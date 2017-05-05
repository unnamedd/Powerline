#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

import Foundation

/// Error associated with command execution
///
/// - missingValue: Missing value in named argument
/// - missingNamedArgument: Missing named argument
/// - unknownOption: Unexpected option
/// - extranousPositionalArguments: Too many positional arguments
/// - missingPositional: Missing positional argument
/// - notEnoughArguments: Not enouch arguments to run the command
/// - invalidUsage: Invalid usage
/// - other: Custom errors
public enum CommandError: Error, CustomStringConvertible {
    case missingValue(NamedArgument)
    case missingNamedArgument(NamedArgument)
    case unknownOption(String)
    case extranousPositionalArguments
    case missingPositional(PositionalArgument)
    case notEnoughArguments
    case invalidUsage(reason: String)
    case other(String)

    /// Creates a new CommandError with a custom description
    ///
    /// - Parameter error: Error description
    public init(_ error: String) {
        self = .other(error)
    }

    public var description: String {
        switch self {
        case .extranousPositionalArguments:
            return "Extranous positional arguments"
        case .missingNamedArgument(let namedArgument):
            return "Missing argument \"\(namedArgument.name)\""
        case .missingPositional(let positional):
            return "Missing positional argument \(positional.name)"
        case .missingValue(let namedArgument):
            return "Named argument \"\(namedArgument.name)\" is missing a value"
        case .unknownOption(let string):
            return "Unknown option \"\(string)\""
        case .notEnoughArguments:
            return "Not enough arguments"
        case .invalidUsage(let reason):
            return "Invalid usage: \(reason)"
        case .other(let string):
            return string
        }
    }
}

public struct Command {

    /// The name of the command
    public let name: String

    /// Short description of what the command does
    public let summary: String

    /// Flags accepted by the command
    public let flags: Set<Flag>

    /// Named arguments, accepted by the command
    public let namedArguments: Set<NamedArgument>

    /// Positional argument accepted by the command
    public let positionalArgument: PositionalArgument?

    /// Subcommands of the command
    ///
    /// For instance a subcommand of `git` would be `status`.
    public let subcommands: [Command]

    /// Closure handling the result of the comand
    public let handler: (Result) throws -> Void

    /// Creates a new command
    ///
    /// - Parameters:
    ///   - name: Name of the command
    ///   - summary: Short description of what the command does
    ///   - subcommands: Subcommands for the command
    ///   - positionalArgument: Positional argument accepted by the command
    ///   - namedArguments: Named arguments accepted by the command
    ///   - flags: Flags accepted by the command
    ///   - handler: Closure handling the result of the comand
    public init(
        name: String,
        summary: String,
        subcommands: [Command] = [],
        positionalArgument: PositionalArgument? = nil,
        namedArguments: Set<NamedArgument> = [],
        flags: Set<Flag> = [],
        handler: @escaping (Result) throws -> Void
    ) {

        self.name = name
        self.summary = summary
        self.subcommands = subcommands
        self.flags = flags
        self.namedArguments = namedArguments
        self.positionalArgument = positionalArgument
        self.handler = handler
    }
}

internal extension Command {
    internal func flag(withCharacter character: Character) -> Flag? {
        return flags.filter({ $0.character == character }).first
    }

    internal func flag(named name: String) -> Flag? {
        return flags.filter({ $0.name == name }).first
    }

    internal func namedArgument(withCharacter character: Character) -> NamedArgument? {
        return namedArguments.filter({ $0.character == character }).first
    }

    internal func namedArgument(named name: String) -> NamedArgument? {
        return namedArguments.filter({ $0.name == name }).first
    }

    internal func subcommand(named name: String) -> Command? {
        return subcommands.filter({ $0.name == name }).first
    }

    internal var usageString: String {

        var string = ""

        string += "NAME\n"

        string += "\t\(name) - \(summary)\n\n"

        string += "USAGE\n"

        string += "\t\(name) [options]\n\n"

        if !subcommands.isEmpty {

            string += "COMMANDS\n"

            for subcommand in subcommands {
                string += "\t\(subcommand.name) - \(subcommand.summary)\n\n"
            }
        }

        if flags.count + namedArguments.count > 0 {

            string += "OPTIONS\n"

            for flag in flags {

                string += "\t"

                if let character = flag.character {
                    string += "-\(character), "
                }

                string += " --\(flag.name)\n\t\t\(flag.summary)\n\n"

            }

            string += "\t-h, --help\n\t\tShow usage description\n\n"

            for namedArgument in namedArguments {
                string += "\t"

                if let character = namedArgument.character {
                    string += "-\(character), "
                }

                string += "--\(namedArgument.name) <\(namedArgument.valuePlaceholder)>\n\t\t\(namedArgument.summary)\n\n"
            }

        }

        return string
    }
}

public extension Command {

