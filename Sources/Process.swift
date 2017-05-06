import Foundation

public enum ProcessError: Error {
    case fileNotFound(path: String)
    case launchPathNotExecutable(path: String)
    case invalidLaunchPath
    case unsuccessfulExit(
        exitCode: Int,
        standardError: String
    )
}

extension ProcessError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .fileNotFound(path: let path):
            return "No such file at \"\(path)\""
        case .launchPathNotExecutable(let path):
            return "Launch path \"\(path)\" is not an executable"
        case .invalidLaunchPath:
            return "Missing launch path"
        case .unsuccessfulExit(let exitCode, let stderr):
            return "Process finished with non-zero exit value \(exitCode):\n\(stderr)"
        }
    }
}

internal struct ProcessRunner {
    fileprivate let process: Process
    fileprivate let standardOutput: Stream
    fileprivate let standardError: Stream

    internal init(context: Context, combineOutput: Bool = false, executable: String, arguments: String...) throws {
        try self.init(context: context, combineOutput: combineOutput, executable: executable, arguments: arguments)
    }

    internal init(context: Context, combineOutput: Bool = false, executable: String, arguments: [String]) throws {

        func pathForExecutable(executable: String) throws -> String {
            guard !executable.characters.contains("/") else {
                return executable
            }

            let process = try ProcessRunner(
                context: context,
                executable: "/usr/bin/which",
                arguments: executable
            )

            guard let stdout = try process.run().standardOutput else {
                throw ProcessError.invalidLaunchPath
            }

            return stdout
        }

        let standardOutputPipe = Pipe()
        let standardErrorPipe: Pipe

        if combineOutput {
            standardErrorPipe = standardOutputPipe
        } else {
            standardErrorPipe = Pipe()
        }

        standardOutput = Stream(fileHandle: standardOutputPipe.fileHandleForReading, encoding: context.encoding)

        standardError = Stream(fileHandle: standardErrorPipe.fileHandleForReading, encoding: context.encoding)

        let launchPath = try pathForExecutable(executable: executable)

        guard FileManager.default.fileExists(atPath: launchPath) else {
            throw ProcessError.fileNotFound(path: launchPath)
        }

        process = Process()
        process.arguments = arguments
        process.launchPath = launchPath

        process.environment = context.environment
        process.currentDirectoryPath = context.currentDirectory

        process.standardOutput = standardOutputPipe
        process.standardError = standardErrorPipe
    }

    internal func run() throws -> ProcessResult {
        guard let launchPath = process.launchPath else {
            throw ProcessError.invalidLaunchPath
        }

        guard FileManager.default.isExecutableFile(atPath: launchPath) else {
            throw ProcessError.launchPathNotExecutable(path: launchPath)
        }

        process.launch()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {

            let standardError: String = self.standardError.readToEndOfFile()?.trimmingCharacters(
                in: .whitespacesAndNewlines
            ) ?? "Contents of standard error is empty"

            throw ProcessError.unsuccessfulExit(
                exitCode: Int(process.terminationStatus),
                standardError: standardError
            )
        }

        return ProcessResult(
            standardOutput: standardOutput.readToEndOfFile()?.trimmingCharacters(in: .whitespacesAndNewlines),
            standardError: standardError.readToEndOfFile()?.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    @discardableResult
    internal func run(completion: @escaping (_ error: ProcessError?, _ result: ProcessResult?) -> Void) throws -> ProcessHandler {
        guard let launchPath = process.launchPath else {
            throw ProcessError.invalidLaunchPath
        }

        guard FileManager.default.isExecutableFile(atPath: launchPath) else {
            throw ProcessError.launchPathNotExecutable(path: launchPath)
        }

        process.terminationHandler = { process in

            guard process.terminationStatus == 0 else {

                let standardError: String = self.standardError.readToEndOfFile()?.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ) ?? "Contents of standard error is empty"

                let error = ProcessError.unsuccessfulExit(
                    exitCode: Int(process.terminationStatus),
                    standardError: standardError
                )

                completion(error, nil)

                return
            }

            let result = ProcessResult(
                standardOutput: self.standardOutput.readToEndOfFile()?.trimmingCharacters(in: .whitespacesAndNewlines),
                standardError: self.standardError.readToEndOfFile()?.trimmingCharacters(in: .whitespacesAndNewlines)
            )

            completion(nil, result)
        }

        process.launch()

        return ProcessHandler(process: process)
    }
}

/// A `ProcessHandler` allows you to assert the running status of a process, as well as
/// suspend, terminate, interrupt, and resume it.
public struct ProcessHandler {
    private var process: Process

    fileprivate init(process: Process) {
        self.process = process
    }

    /// Determines whether the process is running
    public var isRunning: Bool {
        return process.isRunning
    }

    /// Attempts to suspend the process
    ///
    /// - Returns: `true` if successful, `false` if unsucsessful
    @discardableResult
    public func suspend() -> Bool {
        return process.suspend()
    }

    /// Terminates the process
    public func terminate() {
        process.terminate()
    }

    /// Attempts to resume the process
    ///
    /// - Returns: `true` if successful, `false` if unsucsessful
    @discardableResult
    public func resume() -> Bool {
        return process.resume()
    }

    /// Interrupts the process
    public func interrupt() {
        process.interrupt()
    }
}

/// The output result of a running process
public struct ProcessResult {

    /// The standard output of the process
    public let standardOutput: String?

    /// The standard error of the output
    public let standardError: String?

    internal init(standardOutput: String?, standardError: String?) {

        self.standardOutput = standardOutput
        self.standardError = standardError
    }
}
