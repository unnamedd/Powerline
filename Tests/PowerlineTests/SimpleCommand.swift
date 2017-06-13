import Powerline

struct SimpleCommand: Command {
    let summary: String
    let parameters: [Parameter]
    let variadicParameter: Parameter?
    let flags: Set<Flag>
    let options: Set<Option>
    let subcommands: [String : Command]

    let handler: (Context) throws -> Void

    func process(context: Context) throws {
        try handler(context)
    }

    init(
        summary: String = "No summary",
        parameters: [Parameter] = [],
        variadicParameter: Parameter? = nil,
        flags: Set<Flag> = [],
        options: Set<Option> = [],
        subcommands: [String: Command] = [:],
        handler: @escaping (Context) throws -> Void
        ) {

        self.summary = summary
        self.flags = flags
        self.parameters = parameters
        self.variadicParameter = variadicParameter
        self.subcommands = subcommands
        self.handler = handler
        self.options = options
    }
}
