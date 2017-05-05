import XCTest
@testable import Powerline

class PowerlineTests: XCTestCase {

    static var allTests: [(String, (PowerlineTests) -> () throws -> Void)] {
        return [
            ("testVariadicGreetingWithOptionsAndOutput", testVariadicGreetingWithOptionsAndOutput),
            ("testCompoundFlagLastArgument", testCompoundFlagLastArgument),
            ("testCmdAsync", testCmdAsync),
            ("testCmd", testCmd),
        ]
    }

    func testVariadicGreetingWithOptionsAndOutput() throws {
        print(CommandLine.arguments)


        try Command.filePrinter.run(arguments: ["example", "--output", "file.txt", "log1.log", "log2.log", "-v"]) { handler in
            XCTAssertEqual(try handler.value(for: .output), "file.txt")

            XCTAssertEqual(try handler.positionalValues(), ["log1.log", "log2.log"])

            XCTAssert(handler.flags.contains(.verbose))
        }
    }

    func testCompoundFlagLastArgument() throws {
        try Command.filePrinter.run(arguments: ["example", "-vo", "file.txt", "log1.log"]) { handler in
            XCTAssertEqual(try handler.value(for: .output), "file.txt")

            XCTAssertEqual(try handler.positionalValues(), ["log1.log"])

            XCTAssert(handler.flags.contains(.verbose))
        }
    }

    func testCmdAsync() throws {


        let expectation = self.expectation(description: "Async")

        try Command.filePrinter.run(arguments: ["example", "-vo", "file.txt", "log1.log"]) { handler in

            do {
                let handler = try handler.cmd("curl -v http://www.google.com") { error, result in

                    defer {
                        expectation.fulfill()
                    }

                    if let error = error {
                        XCTFail("\(error)")
                        return
                    }

                    if let string = result?.standardOutput {
                        handler.print(string)
                    }
                }

            } catch {
                handler.print(error)
            }

            
            waitForExpectations(timeout: 10, handler: nil)

        }
    }

    func testCmd() throws {
        try Command.filePrinter.run(arguments: ["example"]) { handler in

            guard let output = try handler.cmd("ls -a1").standardOutput else {
                XCTFail("No output")
                return
            }

            print(output)

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
