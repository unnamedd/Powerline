import Futures

// MARK: - Synchronous process execution

public extension Context {

    func run(executable: String, arguments: [String] = []) -> Future<ProcessResult> {
        return promise {
            return try ProcessRunner(context: self, executable: executable, arguments: arguments)
        }.then { runner in
            runner.run()
        }
    }
}
