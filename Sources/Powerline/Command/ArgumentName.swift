public enum ArgumentName {
    case short(Character)
    case long(String)
    case both(String, Character)

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
            return "-\(character) / --\(string)"

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
