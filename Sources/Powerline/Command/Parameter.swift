public struct Parameter: ArgumentProtocol {
    public let name: String
    public let summary: String

    public init(name: String, summary: String) {
        self.name = name
        self.summary = summary
    }
}
