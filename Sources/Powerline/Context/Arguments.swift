import Foundation

internal protocol ArgumentsComponent {
    var index: Int { get }
    var string: String { get }
}

public struct Arguments {

    internal struct ShortOption: ArgumentsComponent {
        let index: Int
        let character: Character

        var string: String {
            return String(character)
        }
    }

    internal struct LongOption: ArgumentsComponent {
        let index: Int
        let name: String

        var string: String {
            return name
        }
    }

    internal struct Parameter: ArgumentsComponent {
        let index: Int
        let value: String

        var string: String {
            return value
        }
    }

    internal struct OptionSet: ArgumentsComponent {
        let index: Int
        let characters: [Character]

        var string: String {
            return String(characters)
        }
    }

    public let executable: String

    fileprivate let rawArguments: [String]

    internal let components: [ArgumentsComponent]

    internal init?(arguments: [String]) {

        guard arguments.isEmpty == false else {
            return nil
        }

        self.rawArguments = arguments

        executable = arguments[0]

        var components: [ArgumentsComponent] = []

        for (i, argument) in arguments.enumerated() {

            // If the argument has a prefix of two dashes it's a long option
            if argument.hasPrefix("--"), argument.characters.count > 2 {

                let index = argument.index(argument.startIndex, offsetBy: 2)

                components.append(
                    LongOption(index: i, name: argument.substring(from: index))
                )

                // If the argument has a prefix of one dash it's a short option or a optionset
            } else if argument.hasPrefix("-"), argument.characters.count > 1 {

                let index = argument.index(argument.startIndex, offsetBy: 1)

                // If a short option has exactly two characters (one including the dash) it's a short option
                if argument.characters.count == 2 {
                    components.append(
                        ShortOption(index: i, character: argument.characters[index])
                    )
                    // If the number of characters (excluding the dash) exceeds one, it's an optionset
                } else {
                    components.append(
                        OptionSet(index: i, characters: Array(argument.substring(from: index).characters))
                    )
                }

                // If all else, it's a value
            } else {

                components.append(
                    Parameter(index: i, value: argument)
                )
            }
        }

        self.components = components
    }
}

extension Arguments {

    func component(after component: ArgumentsComponent) -> ArgumentsComponent? {
        guard components.count > component.index + 1 else {
            return nil
        }

        return components[component.index + 1]
    }

    func component(before component: ArgumentsComponent) -> ArgumentsComponent? {
        guard component.index > 0 else {
            return nil
        }

        return components[component.index - 1]
    }
}

extension Arguments {

    public var executableName: String {
        guard executable.contains("/") else {
            return executable
        }

        let components = executable.components(separatedBy: "/")
        return components[components.endIndex - 1]
    }
}

extension Arguments: Collection {

    public var startIndex: Int {
        return rawArguments.startIndex
    }

    public var endIndex: Int {
        return rawArguments.endIndex
    }

    public func index(after i: Int) -> Int {
        return rawArguments.index(after: i)
    }

    public subscript (position: Int) -> String {
        return rawArguments[position]
    }
}
