
// :nodoc:
public protocol ArgumentProtocol: Hashable, CustomStringConvertible {
    associatedtype Name: Hashable, CustomStringConvertible
    
    var name: Name { get }
    var summary: String { get }
}

extension ArgumentProtocol {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name
    }

    public var hashValue: Int {
        return name.hashValue
    }

    public var description: String {
        return "\(name.description)"
    }
}

extension Sequence where Iterator.Element: ArgumentProtocol, Iterator.Element.Name == ArgumentName {

    internal func filter(shortName: Character) -> [Iterator.Element] {
        return filter({ $0.name.shortName == shortName })
    }

    internal func filter(longName: String) -> [Iterator.Element] {
        return filter({ $0.name.longName == longName })
    }

}
