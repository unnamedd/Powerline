#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

import struct Foundation.URL

/// A command process provides access to a running process of a command, containing the parsed flags, named arguments
//  and positional arguments. It also provide access to stdout, stdin, and stderr
public struct CommandProcess {

    /// The raw arguments, passed to the process
    public let rawArguments: [String]

    /// The flags parsed from the command
    public let flags: Set<Flag>

    /// Positional arguments parsed from the command
    public let positionalArguments: PositionalArguments

    private let valuesByNamedArgument: [NamedArgument: String]

    fileprivate var context: Context

    internal init(
        rawArguments: [String],
        context: Context,
        positionalValues: [String],
        valuesByNamedArgument: [NamedArgument: String],
        flags: Set<Flag>) {

        self.rawArguments = rawArguments
        self.context = context
        self.positionalArguments = PositionalArguments(values: positionalValues)
        self.valuesByNamedArgument = valuesByNamedArgument
        self.flags = flags
    }

    /// Returns the sting value of a named argument
    ///
    /// - Parameter namedArgument: Named argument
    /// - Returns: String, or nil if the named argument was not provided
    public func string(for namedArgument: NamedArgument) -> String? {
        return valuesByNamedArgument[namedArgument]
    }

    /// Returns a named argument, converted to the inferred type
    ///
    /// - Parameter namedArgument: Named argument
    /// - Returns: Value of the inferred type, or nil if the argument was not provided
    /// - Throws: An error indicating the the conversion failed
    public func value<T: StandardInputInitializable>(forNamedArgument namedArgument: NamedArgument) throws -> T? {
        guard let string = valuesByNamedArgument[namedArgument] else {
            return nil
        }

        return T(string: string)
    }

    /// Returns a named argument, converted to the inferred type
    ///
    /// - Parameter namedArgument: Named argument
    /// - Returns: Value of the inferred type
    /// - Throws: An error indicating the the conversion failed **or**, if the named argument was not provided
    public func value<T: StandardInputInitializable>(forNamedArgument namedArgument: NamedArgument) throws -> T {
        guard let value: T = try value(forNamedArgument: namedArgument) else {
            throw CommandError.missingNamedArgument(namedArgument)
        }

        return value
    }
}

extension CommandProcess {

    /// Runs a shell command synchronously
    ///
    /// - Parameters:
    ///   - executable: Executable to run
    ///   - arguments: Arguments passed to the executable
    /// - Returns: A `ProcessResult` struct, containing the stdout and stderr of the runned proccess
    /// - Throws: An error indicating that thehe process exited with a non-zero value, or if the executable
    ///           wasn't found or is invalid
    @discardableResult
    public func run(executable: String, arguments: [String] = []) throws -> ProcessResult {
        let runner = try ProcessRunner(context: context, executable: executable, arguments: arguments)
        return try runner.run()
    }

    /// Runs a shell command synchronously
    ///
    /// - Parameters:
    ///   - string: Executable and arguments to be passed, separated by whitespace
    /// - Returns: A `ProcessResult` struct, containing the stdout and stderr of the runned proccess
    /// - Throws: An error indicating that thehe process exited with a non-zero value, or if the executable 
    ///           wasn't found or is invalid
    @discardableResult
    public func run(_ string: String) throws -> ProcessResult {
        let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
        var components = string.components(separatedBy: " ").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        guard components.count > 1 else {
            return try run(executable: string)
        }

        let executable = components.removeFirst()

        return try run(executable: executable, arguments: components)
    }
}

extension CommandProcess {

    /// Runs a shell command asynchronously
    ///
    /// - Parameters:
    ///   - executable: Executable to run
    ///   - arguments: Arguments passed to the executable
    ///   - completion: Completion handler
    ///   - error: Error, if any
    ///   - result: A `ProcessResult` struct, containing the stdout and stderr of the runned proccess
    ///             or nil, if an error occurred
    /// - Returns: A `ProcessHandler` struct, allowing you to suspend, terminate, and resume the process
    /// - Throws: An error indicating that the executable wasn't found or is invalid
    @discardableResult
    public func run(executable: String, arguments: [String] = [], completion: @escaping (_ error: ProcessError?, _ result: ProcessResult?) -> Void) throws -> ProcessHandler {
        let runner = try ProcessRunner(context: context, executable: executable, arguments: arguments)

        return try runner.run(completion: completion)
    }

    /// Runs a shell command asynchronously
    ///
    /// - Parameters:
    ///   - string: Executable and arguments to be passed, separated by whitespace
    ///   - completion: Completion handler
    ///   - error: Error, if any
    ///   - result: A `ProcessResult` struct, containing the stdout and stderr of the runned proccess
    ///             or nil, if an error occurred
    /// - Returns: A `ProcessHandler` struct, allowing you to suspend, terminate, and resume the process
    /// - Throws: An error indicating that the executable wasn't found or is invalid
    @discardableResult
    public func run(_ string: String, completion: @escaping (_ error: ProcessError?, _ result: ProcessResult?) -> Void) throws -> ProcessHandler {
        let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
        var components = string.components(separatedBy: " ")

        guard components.count > 1 else {
            return try run(executable: string, completion: completion)
        }

        let executable = components.removeFirst()

        return try run(executable: executable, arguments: components, completion: completion)
    }
}

