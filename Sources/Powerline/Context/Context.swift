#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

import class Foundation.ProcessInfo
import class Foundation.FileHandle

public class Context {

    public internal(set) var flags: Set<Flag> = []

    public internal(set) var options: [Option: String] = [:]

    public internal(set) var parameters = Parameters()

    internal var commands: [(name: String, argumentIndex: Int)]

    internal var currentCommand: (name: String, argumentIndex: Int) {
        return commands[commands.endIndex - 1]
    }

    public let arguments: Arguments

    public let environment: [String: String]

    public let encoding: String.Encoding

    public let standardInput: InputStream

    public let standardOutput: OutputStream

    public let standardError: OutputStream

    public init(arguments: Arguments) {
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

        self.standardInput = InputStream(fileHandle: FileHandle.standardInput, encoding: encoding)
        self.standardOutput = OutputStream(fileHandle: FileHandle.standardOutput, encoding: encoding)
        self.standardError = OutputStream(fileHandle: FileHandle.standardError, encoding: encoding)
    }
}
