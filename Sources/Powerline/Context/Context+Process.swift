// MARK: - Synchronous process execution

extension Context {

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
        let runner = try ProcessRunner(context: self, executable: executable, arguments: arguments)
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

// MARK: - Asynchronous process execution

extension Context {

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
        let runner = try ProcessRunner(context: self, executable: executable, arguments: arguments)

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
