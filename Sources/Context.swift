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

    public static let main: Context = {

        let environment = ProcessInfo.processInfo.environment

        let encodingString = environment["LC_TYPE"] ?? environment["LANG"]?.components(separatedBy: ".").last ?? "UTF-8"
        let encoding: String.Encoding

        switch encodingString.lowercased() {
        case "utf-8":
            encoding = .utf8
        case "ascii":
            encoding = .ascii
        case "unicode":
            encoding = .unicode
        case "utf-16":
            encoding = .utf16
        default:
            encoding = .utf8
        }

        // TODO: Support more

        return Context(
            environment: environment,
            encoding: encoding,
            standardInput: InputStream(fileHandle: FileHandle.standardInput, encoding: .utf8),
            standardOutput: OutputStream(fileHandle: FileHandle.standardOutput, encoding: .utf8),
            standardError: OutputStream(fileHandle: FileHandle.standardError, encoding: .utf8)
        )
    }()
}
