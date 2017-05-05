#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

public extension Command {
    public struct Result {
        public let flags: Set<Flag>
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

        public func string(for namedArgument: NamedArgument) -> String? {
            return valuesByNamedArgument[namedArgument]
        }

        public func value<T: StringInitializable>(for namedArgument: NamedArgument) throws -> T? {
            guard let string = valuesByNamedArgument[namedArgument] else {
                return nil
            }

            return try? T(string: string)
        }

        public func value<T: StringInitializable>(for namedArgument: NamedArgument) throws -> T {
            guard let value: T = try value(for: namedArgument) else {
                throw CommandError.missingNamedArgument(namedArgument)
            }

            return value
        }
    }
}

extension Command.Result {
    public func cmd(executable: String, arguments: [String] = []) throws -> ProcessResult {
        let runner = try ProcessRunner(context: context, executable: executable, arguments: arguments)
        return try runner.run()
    }

    public func cmd(_ string: String) throws -> ProcessResult {
        let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
        var components = string.components(separatedBy: " ")

        guard components.count > 1 else {
            return try cmd(executable: string)
        }

        let executable = components.removeFirst()

        return try cmd(executable: executable, arguments: components)
    }
}

extension Command.Result {
    @discardableResult
    public func cmd(executable: String, arguments: [String] = [], completion: @escaping (_ error: ProcessError?, _ result: ProcessResult?) -> Void) throws -> ProcessHandler {
        let runner = try ProcessRunner(context: context, executable: executable, arguments: arguments)

        return try runner.run(completion: completion)
    }

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
