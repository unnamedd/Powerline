import Powerline

struct SimpleCommand: Command {
    let summary: String
    let arguments: Arguments
    let subcommands: [String: Command]

    let handler: (Context) throws -> Void

    func process(context: Context) throws {
        try handler(context)
    }

    init(
        summary: String = "No summary",
        arguments: Arguments = Arguments(),
        subcommands: [String: Command] = [:],
        handler: @escaping (Context) throws -> Void
        ) {

        self.summary = summary
        self.arguments = arguments
        self.subcommands = subcommands
        self.handler = handler

    }
}