    /// Runs the command, supressing thrown errors exiting and printing the error or usage, if the 
    /// command was improperly used
    ///
    /// - Parameter arguments: Arguments to pass to the command. Defaults to `CommandLine.arguments`
    public func runOrExit(arguments: [String] = CommandLine.arguments) {
        runOrExit(arguments: arguments, context: .main)
    }

    private func runOrExit(arguments: [String] = CommandLine.arguments, context: Context) {

        do {
            try run(arguments: arguments, context: context)
        } catch CommandError.invalidUsage(let reason) {
            context.standardError.write(reason, terminator: "\n")
            context.standardError.write(usageString, terminator: "\n")
            exit(64)
        } catch let error as CommandError {
            context.standardError.write(error.description, terminator: "\n")
            exit(EXIT_FAILURE)
        } catch {
            context.standardError.write(error.localizedDescription, terminator: "\n")
            exit(EXIT_FAILURE)
        }
    }

    /// Runs the command
    ///
    /// - Parameter arguments: Arguments to pass to the command. Defaults to `CommandLine.arguments`
    public func run(arguments: [String] = CommandLine.arguments) throws {
        try run(arguments: arguments, context: .main)
    }

    private func run(arguments: [String] = CommandLine.arguments, context: Context) throws {

        var context = context

        guard arguments.count >= 1 else {
            throw CommandError.notEnoughArguments
        }

        var setFlags: Set<Flag> = []
        var positionalValues = [String]()
        var valuesByNamedArgument = [NamedArgument: String]()

        var argumentIndex = 1

        while argumentIndex < arguments.count {

            let argument = arguments[argumentIndex]

            guard argument != "==" else {
                break
            }

            defer {
                argumentIndex += 1
            }

            func extractArgument(for namedArgument: NamedArgument) throws {
                guard argumentIndex < arguments.endIndex - 1 else {
                    throw CommandError.missingValue(namedArgument)
                }

                argumentIndex += 1

                let value = arguments[argumentIndex].replacingOccurrences(of: "\"", with: "")

                guard !value.hasPrefix("-") else {
                    throw CommandError.missingValue(namedArgument)
                }

                valuesByNamedArgument[namedArgument] = value
            }

            // Check for long-named arguments or flags
            if argument.hasPrefix("--") && argument.characters.count > 2 {
                // Extract the name of that argument
                let argumentName = argument.substring(from: argument.index(argument.startIndex, offsetBy: 2))

                if argumentName == "help" {
                    context.standardOutput.write(usageString, terminator: "\n")
                    exit(EXIT_SUCCESS)
                }

                // Find a named argument corresponding to the name
                if let namedArgument = namedArguments.named(argumentName) {
                    try extractArgument(for: namedArgument)
                } else if let flag = flag(named: argumentName) {
                    setFlags.insert(flag)
                } else {
                    throw CommandError.unknownOption(argumentName)
                }

                continue
            }

            // Check for short-named arguments or flags
            if argument.hasPrefix("-") && argument.characters.count > 1 {

                let string = argument.substring(from: argument.index(argument.startIndex, offsetBy: 1))

                if string.characters.count == 1 {

                    guard string != "h" else {
                        context.standardOutput.write(usageString, terminator: "\n")
                        exit(EXIT_SUCCESS)
                    }

                    if let flag = flag(withCharacter: string.characters[string.startIndex]) {
                        setFlags.insert(flag)

                        // String has one characater, but does not correspond to a flag
                    } else if let namedArgument = namedArgument(withCharacter: string.characters[string.startIndex]) {
                        try extractArgument(for: namedArgument)
                    } else {
                        throw CommandError.unknownOption(string)
                    }
                } else {
                    // Check if the string is a flag
                    if let flag = flag(named: string) {
                        setFlags.insert(flag)
                    } else {
                        // Loop through the characters, extract flags
                        for (characterIndex, character) in string.characters.enumerated() {

                            if let flag = flag(withCharacter: character) {
                                setFlags.insert(flag)
                                // No matching flag found. Look for trailing argument by matching
                                // argument character IF the character is last in sequence
                            } else if
                                characterIndex == string.characters.count - 1,
                                let namedArgument = namedArgument(withCharacter: character) {
                                try extractArgument(for: namedArgument)
                            } else {
                                throw CommandError.unknownOption(string)
                            }
                        }
                    }
                }

                continue
            }

            if let subcommand = subcommand(named: argument) {
                return try subcommand.run(arguments: Array(arguments[1..<arguments.count]))
            }

            // In any other case we're dealing with a positional argument
            guard let positional = positionalArgument else {
                throw CommandError.extranousPositionalArguments
            }

            if !positional.isVariadic && !positionalValues.isEmpty {
                throw CommandError.extranousPositionalArguments
            }

            positionalValues.append(argument)
        }

        let result = Result(
            context: context,
            positionalValues: positionalValues,
            valuesByNamedArgument: valuesByNamedArgument,
            flags: setFlags
        )

        try handler(result)

    }
}
