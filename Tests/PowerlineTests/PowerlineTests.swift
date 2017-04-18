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
            print(CommandLine.arguments)

            //try Command.greet.run(arguments: ["greet", "David", "John", "Adam", "Paulo", "--say-goodbye", "-g", "\"Welcome to Powerline!\""])
            Command.filePrinter.runOrExit(arguments: ["example", "--output", "file.txt", "log1.log", "log2.log", "-v"])
        } catch {
            XCTFail("\(error)")
        }
    }
}

extension Command {
    static let filePrinter = Command(
        name: "filePrinter",
        summary: "Prints the contents of files",
        positionalArgument: .files,
        namedArguments: [.output],
        flags: [.verbose]
    )

    static func handleCommand(result: Command.Result) throws {
        if let value: String = try result.value(for: .output) {
            print("OUTPUT TO:", value)
        }

        let strings: [String] = try result.positionalValues()

        print(strings)

        if result.flags.contains(.verbose) {
            print("VERBOSE")
        }
    }
}

extension Flag {

    static let verbose = Flag(
        name: "verbose", 					// --verbose
        character: "v", 					// -v
        summary: "Prints debug output" 		// Printed out in help
    )
}

extension NamedArgument {

    static let output = NamedArgument(
        name: "output", 				// --output <file>
        character: "o",					// -o <file>
        summary: "File to write to",	// Printed out in help
        valuePlaceholder: "file"		// Placeholder for value printed out in help
    )
}

extension PositionalArgument {

    static let files = PositionalArgument(
        name: "file", 					// Printed out in help
        summary: "A file to process",	// Printed out in help
        variadic: true					// Whether multiple values are supported
    )
}
