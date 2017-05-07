#if os(OSX)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

public protocol StringInitializable {
    init?(string: String)
}

extension String: StringInitializable {
    public init?(string: String) {
        self = string
    }
}

extension Int: StringInitializable {
    public init?(string: String) {
        guard let value = Int(string) else {
            return nil
        }

        self = value
    }
}

extension Bool: StringInitializable {
    public init?(string: String) {
        switch string.lowercased() {
            case "yes", "true", "1":
            self = true
            case "no", "false", "0":
            self = false
        default:
            return nil
        }
    }
}

extension Double: StringInitializable {
    public init?(string: String) {

        var string = string

        if let locale = localeconv(), let decimalPoint = locale.pointee.decimal_point {
            let decimalPointCharacter = Character(UnicodeScalar(UInt8(bitPattern: decimalPoint.pointee)))
            string = string.replacingOccurrences(of: String(decimalPointCharacter), with: ".")
        }

        guard let value = Double(string) else {
            return nil
        }

        self = value
    }
}
