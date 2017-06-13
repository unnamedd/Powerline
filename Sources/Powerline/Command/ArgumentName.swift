/// An enum that specifies the name of an argument which supports both a long and a short name
public enum ArgumentName {

    /// Short argument name, character
    case short(Character)

    /// Long argument name, string
    case long(String)

    /// Both long and short argument name, string, character
    case both(String, Character)

    /// The long version of an argument name, if defined
    public var longName: String? {

        switch self {

        case .both(let longName, _):
            return longName

        case .long(let longName):
            return longName

        case .short:
            return nil
        }
    }

    /// The short name of an argument, if defined
    public var shortName: Character? {
        switch self {
        case .both(_, let short):
            return short

        case .long:
            return nil

        case .short(let short):
            return short
        }
    }
}

extension ArgumentName: Equatable {
    public static func == (lhs: ArgumentName, rhs: ArgumentName) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension ArgumentName: CustomStringConvertible {
    public var description: String {
        switch self {

        case .both(let string, let character):
            return "-\(character), --\(string)"

        case .long(let string):
            return "--\(string)"

        case .short(let character):
            return "-\(character)"
        }
    }
}

extension ArgumentName: Hashable {
    public var hashValue: Int {
        switch self {
        case .both(let name, let character):
            return name.hashValue ^ character.hashValue
        case .short(let character):
            return character.hashValue
        case .long(let name):
            return name.hashValue
        }
    }
}
