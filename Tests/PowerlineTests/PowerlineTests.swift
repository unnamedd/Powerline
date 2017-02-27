import XCTest
@testable import Powerline

class PowerlineTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }


    static var allTests : [(String, (PowerlineTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }

    func testBasics() throws {

        let result = try Command.commit.run(arguments: "git commit -am \"OK\"".components(separatedBy: " "))

        print(result.valuesByNamedArgument)

    }
}

extension Command {
    static let commit = Command(
        name: "commit",
        namedArguments: [
            .message
        ],
        flags: [
            .stageAll
        ]
    )
}


extension Flag {
    static let stageAll = Flag(name: "all", character: "a", description: "Stages all")
}

extension NamedArgument {
    static let message = NamedArgument(name: "message", character: "m", description: "Commit message", valuePlaceholder: "msg")
}
