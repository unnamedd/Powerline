import class Foundation.Pipe
import class Foundation.Process
import class Foundation.FileManager
import Futures

/// Error associated with running processes
public enum ProcessError: Error {

    // Executable file not found
    case fileNotFound(path: String)

    // Path did not resolve to an executable
    case launchPathNotExecutable(path: String)

    // Launch path is invalid
    case invalidLaunchPath

    // Non-zero exit
    case unsuccessfulExit(
        exitCode: Int,
        reason: String?
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
        case let .unsuccessfulExit(exitCode, reason):
            guard let reason = reason else {
                return "Process finished with non-zero exit value \(exitCode)"
            }

            return reason
        }
    }
}

internal struct ProcessRunner {
    fileprivate let process: Process
    fileprivate let standardOutput: Stream
    fileprivate let standardError: Stream

    internal init(context: Context, executable: String, arguments: [String]) throws {

        func pathForExecutable(executable: String) throws -> String {
            guard !executable.contains("/") else {
                return executable
            }

            let process = try ProcessRunner(
                context: context,
                executable: "/usr/bin/which",
                arguments: [executable]
            )

            guard let stdout = try process.run().standardOutput else {
                throw ProcessError.invalidLaunchPath
            }

            return stdout
        }

        let standardOutputPipe = Pipe()
        let standardErrorPipe = Pipe()

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
        process.currentDirectoryPath = context.currentDirectoryPath

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

            let output: String? = self.standardError.readToEndOfFile() ?? self.standardOutput.readToEndOfFile()

            let reason = output?.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            throw ProcessError.unsuccessfulExit(
                exitCode: Int(process.terminationStatus),
                reason: reason
            )
        }

        return ProcessResult(
            standardOutput: standardOutput.readToEndOfFile()?.trimmingCharacters(in: .whitespacesAndNewlines),
            standardError: standardError.readToEndOfFile()?.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    public func run() -> Future<ProcessResult> {
        return promise {
            return try self.run()
        }
    }

    @discardableResult
    internal func run(completion: @escaping (
        _ error: ProcessError?,
        _ result: ProcessResult?) -> Void) throws -> ProcessHandler {

        guard let launchPath = process.launchPath else {
            throw ProcessError.invalidLaunchPath
        }

        guard FileManager.default.isExecutableFile(atPath: launchPath) else {
            throw ProcessError.launchPathNotExecutable(path: launchPath)
        }

        process.terminationHandler = { process in

            guard process.terminationStatus == 0 else {

                let output: String? = self.standardError.readToEndOfFile() ?? self.standardOutput.readToEndOfFile()

                let reason = output?.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

                let error = ProcessError.unsuccessfulExit(
                    exitCode: Int(process.terminationStatus),
                    reason: reason
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
