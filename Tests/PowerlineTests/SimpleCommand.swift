import Powerline

struct SimpleCommand: Command {
    let summary: String
    let positionalArgument: PositionalArgument?
    let flags: Set<Flag>
    let namedArguments: Set<NamedArgument>
    let subcommands: [String : Command]

    let handler: (CommandProcess) throws -> Void

    func run(process: CommandProcess) throws {
        try handler(process)
    }

    init(
        summary: String = "No summary",
        positionalArgument: PositionalArgument? = nil,
        flags: Set<Flag> = [],
        namedArguments: Set<NamedArgument> = [],
        subcommands: [String: Command] = [:],
        handler: @escaping (CommandProcess) throws -> Void
        ) {

        self.summary = summary
        self.positionalArgument = positionalArgument
        self.flags = flags
        self.namedArguments = namedArguments
        self.subcommands = subcommands
        self.handler = handler
    }
}
