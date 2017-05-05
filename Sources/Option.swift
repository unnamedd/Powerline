public protocol Option: CustomStringConvertible, Hashable {
    var name: String { get }
    var summary: String { get }
}

public extension Option {
    public var description: String {
        return "\(name) - \(summary)"
    }
}

internal extension Sequence where Iterator.Element: Option {
    internal func named(_ name: String) -> Iterator.Element? {
        return filter({ $0.name == name }).first
    }
}

public extension Option {
    public var hashValue: Int {
        return name.hashValue
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

public struct Flag: Option {

    public let name: String
    public let character: Character?
    public let summary: String

    public init(name: String, character: Character? = nil, summary: String? = nil) {

        guard name != "help" && character != "h" else {
            fatalError("Flag name \"help\" and flag character \"h\" are reserved.")
        }

        self.name = name
        self.character = character
        self.summary = summary ?? "No summary provided"
    }
}

public struct NamedArgument: Option {
    public let name: String
    public let character: Character?
    public let summary: String
    public let valuePlaceholder: String

    public init(name: String, character: Character? = nil, summary: String? = nil, valuePlaceholder: String? = nil) {

        guard name != "help" && character != "h" else {
            fatalError("Named argument name \"help\" and flag character \"h\" are reserved.")
        }

        self.name = name
        self.character = character
        self.summary = summary ?? "No summary provided"
        self.valuePlaceholder = valuePlaceholder ?? "value"
    }
}

public struct PositionalArgument: Option {
    public let summary: String
    public let name: String
    public let isVariadic: Bool

    public init(name: String, summary: String? = nil, variadic: Bool) {
        self.name = name
        self.summary = summary ?? "No summary provided"
        self.isVariadic = variadic
    }
}
