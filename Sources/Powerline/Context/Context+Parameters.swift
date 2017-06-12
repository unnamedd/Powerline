extension Context {

    /// Contains both variadic and non-variadic parameters passed to the context
    public struct Parameters {

        internal var parameters: [Parameter: String] = [:]
        internal var variadic: [String] = []

        internal init() {}

        mutating internal func set(value: String, for parameter: Parameter) {
            self.parameters[parameter] = value
        }

        /// Indicates whether a value for specified parameter exists
        ///
        /// - Parameter parameter: Parameter to assert
        /// - Returns: `true` if a value exists for the specified parameter, otherwise `false`
        public func hasValue(for parameter: Parameter) -> Bool {
            return parameters.keys.contains(parameter)
        }

        /// Returns an optional value for given `Parameter`
        ///
        /// - Parameter parameter: Parameter for associated value
        /// - Returns: The value converted to the inferred type, or nil, if the value was not found
        /// - Throws: `StandardInputInitializableError.failedConversion` if a value was found, but conversion to
        /// inferred type failed
        public func value<T: StandardInputInitializable>(for parameter: Parameter) throws -> T? {
            guard let string = parameters[parameter] else {
                return nil
            }

            guard let value = T(input: string) else {
                throw StandardInputInitializableError.failedConversion(of: string, to: T.self)
            }

            return value
        }

        /// Returns a value for given `Parameter`, throwing an error if the value was not found
        ///
        /// - Parameter parameter: Parameter for associated value
        /// - Returns: The value converted to the inferred type
        /// - Throws: `StandardInputInitializableError.failedConversion` if a value was found, but conversion to, or
        /// `CommandError.missingParameter` if the value was not found
        public func value<T: StandardInputInitializable>(for parameter: Parameter) throws -> T {
            guard let nonNilValue: T = try self.value(for: parameter) else {
                throw CommandError.missingParameter(parameter)
            }

            return nonNilValue
        }

        /// Returns a variadic value at specified index
        ///
        /// - Parameter index: Index of variadic value
        /// - Returns: The value converted to the inferred type
        /// - Throws: `StandardInputInitializableError.failedConversion` if conversion to
        /// inferred type failed
        public func variadicValue<T: StandardInputInitializable>(at index: Int) throws -> T {
            guard let value = T(input: variadic[index]) else {
                throw StandardInputInitializableError.failedConversion(of: variadic[index], to: T.self)
            }

            return value
        }

        /// Returns an an array of values for the variadic parameter
        ///
        /// - Returns: An array of values for the variadic parameter
        /// - Throws: `StandardInputInitializableError.failedConversion` if conversion to
        /// inferred type failed
        public func variadicValues<T: StandardInputInitializable>() throws -> [T] {
            return try variadic.indices.map { try self.variadicValue(at: $0) }
        }

        /// Count of variadic parameter values
        public var variadicCount: Int {
            return variadic.count
        }

        /// Indicates whether the parameters has variadic values
        public var hasVariadicParameters: Bool {
            return variadicCount > 0
        }
    }
}

extension Context {

    /// Returns an optional string value for specified `Option`
    ///
    /// - Parameter option: `Option`
    /// - Returns: `String`, or `nil` if the option is not present in the context
    public func string(for option: Option) -> String? {
        return options[option]
    }

    /// Returns an optional value for given `Option`
    ///
    /// - Parameter option: Option for associated value
    /// - Returns: The value converted to the inferred type, or nil, if the value was not found
    /// - Throws: `StandardInputInitializableError.failedConversion` if a value was found, but conversion to
    /// inferred type failed
    public func value<T: StandardInputInitializable>(for option: Option) throws -> T? {
        guard let string = options[option] else {
            return nil
        }

        guard let value = T(input: string) else {
            throw StandardInputInitializableError.failedConversion(of: string, to: T.self)
        }

        return value
    }

    /// Returns a value for given `Option`, throwing an error if the value was not found
    ///
    /// - Parameter option: Option for associated value
    /// - Returns: The value converted to the inferred type
    /// - Throws: `StandardInputInitializableError.failedConversion` if a value was found, but conversion to, or
    /// `CommandError.missingParameter` if the value was not found
    public func value<T: StandardInputInitializable>(for option: Option) throws -> T {
        guard let value: T = try value(for: option) else {
            throw CommandError.missingOption(option)
        }

        return value
    }
}
