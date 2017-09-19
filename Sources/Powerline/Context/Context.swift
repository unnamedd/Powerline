#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

import class Foundation.ProcessInfo
import class Foundation.FileHandle

public class Context {

    /// Set flags of the context
    public internal(set) var flags: Set<Flag> = []

    /// Specified options of the context
    public internal(set) var options: [Option: String] = [:]

    /// Specified parameters of the context
    public internal(set) var parameters = Parameters()

    internal var commands: [(name: String, argumentIndex: Int)]

    internal var currentCommand: (name: String, argumentIndex: Int) {
        return commands[commands.endIndex - 1]
    }

    /// Arguments passed to the process
    public let arguments: TokenizedArguments

    /// Environment, copied from `ProcessInfo`
    public let environment: [String: String]

    /// The shell encoding of the context
    public let encoding: String.Encoding

    /// Standard input stream
    public let standardInput: InputStream

    /// Standard output stream
    public let standardOutput: OutputStream

    /// Standard error stream
    public let standardError: OutputStream

    internal init(arguments: TokenizedArguments) {
        self.arguments = arguments

        commands = [(name: arguments.executableName, argumentIndex: 0)]

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

        self.environment = environment
        self.encoding = encoding

        standardInput = InputStream(fileHandle: FileHandle.standardInput, encoding: encoding)
        standardOutput = OutputStream(fileHandle: FileHandle.standardOutput, encoding: encoding)
        standardError = OutputStream(fileHandle: FileHandle.standardError, encoding: encoding)
    }
}
