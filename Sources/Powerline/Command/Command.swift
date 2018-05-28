#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

public struct Arguments {
    internal var flags: Set<Flag>
    internal var options: Set<Option>
    internal var parameters: [Parameter]
    internal var variadicParameter: Parameter?

    public init(
        flags: Set<Flag> = [],
        options: Set<Option> = [],
        parameters: [Parameter] = [],
        variadicParameter: Parameter? = nil) {

        self.flags = flags
        self.options = options
        self.parameters = parameters
        self.variadicParameter = variadicParameter
    }
}

public protocol Command {

    var summary: String { get }

    var arguments: Arguments { get }

    var subcommands: [String: Command] { get }

    func process(context: Context) throws
}

extension Command {
    public var subcommands: [String: Command] {
        return [:]
    }
}

extension Command {

    public func run(arguments: [String] = CommandLine.arguments) throws {

        guard let arguments = TokenizedArguments(arguments: arguments) else {
            print("Not enough arguments")
            exit(EXIT_FAILURE)
        }

        let context = Context(arguments: arguments)

        do {
            try run(context: context)

        } catch let error as StandardInputInitializableError {

            context.error(error.description)

        } catch let error as CommandError {

            context.error(error.description.red)

            if case .other(_, let invalidUsage) = error, invalidUsage == true {
                context.print(contextualUsageString(for: context))
            }

        } catch {
            throw error
        }
    }

    private func run(context: Context) throws {

        // Loop through all arguments in the context
        for component in context.arguments.components {
            guard try parse(token: component, context: context) else {
                return
            }
        }

        try process(context: context)
    }

    // Returns false if a subcommand was encountered, which then will continue the execution
    private func parse(token: TokenizedArguments.Token, context: Context) throws -> Bool {
        switch token.type {
        case .parameter(let parameterName):

            // We won't parse tokens with an index less than the current index of the context's current command
            guard token.index > context.currentCommand.argumentIndex else {
                break
            }

            if token.index == context.currentCommand.argumentIndex + 1, let subcommand = subcommands[parameterName] {
                context.commands.append((name: parameterName, argumentIndex: token.index))
                try subcommand.run(context: context)
                return false

            } else {
                try parse(parameter: parameterName, at: token.index, context: context)
            }

        case .longOption(let longOptionName):

            if longOptionName == "help" {
                context.print(contextualUsageString(for: context))
                exit(EXIT_SUCCESS)
            }

            try parse(longOption: longOptionName, at: token.index, context: context)

        case .shortOption(let shortOptionCharacter):

            if shortOptionCharacter == "h" {
                context.print(contextualUsageString(for: context))
                exit(EXIT_SUCCESS)
            }

            try parse(shortOption: shortOptionCharacter, at: token.index, context: context)

        case .optionSet(let optionSet):
            try parse(optionSet: optionSet, at: token.index, context: context)
        }

        return true
    }

    @inline(__always)
    private func parse(parameter value: String, at index: Int, context: Context) throws {

        if let previousToken = context.arguments.token(before: index) {
            switch previousToken.type {
            case .longOption(let longOptionName):
                guard arguments.options.filter(longName: longOptionName).isEmpty else {
                    return
                }
            case .shortOption(let shortOptionCharacter):
                guard arguments.options.filter(shortName: shortOptionCharacter).isEmpty else {
                    return
                }

            case .optionSet(let optionSetCharacters):
                guard arguments.options.filter(shortName: optionSetCharacters[optionSetCharacters.endIndex - 1]).isEmpty else {
                    return
                }
            default:
                break
            }
        }

        for parameter in arguments.parameters {
            guard context.parameters.hasValue(for: parameter) == false else {
                continue
            }

            context.parameters.set(value: value, for: parameter)
            return
        }

        guard arguments.variadicParameter != nil else {
            throw CommandError.unexpectedArgument(value)
        }

        context.parameters.variadic.append(value)
    }

    @inline(__always)
    private func parse(optionSet characters: [Character], at index: Int, context: Context) throws {
        for (index, character) in characters.enumerated() {

            if index == characters.count - 1 {

                if let option = arguments.options.filter(shortName: character).first {

                    guard
                        let nextToken = context.arguments.token(after: index),
                        case .parameter(let optionValue) = nextToken.type else {

                        throw CommandError.missingOperand(option)
                    }

                    context.options[option] = optionValue

                } else if let flag = arguments.flags.filter(shortName: character).first {
                    context.flags.insert(flag)
                } else {
                    throw CommandError.unexpectedArgument(String(character))
                }

            } else {

                guard let flag = arguments.flags.filter(shortName: character).first else {
                    throw CommandError.unexpectedArgument(String(character))
                }

                context.flags.insert(flag)

            }

        }
    }

