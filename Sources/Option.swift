internal protocol Option: CustomStringConvertible, Hashable {
    var name: String { get }
    var summary: String { get }
}

extension Option {
    public var description: String {
        return "\(name) - \(summary)"
    }
}

internal extension Sequence where Iterator.Element: Option {
    internal func named(_ name: String) -> Iterator.Element? {
        return filter({ $0.name == name }).first
    }
}

extension Option {
    public var hashValue: Int {
        return name.hashValue
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

/// A flag is an argument without a value
/// Flags typically have both a short and a long name, e.g. the short name `-v` and it's corresponding long name
/// `--verbose`.
///
/// Flags can be combined, making `-a -b -c` equal to `-abc`.
public struct Flag: Option {

    /// The name of the flag
    public let name: String

    /// The character (short name) of the flag
    public let character: Character?

    /// A short description, summarizing what enabling the flag does
    public let summary: String

    /// Creates a new flag
    ///
    /// - Parameters:
    ///   - name: The name of the flag
    ///   - character: The character (short name) of the flag
    ///   - summary: A short description, summarizing what enabling the flag does. Defaults to `No summary provided`
    public init(name: String, character: Character? = nil, summary: String = "No summary provided") {

        guard name != "help" && character != "h" else {
            fatalError("Flag name \"help\" and flag character \"h\" are reserved.")
        }

        self.name = name
        self.character = character
        self.summary = summary
    }
}

/// A named argument is an argument with an associated value.
public struct NamedArgument: Option {

    /// The name of the argument
    public let name: String

    /// The characted (short name) of the named argument
    public let character: Character?

    /// A short description, summarizing what the named argument is for
    public let summary: String

    /// The value place holder of the argument, displayed in help. Defaults to `value`
    public let valuePlaceholder: String

    /// Creates a new named argument
    ///
    /// - Parameters:
    ///   - name: The name of the argument
    ///   - character: The character (short name) of the named argument
    ///   - summary: A short description, summarizing what the named argument is for.
    ///              Defaults to `No summary provided`
    ///   - valuePlaceholder: The value place holder of the argument, displayed in help. Defaults to `value`.
    public init(
        name: String,
        character: Character? = nil,
        summary: String = "No summary provided",
        valuePlaceholder: String = "value"
    ) {

        guard name != "help" && character != "h" else {
            fatalError("Named argument name \"help\" and flag character \"h\" are reserved.")
        }

        self.name = name
        self.character = character
        self.summary = summary
        self.valuePlaceholder = valuePlaceholder
    }
}

/// A positonal argument is an argument that is a value in itself
public struct PositionalArgument: Option {

    /// A short description, summarizing what the positional argument is
    public let summary: String

    /// The name of the positional argument
    public let name: String

    /// Specifis whether multiple positional arguments are supported
    public let isVariadic: Bool

    /// Creates a new positional argument
    ///
    /// - Parameters:
    ///   - name: The name of the positional argument
    ///   - summary: A short description, summarizing what the positional argument is
    ///   - variadic: Specifis whether multiple positional arguments are supported
    public init(name: String, summary: String? = nil, variadic: Bool) {
        self.name = name
        self.summary = summary ?? "No summary provided"
        self.isVariadic = variadic
    }
}
