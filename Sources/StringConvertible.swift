#if os(OSX)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

public struct StringConvertibleError: Error, CustomStringConvertible {
    public let description: String
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
            throw StringConvertibleError(description: "Failed to convert \(string) to int")
        }

        self = value
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
            throw StringConvertibleError(description: "Failed to convert \(string) to int")
        }

        self = value
    }
}
