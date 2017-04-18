#if os(OSX)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

public enum StringConvertibleError<T: StringConvertible>: Error, CustomStringConvertible {
    case conversionError(source: String, type: T.Type)

    public var description: String {
        switch self {
        case .conversionError(let source, let type):
            return "Failed to convert \"\(source)\" to \(type)"
        }
    }
}

public protocol StringConvertible {
    init(string: String) throws
}

extension String: StringConvertible {
    public init(string: String) throws {
        self = string
    }
}

extension Int: StringConvertible {
    public init(string: String) throws {
        guard let value = Int(string) else {
            throw StringConvertibleError.conversionError(source: string, type: Int.self)
        }

        self = value
    }
}

extension Bool: StringConvertible {
    public init(string: String) throws {
        switch string.lowercased() {
            case "yes", "true", "1":
            self = true
            case "no", "false", "0":
            self = false
        default:
            throw StringConvertibleError.conversionError(source: string, type: Bool.self)
        }
    }
}

extension Double: StringConvertible {
    public init(string: String) throws {

        var string = string

        if let locale = localeconv(), let decimalPoint = locale.pointee.decimal_point {
            let decimalPointCharacter = Character(UnicodeScalar(UInt8(bitPattern: decimalPoint.pointee)))
            string = string.replacingOccurrences(of: String(decimalPointCharacter), with: ".")
        }

        guard let value = Double(string) else {
            throw StringConvertibleError.conversionError(source: string, type: Double.self)
        }

        self = value
    }
}
