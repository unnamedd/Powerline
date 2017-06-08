public struct Option: ArgumentProtocol {

    public var name: ArgumentName

    public let summary: String

    public let placeholder: String?

    public init(longName: String, summary: String, placeholder: String? = nil) {
        self.name = .long(longName)
        self.summary = summary
        self.placeholder = placeholder ?? "value"
    }

    public init(shortName: Character, summary: String, placeholder: String? = nil) {
        self.name = .short(shortName)
        self.summary = summary
        self.placeholder = placeholder ?? "value"
    }

    public init(longName: String, shortName: Character, summary: String, placeholder: String? = nil) {
        self.name = .both(longName, shortName)
        self.summary = summary
        self.placeholder = placeholder ?? "value"
    }
}
