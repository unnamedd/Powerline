//
//  ExampleCommand.swift
//  PowerlineTests
//
//  Created by David Ask on 2017-09-18.
//

import Foundation
import Powerline

extension Flag {
    static let verbose = Flag(
        longName: "verbose",
        shortName: "v",
        summary: "Print verbose output"
    )
}

extension Option {
    static let count = Option(
        longName: "count",
        shortName: "n",
        summary: "Repeat n times"
    )
}

extension Parameter {
    static let message = Parameter(
        name: "Message",
        summary: "Message to print"
    )
}

struct ExampleCommand : Command {

    let summary: String = "A sample command that prints a message"

    // Define the arguments that the command accepts
    let arguments = Arguments(
        flags: [.verbose],
        options: [.count],
        parameters: [.message]
    )

    // Process the command.
    // `Context` contains information about the process, such as tokenized
    // arguments and more
    func process(context: Context) throws {

        let message: String

        // If the message is provided as an argument, use it
        if let provided: String = try context.parameters.value(for: .message) {
            message = provided
        } else {
            // Otherwise, ask the user to provide a message
            message = context.read(message: "What do you want to print out?")
        }

        // Read the count option, or default to 1
        let count: Int = try context.value(for: .count) ?? 1

        if count > 10 {
            // Prompt a user to print a message more than 10 times
            guard context.confirm("Print \"\(message)\" \(count) times?") else {
                context.print("Aborting".red)
                return
            }
        }

        for i in 0 ..< count {
            // Print verbos output
            if context.flags.contains(.verbose) {
                context.print("Printing message number \(i + 1)...".darkGray)
            }
            context.print(message.green)
        }
    }
}
