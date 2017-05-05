import Foundation

public struct Context {
    public var environment: [String: String]
    public var encoding: String.Encoding
    public var standardInput: InputStream
    public var standardOutput: OutputStream
    public var standardError: OutputStream
    public var currentDirectory: String {
        get {
            return FileManager.default.currentDirectoryPath
        }
        set {
            guard FileManager.default.changeCurrentDirectoryPath(newValue) else {
                standardError.write("Failed to change current directory path", terminator: "\n")
                exit(EXIT_FAILURE)
            }
        }
    }

    public static let main = Context(
        environment: ProcessInfo.processInfo.environment,
        encoding: .utf8,
        standardInput: InputStream(fileHandle: FileHandle.standardInput, encoding: .utf8),
        standardOutput: OutputStream(fileHandle: FileHandle.standardOutput, encoding: .utf8),
        standardError: OutputStream(fileHandle: FileHandle.standardError, encoding: .utf8)
    )
}