    @inline(__always)
    private func parse(shortOption character: Character, at index: Int, context: Context) throws {

        if let option = arguments.options.filter(shortName: character).first {

            guard
                let nextToken = context.arguments.token(after: index),
                case .parameter(let optionValue) = nextToken.type else {

                    throw CommandError.missingOperand(option)
            }

            context.options[option] = optionValue

        } else if let flag = arguments.flags.filter(shortName: character).first {
            context.flags.insert(flag)
        } else {
            throw CommandError.unexpectedArgument(String(character))
        }
    }

    @inline(__always)
    private func parse(longOption name: String, at index: Int, context: Context) throws {
        if let option = arguments.options.filter(longName: name).first {

            guard
                let nextToken = context.arguments.token(after: index),
                case .parameter(let optionValue) = nextToken.type else {

                    throw CommandError.missingOperand(option)
            }

            context.options[option] = optionValue

        } else if let flag = arguments.flags.filter(longName: name).first {
            context.flags.insert(flag)
        } else {
            throw CommandError.unexpectedArgument(name)
        }
    }
}

extension Command {

    // Prints the contextual usage string for the command
    public func contextualUsageString(for context: Context) -> String {

        var string = ""

        let indentation = "  "

        string += "NAME".bold + "\n"

        string += "\(indentation)\(context.currentCommand.name) - \(summary.dimmed)\n\n"

        if !arguments.parameters.isEmpty || !arguments.flags.isEmpty || !arguments.options.isEmpty {

            string += "USAGE".bold + "\n"

            string += "\(indentation)\(context.commands.map { $0.name }.joined(separator: " ")) " + "[options]".magenta

            for parameter in arguments.parameters {
                string += " " + "[\(parameter.name)]".blue
            }

            if let variadic = arguments.variadicParameter {
                string += " " + "[\(variadic.name)...]".blue
            }

            for parameter in arguments.parameters {
                string += "\n" + indentation + parameter.name.blue + " - " + parameter.summary.dimmed
            }

            if let variadic = arguments.variadicParameter {
                string += "\n" + indentation + variadic.name.blue + " - " + variadic.summary.dimmed
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

        if arguments.flags.isEmpty == false {

            string += "OPTIONS".bold + "\n"

            for flag in arguments.flags {

                string += "\(indentation)"

                string += flag.description

                string += "\n\(indentation)\(indentation)\(flag.summary.dimmed)\n\n"

            }

            string += "\(indentation)" + "-h, --help" + "\n\(indentation)\(indentation)" + "Show usage description".dimmed + "\n\n"

            for option in arguments.options {

                string += "\(indentation)"

                string += option.description + " <\(option.placeholder ?? "value")>"

                string += "\n\(indentation)\(indentation)\(option.summary.dimmed)\n\n"

            }

        }

        return string
    }
}

/// Error associated with commands
public enum CommandError: Error {

    /// Associated value is missing from a supplied option
    case missingOperand(Option)

    /// Expected option was not found among the arguments
    case missingOption(Option)

    /// Unexpected argument found
    case unexpectedArgument(String)

    /// Expected parameter not found
    case missingParameter(Parameter)

    /// Other errors
    case other(message: String, invalidUsage: Bool)

    /// Creates a custom CommandError
    ///
    /// - Parameters:
    ///   - message: The reason for the error
    ///   - invalidUsage: Specifies whether the error occurred due to invalid usage.
    ///                   If set to `true`, the usage of the command will be printed to stdout
    public init(message: String, invalidUsage: Bool = false) {
        self = .other(message: message, invalidUsage: invalidUsage)
    }
}

extension CommandError: CustomStringConvertible {

    public var description: String {
        switch self {

        case .missingOperand(let option):
            return "Missing operand for \(option)"

        case .missingOption(let option):
            return "Expected option \(option)"

        case .unexpectedArgument(let option):
            return "Unexpected argument \"\(option)\""

        case .missingParameter(let parameter):
            return "Missing parameter \(parameter)"

        case .other(let reason, let invalidUsage):
            guard invalidUsage else {
                return reason
            }

            return "Invalid usage: \(reason)"
        }
    }

}
