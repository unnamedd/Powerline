import XCTest
@testable import Powerline

class PowerlineTests: XCTestCase {

    static var allTests: [(String, (PowerlineTests) -> () throws -> Void)] {
        return [
            ("testGreeting", testGreeting),
        ]
    }

    func testGreeting() {
        do {
            //try Command.greet.run(arguments: ["greet", "David", "John", "Adam", "Paulo", "--say-goodbye", "-g", "\"Welcome to Powerline!\""])
            Command.greet.runOrExit(arguments: ["greet", "David"])
        } catch {
            XCTFail("\(error)")
        }
    }
}

extension Command {
    static let greet = Command(
        name: "greet",
        summary: "Greets someone",
        subcommands: [
            Command(name: "test", summary: "Tests", handler: { (_) in

            })
        ],
        positionalArgument: PositionalArgument(name: "name", summary: "The name of the person to greet", variadic: true),
        namedArguments: [.greeting],
        flags: [.goodbye]) { result in

            var names: [String] = try result.positionalValues()

            if names.count > 1 {
                names.append("and \(names.remove(at: names.count - 1))")
            }

            print("Hello \(names.joined(separator: ", "))!\n")
            

            if let message: String = try result.value(for: .greeting) {
                print(message)
            }

            if result.flags.contains(.goodbye) {
                print("Good bye!")
            }

    }
}

extension Flag {

    static let goodbye = Flag(name: "say-goodbye", character: "G", summary: "Also says goodbye")
}

extension NamedArgument {
    static let greeting = NamedArgument(name: "greeting", character: "g", summary: "The greeting to print out", valuePlaceholder: "msg")
}
