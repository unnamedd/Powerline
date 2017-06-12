/// An argument that is a value in itself
public struct Parameter: ArgumentProtocol {

    /// Name of the parameter
    public let name: String

    /// Summary of the parameter, shown in the usage of the program
    public let summary: String

    /// Creates a new `Parameter`
    ///
    /// - Parameters:
    ///   - name: Name of the parameter
    ///   - summary: Summary of the parameter, shown in the usage of the program
    public init(name: String, summary: String) {
        self.name = name
        self.summary = summary
    }
}
