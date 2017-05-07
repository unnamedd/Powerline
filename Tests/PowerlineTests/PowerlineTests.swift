import XCTest
@testable import Powerline

class PowerlineTests: XCTestCase {

    static var allTests: [(String, (PowerlineTests) -> () throws -> Void)] {
        return [
            ("testRequiresFlag", testRequiresFlag),
            ("testRequiresNamedArgument", testRequiresNamedArgument),
            ("testVariadicPositionalArgumentsWithConversion", testVariadicPositionalArgumentsWithConversion),
            ("testSubCommand", testSubCommand),
            ("testCmd", testCmd),
            ("testCmdAsync", testCmdAsync),
        ]
    }

    func testRequiresFlag() throws {

        let flag = Flag(
            name: "flag",
            character: "f",
            summary: "Required flag"
        )

        try Command(
            name: "Requires verbose",
            summary: "A command that simply requires the --verbose command",
            flags: [flag]) { process in
                XCTAssert(process.flags.contains(flag))
        }.run(arguments: ["example", "-f"])
    }

    func testRequiresNamedArgument() throws {

        let arg = NamedArgument(name: "required")

        try Command(
            name: "Requires verbose",
            summary: "A command that simply requires the --verbose command",
            namedArguments: [arg]) { process in
                XCTAssertEqual(try process.value(forNamedArgument: arg), "1234")
            }.run(arguments: ["example", "--required", "1234"])
    }

    func testVariadicPositionalArgumentsWithConversion() throws {

        let positional = PositionalArgument(name: "pos", variadic: true)

        try Command(
            name: "Requires verbose",
            summary: "A command that simply requires the --verbose command",
            positionalArgument: positional) { process in
                XCTAssertEqual(try process.positionalArguments.value(at: 0), 1234)
                XCTAssertEqual(try process.positionalArguments.value(at: 1), 5678)
            }.run(arguments: ["example", "1234", "5678"])
    }

    func testSubCommand() throws {

        let subCommandFlag = Flag(name: "test", character: "t")

        let subcommand = Command(
            name: "sub",
            summary: "Subcommand",
            flags: [subCommandFlag]) { process in
                XCTAssert(process.flags.contains(subCommandFlag))
        }

        let mainFlag = Flag(name: "main", character: "m")

        let command = Command(name: "main", summary: "main", subcommands: [subcommand], flags: [mainFlag]) { process in
            XCTAssert(process.flags.contains(mainFlag))
        }

        try command.run(arguments: ["example", "-m"])
        try command.run(arguments: ["example", "sub", "--test"])

    }

    func testCmd() throws {
        let command = Command(name: "cmd", summary: "cmd") { process in

            guard let stdout = try process.run("ls -a1").standardOutput else {
                XCTFail("No stdout")
                return
            }

            process.print(stdout)
        }

        print(CommandLine.arguments)

        try command.run(arguments: ["example"])
    }

    func testCmdAsync() throws {

        let e = expectation(description: "Async command")

        let command = Command(name: "cmd", summary: "cmd") { process in

            try process.run("curl -v http://ip.jsontest.com") { error, cmdResult in
                if let error = error {
                    XCTFail(error.localizedDescription)
                    return
                }

                guard let cmdResult = cmdResult else {
                    XCTFail("Result missing")
                    return
                }

                guard let stdout = cmdResult.standardOutput else {
                    XCTFail("No stdout")
                    return
                }

                process.print(stdout)

                e.fulfill()
            }
        }

        try command.run(arguments: ["example"])

        waitForExpectations(timeout: 10, handler: nil)
    }
}
