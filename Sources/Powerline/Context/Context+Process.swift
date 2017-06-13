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
    ///   - executable: Executable to run
    ///   - arguments: Arguments passed to the executable
    /// - Returns: A `ProcessResult` struct, containing the stdout and stderr of the runned proccess
    /// - Throws: An error indicating that thehe process exited with a non-zero value, or if the executable
    ///           wasn't found or is invalid
    @discardableResult
    public func run(executable: String, arguments: String...) throws -> ProcessResult {
        return try run(executable: executable, arguments: arguments)
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
