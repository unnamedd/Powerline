#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

public extension Command {

    /// A command result contains the parsed flags, named arguments and positional arguments
    //  and provide access to stdout, stdin, and stderr
    public struct Result {

        /// The flags parsed from the command
        public let flags: Set<Flag>

        /// Positional arguments parsed from the command
        public let positionalArguments: PositionalArguments

        private let valuesByNamedArgument: [NamedArgument: String]

        fileprivate var context: Context

        internal init(
            context: Context,
            positionalValues: [String],
            valuesByNamedArgument: [NamedArgument: String],
            flags: Set<Flag>) {

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
        public func value<T: StringInitializable>(for namedArgument: NamedArgument) throws -> T? {
            guard let string = valuesByNamedArgument[namedArgument] else {
                return nil
            }

            return try? T(string: string)
        }

        /// Returns a named argument, converted to the inferred type
        ///
        /// - Parameter namedArgument: Named argument
        /// - Returns: Value of the inferred type
        /// - Throws: An error indicating the the conversion failed **or**, if the named argument was not provided
        public func value<T: StringInitializable>(for namedArgument: NamedArgument) throws -> T {
            guard let value: T = try value(for: namedArgument) else {
                throw CommandError.missingNamedArgument(namedArgument)
            }

            return value
        }
    }
}

extension Command.Result {

    /// Runs a shell command synchronously
    ///
    /// - Parameters:
    ///   - executable: Executable to run
    ///   - arguments: Arguments passed to the executable
    /// - Returns: A `ProcessResult` struct, containing the stdout and stderr of the runned proccess
    /// - Throws: An error indicating that thehe process exited with a non-zero value, or if the executable
    ///           wasn't found or is invalid
    @discardableResult
    public func cmd(executable: String, arguments: [String] = []) throws -> ProcessResult {
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
    public func cmd(_ string: String) throws -> ProcessResult {
        let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
        var components = string.components(separatedBy: " ").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        guard components.count > 1 else {
            return try cmd(executable: string)
        }

        let executable = components.removeFirst()

        return try cmd(executable: executable, arguments: components)
    }
}

extension Command.Result {

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
    public func cmd(executable: String, arguments: [String] = [], completion: @escaping (_ error: ProcessError?, _ result: ProcessResult?) -> Void) throws -> ProcessHandler {
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
    public func cmd(_ string: String, completion: @escaping (_ error: ProcessError?, _ result: ProcessResult?) -> Void) throws -> ProcessHandler {
        let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
        var components = string.components(separatedBy: " ")

        guard components.count > 1 else {
            return try cmd(executable: string, completion: completion)
        }

        let executable = components.removeFirst()

        return try cmd(executable: executable, arguments: components, completion: completion)
    }
}

extension Command.Result {
    public var environment: [String: String] {
        return context.environment
    }

    public func stdout(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let string = items.map { String(describing: $0) }.joined(separator: separator)
        context.standardOutput.write(string, terminator: terminator)
    }

    public func stderr(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let string = items.map { String(describing: $0) }.joined(separator: separator)
        context.standardError.write(string, terminator: terminator)
    }
}

extension Command.Result {
    /// A collection of positional arguments
    public struct PositionalArguments {
        fileprivate let values: [String]

        fileprivate init(values: [String]) {
            self.values = values
        }
    }
}

extension Command.Result.PositionalArguments: Collection {

    public subscript(position: Int) -> String {
        return values[position]
    }

    /// Returns a value at a given index in the collection, converted to the inferred type
    ///
    /// - Parameter index: Index in collection
    /// - Returns: A value of the inferred type
    /// - Throws: An error indicating that the type conversion failed
    public func value<T: StringInitializable>(at index: Int) throws -> T {
        return try T(string: self[index])
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
