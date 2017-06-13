import XCTest
@testable import Powerline

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

    func testRequiresFlag() throws {

        let flag = Flag(
            longName: "flag",
            shortName: "f",
            summary: "Required flag"
        )

        try SimpleCommand(
            flags: [flag]) { context in
                XCTAssert(context.flags.contains(flag))
        }.run(arguments: ["example", "-f"])
    }

    func testRequiresNamedArgument() throws {

        let arg = Option(longName: "required", summary: "None")

        try SimpleCommand(
            options: [arg]) { context in
                XCTAssertEqual(try context.value(for: arg), "1234")
            }.run(arguments: ["example", "--required", "1234"])
    }

    func testVariadicPositionalArgumentsWithConversion() throws {

        let positional = Parameter(name: "pos", summary: "None")

        try SimpleCommand(
            variadicParameter: positional) { context in

                XCTAssertEqual(try context.parameters.variadicValue(at: 0), 1234)
                XCTAssertEqual(try context.parameters.variadicValue(at: 1), 5678)

            }.run(arguments: ["example", "1234", "5678"])
    }

    func testSubCommand() throws {

        let subcommandFlag = Flag(longName: "test", shortName: "t", summary: "None")

        let subcommand = SimpleCommand(
            summary: "Subcommand",
            flags: [subcommandFlag]) { context in
                XCTAssert(context.flags.contains(subcommandFlag))
        }

        let mainFlag = Flag(longName: "main", shortName: "m", summary: "None")

        let command = SimpleCommand(flags: [mainFlag], subcommands: ["sub": subcommand]) { context in
            XCTAssert(context.flags.contains(mainFlag))
        }

        try command.run(arguments: ["example", "-m"])
        try command.run(arguments: ["example", "sub", "--test"])

    }

    func testCmd() throws {
        let command = SimpleCommand { context in

            guard let stdout = try context.run("ls -a1").standardOutput else {
                XCTFail("No stdout")
                return
            }

            context.print(stdout)
        }

        print(CommandLine.arguments)

        try command.run(arguments: ["example"])
    }
}