extension CommandProcess {
    /// Returns the shell environment
    public var environment: [String: String] {
        return context.environment
    }

    /// The current directory of the process
    public var currentDirectory: String {
        get {
            return context.currentDirectory
        }
        set {
            context.currentDirectory = newValue
        }
    }
    /// The current directory url of the process
    public var urlForCurrentDirectory: URL? {
        get {
            return URL(string: currentDirectory)
        }
        set {
            guard let newValue = newValue else {
                error("Cannot set current URL to nil value")
                return
            }
            currentDirectory = newValue.path
        }
    }

    /// Prints a message to `stdout`
    ///
    /// - Parameters:
    ///   - items: Items being described, and written to `stdout`
    ///   - separator: String separating the items
    ///   - terminator: String, appended to the end of the output
    public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let string = items.map { String(describing: $0) }.joined(separator: separator)
        context.standardOutput.write(string, terminator: terminator)
    }

    /// Prints a message to `stderr`
    ///
    /// - Parameters:
    ///   - items: Items being described, and written to `stderr`
    ///   - separator: String separating the items
    ///   - terminator: String, appended to the end of the output
    public func error(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let string = items.map { String(describing: $0) }.joined(separator: separator)
        context.standardError.write(string, terminator: terminator)
    }
}

extension CommandProcess {
    /// A collection of positional arguments
    public struct PositionalArguments {
        fileprivate let values: [String]

        fileprivate init(values: [String]) {
            self.values = values
        }
    }
}

extension CommandProcess {
    /// Reads the input from stdin
    ///
    /// - Returns: A string, or nil if the input is empty
    public func readInput() -> String? {
        guard let input = context.standardInput.read()?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }
        return input.isEmpty ? nil : input
    }

    public func read<T: StandardInputInitializable>(message: String) -> T {
        print("\(message): ".bold.magenta, terminator: " ")

        while true {
            guard let input = readInput() else {
                print("Please try again:".yellow, terminator: " ")
                continue
            }

            guard let value = T(string: input) else {
                print("Failed to convert input to \(String(describing: T.self)) Please try again:".yellow, terminator: " ")
                continue
            }

            return value
        }
    }

    /// Prompts the user to type either `y` or `n`.
    ///
    /// - Parameter message: A message to provide
    /// - Returns: `true` if the input was `y`, `false` if the input was `n`.
    public func confirm(_ message: String) -> Bool {
        print(message.bold.magenta, "[y/N]", terminator: " ")

        while true {
            let input = readInput()?.lowercased() ?? ""

            switch input {
            case "y":
                return true
            case "n":
                return false
            default:
                print("Please enter yes or no. [y/N]:".yellow, terminator: " ")
            }
        }
    }

    /// Prompts the user to select one of several values
    ///
    /// - Parameters:
    ///   - options: An array of strings representing the selectable values
    ///   - defaultValue: Optional default value. Does not have to be contained in the original options
    ///   - message: A message to provide
    /// - Returns: The selected value or default value, if provided
    public func select(_ options: [String], default defaultValue: String? = nil, message: String) -> String {
        print(message.bold.magenta)
        for (i, option) in options.enumerated() {
            if let defaultValue = defaultValue, i == options.index(of: defaultValue) {
                print("\(i + 1))".blue.bold, option, "(Default)".dimmed)
            } else {
                print("\(i + 1))".blue, option)
            }
        }

        if let defaultValue = defaultValue {
            print("Select an option. Press ENTER for default value (\(defaultValue.italic)):".blue, terminator: " ")
        } else {
            print("Select an option:".blue, terminator: " ")
        }

        while true {
            guard let input = readInput() else {
                guard let defaultValue = defaultValue else {
                    print("You have to select an option:".yellow, terminator: " ")
                    continue
                }

                return defaultValue
            }

            guard let index = Int(input), (options.startIndex ..< options.endIndex).contains(index - 1) else {
                if let defaultValue = defaultValue {
                    print("Please select an option between \(options.startIndex + 1) and \(options.endIndex), or press ENTER for default value (\(defaultValue.italic)):".yellow, terminator: " ")
                } else {
                    print("Please select an option between \(options.startIndex + 1) and \(options.endIndex):".yellow, terminator: " ")
                }
                continue
            }

            return options[index - 1]
        }
    }
}

extension CommandProcess.PositionalArguments: Collection {

    public subscript(position: Int) -> String {
        return values[position]
    }

    /// Returns a value at a given index in the collection, converted to the inferred type
    ///
    /// - Parameter index: Index in collection
    /// - Returns: A value of the inferred type
    /// - Throws: An error indicating that the type conversion failed
    public func value<T: StandardInputInitializable>(at index: Int) throws -> T? {
        return T(string: self[index])
    }

    public var count: Int {
        return values.count
    }

    public var startIndex: Int {
        return values.startIndex
    }

    public var endIndex: Int {
        return values.endIndex
    }

    public func index(after i: Int) -> Int {
        return values.index(after: i)
    }
}
