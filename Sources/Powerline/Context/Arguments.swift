import Foundation

/// Arguments is a collection of strings, representing the arguments, including the executable
//  of a Powerline process
public struct TokenizedArguments {

    public enum TokenType {
        case shortOption(Character)
        case longOption(String)
        case parameter(String)
        case optionSet([Character])
    }

    public struct Token {

        let index: Int
        let type: TokenType

        internal init(index: Int, type: TokenType) {
            self.index = index
            self.type = type
        }
    }

    /// Executable argument
    public let executable: String

    public let rawArguments: [String]

    internal let components: [Token]

    internal init?(arguments: [String]) {

        guard arguments.isEmpty == false else {
            return nil
        }

        self.rawArguments = arguments

        executable = arguments[0]

        var tokens: [Token] = []

        for (index, argument) in arguments.enumerated() {

            // If the argument has a prefix of two dashes it's a long option
            if argument.hasPrefix("--"), argument.count > 2 {

                let stringIndex = argument.index(argument.startIndex, offsetBy: 2)

                tokens.append(
                    Token(index: index, type: .longOption(String(argument[stringIndex...])))
                )

                // If the argument has a prefix of one dash it's a short option or a optionset
            } else if argument.hasPrefix("-"), argument.count > 1 {

                let stringIndex = argument.index(argument.startIndex, offsetBy: 1)

                // If a short option has exactly two characters (one including the dash) it's a short option
                if argument.count == 2 {
                    tokens.append(
                        Token(index: index, type: .shortOption(argument[stringIndex]))
                    )
                    // If the number of characters (excluding the dash) exceeds one, it's an optionset
                } else {
                    tokens.append(
                        Token(index: index, type: .optionSet(Array(String(argument[stringIndex...]))))
                    )
                }

                // If all else, it's a value
            } else {
                tokens.append(
                    Token(index: index, type: .parameter(argument))
                )
            }
        }

        self.components = tokens
    }
}

extension TokenizedArguments {

    internal func token(after index: Int) -> Token? {
        guard components.count > index + 1 else {
            return nil
        }

        return components[index + 1]
    }

    internal func token(before index: Int) -> Token? {
        guard index > 0 else {
            return nil
        }

        return components[index - 1]
    }
}

public extension TokenizedArguments {

    /// Name of the executable
    var executableName: String {
        guard executable.contains("/") else {
            return executable
        }

        let components = executable.components(separatedBy: "/")
        return components[components.endIndex - 1]
    }
}

extension TokenizedArguments: Collection {

    public var startIndex: Int {
        return components.startIndex
    }

    public var endIndex: Int {
        return components.endIndex
    }

    public func index(after index: Int) -> Int {
        return components.index(after: index)
    }

    public subscript (position: Int) -> Token {
        return components[position]
    }
}
