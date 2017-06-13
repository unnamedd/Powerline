extension Context {
    /// Prints a message to `stdout`
    ///
    /// - Parameters:
    ///   - items: Items being described, and written to `stdout`
    ///   - separator: String separating the items
    ///   - terminator: String, appended to the end of the output
    public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let string = items.map { String(describing: $0) }.joined(separator: separator)
        standardOutput.write(string, terminator: terminator)
    }

    /// Prints a message to `stderr`
    ///
    /// - Parameters:
    ///   - items: Items being described, and written to `stderr`
    ///   - separator: String separating the items
    ///   - terminator: String, appended to the end of the output
    public func error(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let string = items.map { String(describing: $0) }.joined(separator: separator)
        standardError.write(string, terminator: terminator)
    }
}
