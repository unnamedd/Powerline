#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

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
    case unexpectedArgument(String)
    case missingPositional(PositionalArgument)
    case notEnoughArguments
    case invalidUsage(reason: String)
    case other(String)

    /// Creates a new CommandError with a custom message
    ///
    /// - Parameters:
    ///   - invalidUsage: If set to `true`, usage will be printed out
    ///   - message: Message to print
    public init(_ message: String, invalidUsage: Bool = false) {
        guard invalidUsage else {
            self = .other(message)
            return
        }

        self = .invalidUsage(reason: message)
    }

    public var description: String {
        switch self {
        case .unexpectedArgument(let argument):
            return "Unexpected argument \"\(argument)\""
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

public protocol Command {

    /// Short description of what the command does
    var summary: String { get }

    /// Flags accepted by the command
    var flags: Set<Flag> { get }

    /// Named arguments, accepted by the command
    var namedArguments: Set<NamedArgument> { get }

    /// Positional argument accepted by the command
    var positionalArgument: PositionalArgument? { get }

    /// Subcommands of the command
    ///
    /// For instance a subcommand of `git` would be `status`.
    var subcommands: [String: Command] { get }

    /// Invoked when the command is run
    ///
    /// - Parameter process: Process grants access to the parameters of the running process
    ///   such as options, environment, stdout, stdin, and more
    func run(process: CommandProcess) throws
}

extension Command {

    public var flags: Set<Flag> {
        return []
    }

    public var namedArguments: Set<NamedArgument> {
        return []
    }

    public func run(process: CommandProcess) throws {
        process.print(usageString(name: try name(fromArguments: process.rawArguments)))
    }

    public var subcommands: [String: Command] {
        return [:]
    }
}

extension Command {
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

    internal func usageString(name: String) -> String {

        var string = ""

        let indentation = "  "

        string += "NAME".bold + "\n"

        string += "\(indentation)\(name) - \(summary.dimmed)\n\n"

        if positionalArgument != nil || !flags.isEmpty || !namedArguments.isEmpty {

            string += "USAGE".bold + "\n"

            string += "\(indentation)\(name.underlined) " + "[options]".magenta

            if let positionalArgument = positionalArgument {
                string += " " + "[\(positionalArgument.name)\(positionalArgument.isVariadic ? "..." : "")]".blue

                string += "\n" + indentation + positionalArgument.name.blue + " - " + positionalArgument.summary.dimmed
            }

            string += "\n\n"
        }

        if !subcommands.isEmpty {

            string += "SUBCOMMANDS".bold + "\n"

            for (subcommandName, subcommand) in subcommands {
                string += "\(indentation)\(subcommandName.underlined) - \(subcommand.summary.dimmed)\n"
            }

            string += "\n"
        }

        if flags.count + namedArguments.count > 0 {

            string += "OPTIONS".bold + "\n"

            for flag in flags {

                string += "\(indentation)"

                if let character = flag.character {
                    string += "-\(character)".bold.magenta + ", "
                }

                string += " " + "--\(flag.name)".blue + "\n\(indentation)\(indentation)\(flag.summary.dimmed)\n\n"

            }

            string += "\(indentation)" + "-h".bold.magenta + ", " + "--help".blue + "\n\(indentation)\(indentation)" + "Show usage description".dimmed + "\n\n"

            for namedArgument in namedArguments {
                string += "\(indentation)"

                if let character = namedArgument.character {
                    string += "-\(character)".bold.magenta + ", "
                }

                string += "--\(namedArgument.name)".blue + "<\(namedArgument.valuePlaceholder)>".italic + "\n\(indentation)\(indentation)\(namedArgument.summary.dimmed)" + "\n\n"
            }

        }

        return string
    }
}

extension Command {
    internal func name(fromArguments arguments: [String]) throws -> String {
        guard !arguments.isEmpty else {
            throw CommandError.notEnoughArguments
        }

        let name = arguments[0]

        let nameComponents = name.components(separatedBy: "/")
        guard nameComponents.count > 1 else {
            return name
        }

        return nameComponents[nameComponents.endIndex - 1]
    }
}

extension Command {

    /// Runs the command, supressing thrown errors exiting and printing the error or usage, if the 
    /// command was improperly used
    ///
    /// - Parameter arguments: Arguments to pass to the command. Defaults to `CommandLine.arguments`
    final public func runOrExit(arguments: [String] = CommandLine.arguments) {
        runOrExit(arguments: arguments, context: .main)
    }

    private func runOrExit(arguments: [String] = CommandLine.arguments, context: Context) {

        do {
            try run(arguments: arguments, context: context)
        } catch CommandError.invalidUsage(let reason) {
            context.standardError.write(reason.red, terminator: "\n")

            if let name = try? name(fromArguments: arguments) {
                context.standardError.write(usageString(name: name), terminator: "\n")
            }

            exit(64)
        } catch StandardInputInitializableError.failedConversion(let input, let type) {
            context.standardError.write(
                "\"\(input)\" cannot be converted to \(String(describing: type))".red,
                terminator: "\n"
            )
            context.standardOutput.write("Examples:".magenta, terminator: " ")
            context.standardOutput.write(type.inputExamples.joined(separator: ", ").dimmed, terminator: "\n")

        } catch let error as CommandError {
            context.standardError.write(error.description.red, terminator: "\n")
            exit(EXIT_FAILURE)
        } catch {
            context.standardError.write(String(describing: error).red, terminator: "\n")
            exit(EXIT_FAILURE)
        }
    }

    /// Runs the command
    ///
    /// - Parameter arguments: Arguments to pass to the command. Defaults to `CommandLine.arguments`
    final public func run(arguments: [String] = CommandLine.arguments) throws {
        try run(arguments: arguments, context: .main)
    }

    private func run(arguments: [String] = CommandLine.arguments, context: Context) throws {

        guard arguments.count >= 1 else {
            throw CommandError.notEnoughArguments
        }

        let name = try self.name(fromArguments: arguments)

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
                    context.standardOutput.write(usageString(name: name), terminator: "\n")
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
                        context.standardOutput.write(usageString(name: name), terminator: "\n")
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

            if let subcommand = subcommands[argument] {
                return try subcommand.run(arguments: Array(arguments[1..<arguments.count]))
            }

            // In any other case we're dealing with a positional argument
            guard let positional = positionalArgument else {
                throw CommandError.unexpectedArgument(argument)
            }

            if !positional.isVariadic && !positionalValues.isEmpty {
                throw CommandError.unexpectedArgument(argument)
            }

            positionalValues.append(argument)
        }

        try run(
            process: .init(
                rawArguments: arguments,
                context: context,
                positionalValues: positionalValues,
                valuesByNamedArgument: valuesByNamedArgument,
                flags: setFlags
            )
        )

    }
}
