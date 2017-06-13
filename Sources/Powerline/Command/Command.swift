#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

public protocol Command {

    var summary: String { get }

    var flags: Set<Flag> { get }

    var options: Set<Option> { get }

    var parameters: [Parameter] { get }

    var variadicParameter: Parameter? { get }

    var subcommands: [String: Command] { get }

    func process(context: Context) throws
}

extension Command {

    public var flags: Set<Flag> {
        return []
    }

    public var options: Set<Option> {
        return []
    }

    public var subcommands: [String: Command] {
        return [:]
    }

    public var parameters: [Parameter] {
        return []
    }

    public var variadicParameter: Parameter? {
        return nil
    }

    public func process(context: Context) throws {
        context.print(usageString(context: context))
    }
}

extension Command {

    public func run(arguments: [String] = CommandLine.arguments) throws {

        guard let arguments = Arguments(arguments: arguments) else {
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
                context.print(usageString(context: context))
            }

        } catch {
            throw error
        }
    }

    private func run(context: Context) throws {

        // Loop through all arguments in the context
        for component in context.arguments.components {

            if let parameter = component as? Arguments.Parameter, component.index > context.currentCommand.argumentIndex {

                if component.index == context.currentCommand.argumentIndex + 1, let subcommand = subcommands[parameter.value] {
                    context.commands.append((name: parameter.value, argumentIndex: parameter.index))
                    try subcommand.run(context: context)
                    return

                } else {
                    try parse(component: parameter, context: context)
                }

            } else if let long = component as? Arguments.LongOption {

                if long.name == "help" {
                    context.print(usageString(context: context))
                    exit(EXIT_SUCCESS)
                }

                try parse(component: long, context: context)

            } else if let short = component as? Arguments.ShortOption {

                if short.character == "h" {
                    context.print(usageString(context: context))
                    exit(EXIT_SUCCESS)
                }

                try parse(component: short, context: context)

            } else if let optionSet = component as? Arguments.OptionSet {

                try parse(component: optionSet, context: context)
            }

        }

        try process(context: context)

    }

    @inline(__always)
    private func parse(component: Arguments.Parameter, context: Context) throws {

        if let longArgument = context.arguments.component(before: component) as? Arguments.LongOption {
            guard options.filter(longName: longArgument.name).isEmpty else {
                return
            }
        } else if let shortArgument = context.arguments.component(before: component) as? Arguments.ShortOption {
            guard options.filter(shortName: shortArgument.character).isEmpty else {
                return
            }
        } else if let optionSet = context.arguments.component(before: component) as? Arguments.OptionSet {
            guard options.filter(shortName: optionSet.characters[optionSet.characters.endIndex - 1]).isEmpty else {
                return
            }
        }

        for parameter in parameters {
            guard context.parameters.hasValue(for: parameter) == false else {
                continue
            }

            context.parameters.set(value: component.value, for: parameter)
            return
        }

        guard variadicParameter != nil else {
            throw CommandError.unexpectedArgument(component.value)
        }

        context.parameters.variadic.append(component.value)
    }

    @inline(__always)
    private func parse(component: Arguments.OptionSet, context: Context) throws {
        for (i, character) in component.characters.enumerated() {

            if i == component.characters.count - 1 {

                if let option = options.filter(shortName: character).first {

                    guard let argument = context.arguments.component(after: component) as? Arguments.Parameter else {
                        throw CommandError.missingOperand(option)
                    }

                    context.options[option] = argument.value

                } else if let flag = flags.filter(shortName: character).first {
                    context.flags.insert(flag)
                } else {
                    throw CommandError.unexpectedArgument(String(character))
                }

            } else {

                guard let flag = flags.filter(shortName: character).first else {
                    throw CommandError.unexpectedArgument(String(character))
                }

                context.flags.insert(flag)

            }

        }
    }

    @inline(__always)
    private func parse(component: Arguments.ShortOption, context: Context) throws {

        if let option = options.filter(shortName: component.character).first {

            guard let argument = context.arguments.component(after: component) as? Arguments.Parameter else {
                throw CommandError.missingOperand(option)
            }

            context.options[option] = argument.value

        } else if let flag = flags.filter(shortName: component.character).first {
            context.flags.insert(flag)
        } else {
            throw CommandError.unexpectedArgument(String(component.character))
        }
    }

    @inline(__always)
    private func parse(component: Arguments.LongOption, context: Context) throws {
        if let option = options.filter(longName: component.name).first {
            guard let argument = context.arguments.component(after: component) as? Arguments.Parameter else {
                throw CommandError.missingOperand(option)
            }

            context.options[option] = argument.value

        } else if let flag = flags.filter(longName: component.name).first {
            context.flags.insert(flag)
        } else {
            throw CommandError.unexpectedArgument(component.name)
        }
    }
}

extension Command {
    internal func usageString(context: Context) -> String {

        var string = ""

        let indentation = "  "

        string += "NAME".bold + "\n"

        string += "\(indentation)\(context.currentCommand.name) - \(summary.dimmed)\n\n"

        if !parameters.isEmpty || !flags.isEmpty || !options.isEmpty {

            string += "USAGE".bold + "\n"

            string += "\(indentation)\(context.commands.map { $0.name }.joined(separator: " ")) " + "[options]".magenta

            for parameter in parameters {
                string += " " + "[\(parameter.name)]".blue
            }

            if let variadic = variadicParameter {
                string += " " + "[\(variadic.name)...]".blue
            }

            for parameter in parameters {
                string += "\n" + indentation + parameter.name.blue + " - " + parameter.summary.dimmed
            }

            if let variadic = variadicParameter {
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

        if flags.isEmpty == false {

            string += "OPTIONS".bold + "\n"

            for flag in flags {

                string += "\(indentation)"

                string += flag.description

                string += "\n\(indentation)\(indentation)\(flag.summary.dimmed)\n\n"

            }

            string += "\(indentation)" + "-h, --help" + "\n\(indentation)\(indentation)" + "Show usage description".dimmed + "\n\n"

            for option in options {

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

extension CommandError : CustomStringConvertible {

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
