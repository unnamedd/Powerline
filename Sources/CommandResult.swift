public extension Command {
    public struct Result {
        public let flags: Set<Flag>
        private let positional: [String]
        private let valuesByNamedArgument: [NamedArgument: String]

        internal static var empty: Command.Result {
            return .init(positionalValues: [], valuesByNamedArgument: [:], flags: [])
        }

        internal init(
            positionalValues: [String],
            valuesByNamedArgument: [NamedArgument: String],
            flags: Set<Flag>) {

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
