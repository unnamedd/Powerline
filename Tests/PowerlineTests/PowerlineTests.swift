@testable import Powerline
import XCTest

class PowerlineTests: XCTestCase {

    static var allTests: [(String, (PowerlineTests) -> () throws -> Void)] {
        return [
            ("testRequiresFlag", testRequiresFlag),
            ("testRequiresNamedArgument", testRequiresNamedArgument),
            ("testVariadicPositionalArgumentsWithConversion", testVariadicPositionalArgumentsWithConversion),
            ("testSubCommand", testSubCommand),
            ("testCmd", testCmd)
        ]
    }

    func testExampleCommand() throws {
        let command = ExampleCommand()

        try command.run(arguments: ["example", "--verbose", "Hello World!", "-n", "1"])
    }

    func testRequiresFlag() throws {

        let flag = Flag(
            longName: "flag",
            shortName: "f",
            summary: "Required flag"
        )

        try SimpleCommand(arguments: Arguments(flags: [flag])) { context in
                XCTAssert(context.flags.contains(flag))
        }.run(arguments: ["example", "-f"])
    }

    func testRequiresNamedArgument() throws {

        let arg = Option(longName: "required", summary: "None")

        try SimpleCommand(arguments: Arguments(options: [arg])) { context in
                XCTAssertEqual(try context.value(for: arg), "1234")
        }.run(arguments: ["example", "--required", "1234"])
    }

    func testVariadicPositionalArgumentsWithConversion() throws {

        let positional = Parameter(name: "pos", summary: "None")

        try SimpleCommand(arguments: Arguments(variadicParameter: positional)) { context in

                XCTAssertEqual(try context.parameters.variadicValue(at: 0), 1_234)
                XCTAssertEqual(try context.parameters.variadicValue(at: 1), 5_678)

        }.run(arguments: ["example", "1234", "5678"])
    }

    func testSubCommand() throws {

        let subcommandFlag = Flag(longName: "test", shortName: "t", summary: "None")

        let subcommand = SimpleCommand(
            summary: "Subcommand",
            arguments: Arguments(flags: [subcommandFlag])) { context in
                XCTAssert(context.flags.contains(subcommandFlag))
        }

        let mainFlag = Flag(longName: "main", shortName: "m", summary: "None")

        let command = SimpleCommand(
        summary: "Main command",
        arguments: Arguments(flags: [mainFlag]),
        subcommands: ["sub": subcommand]) { context in
            XCTAssert(context.flags.contains(mainFlag))
        }

        try command.run(arguments: ["example", "-m"])
        try command.run(arguments: ["example", "sub", "--test"])
    }

    func testCmd() throws {
        let expectation = self.expectation(description: #function)

        let command = SimpleCommand { context in
            context.run(executable: "ls", arguments: ["-a1"]).whenResolved { result in
                XCTAssert(result.isError == false)
                expectation.fulfill()
            }
        }

        try command.run(arguments: ["example"])
        waitForExpectations(timeout: 3, handler: nil)
    }
}
