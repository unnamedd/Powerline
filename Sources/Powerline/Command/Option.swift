/// An argument which represents a key-value argument.
///
/// Options are passed using their long or short name, followed by their associated value, e.g.
/// `--file-path /tmp/file.txt` or `-f /tmp/file.txt`
///
/// A set of consectutive flags can have a trailing option. If arguments include the flag `-a` and `b`, as well
/// as the option `-f`, it's possible to pass the arguments as `-abc /tmp/file.txt`
public struct Option: ArgumentProtocol {

    /// Name of the option
    public var name: ArgumentName

    /// Summary of the option, shown in the usage of the program
    public let summary: String

    /// Placeholder of the option value, shown in the usage of the program
    public let placeholder: String?

    /// Creates an option with a long name only (e.g `file-path`)
    ///
    /// - Parameters:
    ///   - longName: Long name of the option
    ///   - summary: Summary of the option
    ///   - placeholder: Placeholder of the option value, shown in the usage of the program
    public init(longName: String, summary: String, placeholder: String? = nil) {
        self.name = .long(longName)
        self.summary = summary
        self.placeholder = placeholder ?? "value"
    }

    /// Creates a flag with a short name only (e.g. `v`)
    ///
    /// - Parameters:
    ///   - shortName: Short name, a single character, of the option
    ///   - summary: Summary of the option
    ///   - placeholder: Placeholder of the option value, shown in the usage of the program
    public init(shortName: Character, summary: String, placeholder: String? = nil) {
        self.name = .short(shortName)
        self.summary = summary
        self.placeholder = placeholder ?? "value"
    }

    /// Creates an option with both a long and a short name (e.g. `file-path` and `f`)
    ///
    /// - Parameters:
    ///   - longName: Long name of the option
    ///   - shortName: Short name, a single character, of the option
    ///   - summary: Summary of the option
    ///   - placeholder: Placeholder of the option value, shown in the usage of the program
    public init(longName: String, shortName: Character, summary: String, placeholder: String? = nil) {
        self.name = .both(longName, shortName)
        self.summary = summary
        self.placeholder = placeholder ?? "value"
    }
}
