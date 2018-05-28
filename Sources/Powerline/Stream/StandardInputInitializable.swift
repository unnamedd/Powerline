#if os(OSX)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

import struct Foundation.URL

/// Error associated with initializing types from standard input
public enum StandardInputInitializableError: Error {

    /// Conversion from standard input to specified type failed
    case failedConversion(of: String, to: StandardInputInitializable.Type)
}

extension StandardInputInitializableError: CustomStringConvertible {

    public var description: String {
        switch self {
        case .failedConversion(of: let value, to: let type):

            var string = "\"\(value)\" cannot be converted to \(String(describing: type))".red
            string += "Examples:".magenta + type.inputExamples.joined(separator: ", ").dimmed
            return string
        }
    }
}

/// A protocol that provides functionality to convert strings from stdin to
/// other types
public protocol StandardInputInitializable {

    init?(input: String)

    /// An array of valid strings that would result in a successful conversion
    static var inputExamples: [String] { get }
}

extension String: StandardInputInitializable {

    public init?(input: String) {
        self = input
    }

    public static let inputExamples: [String] = []
}

extension Int: StandardInputInitializable {
    public init?(input: String) {
        guard let value = Int(input) else {
            return nil
        }

        self = value
    }

    public static let inputExamples: [String] = []
}

extension Bool: StandardInputInitializable {
    public init?(input: String) {
        switch input.lowercased() {
        case "yes", "true", "1":
            self = true
        case "no", "false", "0":
            self = false
        default:
            return nil
        }
    }

    public static let inputExamples = ["yes", "true", "1", "no", "false", "0"]
}

extension Double: StandardInputInitializable {

    public init?(input: String) {

        var string = input

        if let locale = localeconv(), let decimalPoint = locale.pointee.decimal_point {
            let decimalPointCharacter = Character(UnicodeScalar(UInt8(bitPattern: decimalPoint.pointee)))
            string = string.replacingOccurrences(of: String(decimalPointCharacter), with: ".")
        }

        guard let value = Double(string) else {
            return nil
        }

        self = value
    }

    public static let inputExamples = ["1", "1.1", "1035.3999"]
}

extension URL: StandardInputInitializable {
    public static let inputExamples = ["http://www.github.com", "~/Desktop", "/usr/local/bin", "directory"]

    public init?(input: String) {
        self.init(string: input)
    }
}
