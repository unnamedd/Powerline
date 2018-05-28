# Powerline
[![CircleCI](https://circleci.com/gh/formbound/Powerline.svg?style=svg)](https://circleci.com/gh/formbound/Powerline)

Powerline is a library for writing fast and reliable command-line applications in Swift, for Linux and macOS.

### Supported platforms
Powerline runs on macOS and Ubuntu.

* Ubuntu 14.04+
* macOS 10.12+

### Features

* Subcommands
* Type-safe argument parsing
* Shell commands
* Prompting
* String coloring

### Glossary

Due to lack of argument parsing standards, Powerline adopts a similar style to that of git. Here's how Powerline distinguishes types of arguments:

- **Option**
  A key-value argument. `--message "Message"` or `-m "Message"`
- **Flag**
  An on-off switch defining a condition.  `--verbose` or `-v`
  - Multiple flags can be combined. `-a -b -c`, equals `-abc`
  - A series of flags can contain a trailing option `-abcm "Message"`
- **Parameter**
  An argument that is a value in itself



## Creating a command-line application

* Create a new folder and run `swift package init —type executable`
* Add `Powerline` as a dependency to your package

```swift
import PackageDescription

let package = Package(
    name: "example",
    dependencies: [
        .package(url: "https://github.com/formbound/Powerline", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "example",
            dependencies: ["Powerline"]),
    ]
)
```

* Define arguments for your command

```swift
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
```

* Create a command

```swift
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
```

* Run the command

```swift
let command = ExampleCommand()
try command.run()
```



## Documentation

Read the code documentation at [powerline.formbound.org](http://powerline.formbound.org)

