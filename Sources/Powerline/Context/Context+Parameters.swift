extension Context {
    public struct Parameters {

        internal var parameters: [Parameter: String] = [:]
        internal var variadic: [String] = []

        internal init() {}

        mutating internal func set(value: String, for parameter: Parameter) {
            self.parameters[parameter] = value
        }

        internal func hasValue(for parameter: Parameter) -> Bool {
            return parameters.keys.contains(parameter)
        }

        public func value<T: StandardInputInitializable>(for parameter: Parameter) throws -> T? {
            guard let string = parameters[parameter] else {
                return nil
            }

            guard let value = T(input: string) else {
                throw StandardInputInitializableError.failedConversion(of: string, to: T.self)
            }

            return value
        }

        public func value<T: StandardInputInitializable>(for parameter: Parameter) throws -> T {
            guard let nonNilValue: T = try self.value(for: parameter) else {
                throw CommandError.missingParameter(parameter)
            }

            return nonNilValue
        }

        public func variadicValue<T: StandardInputInitializable>(at index: Int) throws -> T {
            guard let value = T(input: variadic[index]) else {
                throw StandardInputInitializableError.failedConversion(of: variadic[index], to: T.self)
            }

            return value
        }

        public func variadicValues<T: StandardInputInitializable>() throws -> [T] {
            return try variadic.indices.map { try self.variadicValue(at: $0) }
        }

        public var variadicCount: Int {
            return variadic.count
        }

        public var hasVariadicParameters: Bool {
            return variadicCount > 0
        }
    }
}

extension Context {

    public func string(for option: Option) -> String? {
        return options[option]
    }

    public func value<T: StandardInputInitializable>(for option: Option) throws -> T? {
        guard let string = options[option] else {
            return nil
        }

        guard let value = T(input: string) else {
            throw StandardInputInitializableError.failedConversion(of: string, to: T.self)
        }

        return value
    }

    public func value<T: StandardInputInitializable>(for option: Option) throws -> T {
        guard let value: T = try value(for: option) else {
            throw CommandError.missingOption(option)
        }

        return value
    }
}
