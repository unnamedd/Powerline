import Foundation

#if os(OSX)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

public struct Powerline {
    public struct Error: Swift.Error, CustomStringConvertible {
        public let description: String
    }

    fileprivate(set) public var commands: [Command]

    public init(commands: [Command]) {
        self.commands = commands

        setlocale(LC_ALL, "")
    }

    public func run(arguments: [String] = CommandLine.arguments) throws -> Command.Result  {
        guard arguments.count >= 2 else {
            throw Error(description: "Not enough arguments")
        }

        let commandName = arguments[1]

        guard let command = commands.filter({ $0.name == commandName }).first else {
            throw Error(description: "Command named \(commandName) not found")
        }

        return try command.run(arguments: arguments)
    }

}

extension Command {
    public struct Result {
        public let flags: Set<Flag>
        private let valuesByPositional: [Positional: String]
        private let valuesByNamedArgument: [NamedArgument: String]

        internal init(valuesByPositional: [Positional: String], valuesByNamedArgument: [NamedArgument: String], flags: Set<Flag>) {
            self.valuesByPositional = valuesByPositional
            self.valuesByNamedArgument = valuesByNamedArgument
            self.flags = flags
        }
        
        
    }
}

public struct Command {
    public struct Error: Swift.Error, CustomStringConvertible {
        public let description: String
    }

    private(set) public var name: String
    private(set) public var flags: Set<Flag>
    private(set) public var namedArguments: Set<NamedArgument>
    private(set) public var positional: [Positional]

    public init(name: String, positional: [Positional] = [], namedArguments: Set<NamedArgument> = [], flags: Set<Flag> = []) {
        self.name = name
        self.positional = positional
        self.namedArguments = namedArguments
        self.flags = flags
    }

    public func run(arguments: [String] = CommandLine.arguments) throws -> Result {
        guard arguments.count >= 2 else {
            throw Error(description: "Not enough arguments")
        }

        var setFlags: Set<Flag> = []
        var valuesByPositional = [Positional: String]()
        var valuesByNamedArgument = [NamedArgument: String]()

        let arguments = Array(arguments[1..<arguments.endIndex])

        for var i in 0..<arguments.count {
            let argument = arguments[i]

            guard argument != "==" else {
                break
            }

            if argument.hasPrefix("--") {

                let argumentName = argument.substring(from: argument.index(argument.startIndex, offsetBy: 2))

                if let namedArgument = namedArguments.named(argumentName) {

                    guard i < arguments.endIndex - 1 else {
                        throw Error(description: "No value provided for argument named \(argumentName)")
                    }

                    i += 1

                    valuesByNamedArgument[namedArgument] = arguments[i].components(separatedBy: "=").last ?? ""
                }
            }

            else if argument.hasPrefix("-") {

                let string = argument.substring(from: argument.index(argument.startIndex, offsetBy: 1))

                switch string.characters.count {
                case 0:
                    throw Error(description: "Invalid flag, stray dash character")


                case 1:
                    if let flag = flag(withCharacter: string.characters[string.startIndex]) {
                        setFlags.insert(flag)

                    } else if let namedArgument = namedArgument(withCharacter: string.characters[string.startIndex]) {
                        i += 1

                        valuesByNamedArgument[namedArgument] = arguments[i].components(separatedBy: "=").last ?? ""
                    }
                    else {
                        throw Error(description: "Unknown flag \(String(string.characters))")
                    }
                    break

                default:

                    if let flag = flag(named: string) {
                        setFlags.insert(flag)
                    }
                    else {
                        for (ii, character) in string.characters.enumerated() {

                            if let flag = flag(withCharacter: character) {
                                setFlags.insert(flag)
                            }
                            else if ii == string.characters.count - 1, let namedArgument = namedArgument(withCharacter: character) {
                                i += 1

                                valuesByNamedArgument[namedArgument] = arguments[i].components(separatedBy: "=").last ?? ""
                            }
                        }
                    }

                    break
                }

            }
            else {

            }
        }

        return .init(valuesByPositional: valuesByPositional, valuesByNamedArgument: valuesByNamedArgument, flags: setFlags)
    }

    public func flag(withCharacter character: Character) -> Flag? {
        return flags.filter({ $0.character == character }).first
    }

    public func flag(named name: String) -> Flag? {
        return flags.filter({ $0.name == name }).first
    }

    public func namedArgument(withCharacter character: Character) -> NamedArgument? {
        return namedArguments.filter({ $0.character == character }).first
    }

    public func namedArgument(named name: String) -> NamedArgument? {
        return namedArguments.filter({ $0.name == name }).first
    }
}


public protocol Argument: CustomStringConvertible, Hashable {
    var name: String { get }
}

internal extension Sequence where Iterator.Element: Argument {
    internal func named(_ name: String) -> Iterator.Element? {
        return filter({ $0.name == name }).first
    }
}

public extension Argument {
    public var hashValue: Int {
        return name.hashValue
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

public struct Flag: Argument {

    public let name: String
    public let character: Character
    public let description: String

    public init(name: String, character: Character, description: String) {
        self.name = name
        self.character = character
        self.description = description
    }
}

public struct NamedArgument: Argument {
    public let name: String
    public let character: Character
    public let description: String
    public let valuePlaceholder: String

    public init(name: String, character: Character, description: String, valuePlaceholder: String) {
        self.name = name
        self.character = character
        self.description = description
        self.valuePlaceholder = valuePlaceholder
    }
}

public struct Positional: Argument {
    public let description: String
    public let name: String
    
    public init(name: String, description: String) {
        self.name = name
        self.description = description
    }
}
