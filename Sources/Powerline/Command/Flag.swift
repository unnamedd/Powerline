/// An argument which precense specifies a condition.
/// Flags have no values, rather, their precense is an indicator that a change in the
/// programs behavior is requested.
///
/// Flags can have both a short (single character) and a long name.
///
/// Typically, flags are passed using their long name (`--verbose`), their short name (`-v`),
/// or as a set of consecutive flags (`-abcd`).
public struct Flag: ArgumentProtocol {

    /// Name of the flag
    public var name: ArgumentName

    /// Summary of the flag, shown in the usage of the program
    public let summary: String

    /// Creates a flag with a long name only (e.g `verbose`)
    ///
    /// - Parameters:
    ///   - longName: Long name of the flag
    ///   - summary: Summary of the flag
    public init(longName: String, summary: String) {
        self.name = .long(longName)
        self.summary = summary
    }

    /// Creates a flag with a short name only (e.g. `v`)
    ///
    /// - Parameters:
    ///   - shortName: Short name, a single character, of the flag
    ///   - summary: Summary of the flag
    public init(shortName: Character, summary: String) {
        self.name = .short(shortName)
        self.summary = summary
    }

    /// Creates a flag with both a long and a short name (e.g. `verbose` and `v`)
    ///
    /// - Parameters:
    ///   - longName: Long name of the flag
    ///   - shortName: Short name, a single character, of the flag
    ///   - summary: Summary of the flag
    public init(longName: String, shortName: Character, summary: String) {
        self.name = .both(longName, shortName)
        self.summary = summary
    }
}
