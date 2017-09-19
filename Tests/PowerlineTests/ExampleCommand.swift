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

    let arguments = Arguments(
        flags: [.verbose],
        options: [.count],
        parameters: [.message]
    )

    func process(context: Context) throws {

        let message: String

        if let provided: String = try context.parameters.value(for: .message) {
            message = provided
        } else {
            message = context.read(message: "What do you want to print out?")
        }

        let count: Int = try context.value(for: .count) ?? 0

        if count > 10 {
            // Prompt a user
            guard context.confirm("Are you sure you want to print \"\(message)\" \(count) times") else {
                context.print("Aborting".red)
                return
            }
        }

        for i in 0 ..< count {
            if context.flags.contains(.verbose) {
                context.print("Printing message number \(i + 1)...".darkGray)
            }
            context.print(message.green)
        }
    }
}
