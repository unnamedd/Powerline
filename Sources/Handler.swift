public extension Command {
    public struct Handler {
        public let flags: Set<Flag>
        private let positional: [String]
        private let valuesByNamedArgument: [NamedArgument: String]

        fileprivate var context: Context

        internal init(
            context: Context,
            positionalValues: [String],
            valuesByNamedArgument: [NamedArgument: String],
            flags: Set<Flag>) {

            self.context = context
            self.positional = positionalValues
            self.valuesByNamedArgument = valuesByNamedArgument
            self.flags = flags
        }

        public func positionalValues<T: StringConvertible>() throws -> [T] {
            return try positional.map {
                try T(string: $0)
            }
        }

        public func string(for namedArgument: NamedArgument) -> String? {
            return valuesByNamedArgument[namedArgument]
        }

        public func value<T: StringConvertible>(for namedArgument: NamedArgument) throws -> T? {
            guard let string = valuesByNamedArgument[namedArgument] else {
                return nil
            }

            return try? T(string: string)
        }

        public func value<T: StringConvertible>(for namedArgument: NamedArgument) throws -> T {
            guard let value: T = try value(for: namedArgument) else {
                throw CommandError.missingNamedArgument(namedArgument)
            }

            return value
        }
    }
}

extension Command.Handler {
    public func cmd(executable: String, arguments: [String] = []) throws -> ProcessResult {
        let runner = try ProcessRunner(context: context, executable: executable, arguments: arguments)
        return try runner.run()
    }

    public func cmd(_ string: String) throws -> ProcessResult {

        var components = string.components(separatedBy: " ")

        guard components.count > 1 else {
            return try cmd(executable: string)
        }

        let executable = components.removeFirst()

        return try cmd(executable: executable, arguments: components)
    }
}

extension Command.Handler {
    public func cmd(executable: String, arguments: [String] = [], completion: @escaping (_ error: ProcessError?, _ result: ProcessResult?) -> Void) throws -> ProcessHandler {
        let runner = try ProcessRunner(context: context, executable: executable, arguments: arguments)

        return try runner.run(completion: completion)
    }

    public func cmd(_ string: String, completion: @escaping (_ error: ProcessError?, _ result: ProcessResult?) -> Void) throws -> ProcessHandler {
        var components = string.components(separatedBy: " ")

        guard components.count > 1 else {
            return try cmd(executable: string, completion: completion)
        }

        let executable = components.removeFirst()

        return try cmd(executable: executable, arguments: components, completion: completion)
    }
}

extension Command.Handler {
    public var environment: [String: String] {
        return context.environment
    }

    public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let string = items.map { String(describing: $0) }.joined(separator: separator)
        context.standardOutput.write(string, terminator: terminator)

    }
}
