public struct Flag: ArgumentProtocol {

    public var name: ArgumentName

    public let summary: String

    public init(longName: String, summary: String) {
        self.name = .long(longName)
        self.summary = summary
    }

    public init(shortName: Character, summary: String) {
        self.name = .short(shortName)
        self.summary = summary
    }

    public init(longName: String, shortName: Character, summary: String) {
        self.name = .both(longName, shortName)
        self.summary = summary
    }
}
