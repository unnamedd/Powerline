<p align="center">

<img src="Images/header-image.png" height="250" />

</p>

# Powerline

Powerline is a library for writing solid command-line interfaces in Swift, for Linux and macOS.



<img src="Images/output-screenshot2.png" />

## Features

- [x] Subcommands
- [x] Type-safe options parsing
- [x] Shell commands
- [x] Prompting
- [x] String colouring

## Glossary

- **Command**
  A command is a space-delimited string , where the first string component is the name of an executable.
- **Argument**
  An argument is a string component of a command.


- **Named argument**
  A named argument is a key-value argument written like this `--message Hello` or `-m Hello`.
- **Flag**
  A flag is a on-off switch which presence (or lack thereof) defines a condition. Flags can be written as such: `--verbose` or `-v`.
  - Multiple flags can be combined, so instead of writing `-a -b -c`, writing `-abc` works too.
  - A series of flags can contain a named argument last, e.g. `git commit -am "Changes"`.
- **Positional argument**
  A positional one or more values as a simple strings in a command.

## Usage

Creating structured commands with Powerline is easy. The best way to produce type-safe and clean code is to add arguments and commands via extensions.

Let's create a CLI that greets people.

### Create a new Swift executable

```sh
$ mkdir greeter
$ cd greeter
$ swift package init --type executable
```

In your `Package.swift` file, add `Powerline` as a dependency:

```swift
import PackageDescription

let package = Package(
    name: "greeter",
    dependencies: [
        .Package(url: "https://github.com/formbound/Powerline", majorVersion: 0, minor: 1)
    ]
)
```

#### Create flags, named arguments

```swift
import Powerline

extension Flag {
    static let verbose = Flag(
        name: "verbose",
        character: "v",
        summary: "Prints debug output"
    )
}

extension NamedArgument {
    static let output = NamedArgument(
        name: "output",
        character: "o",
        summary: "File to write to",
        valuePlaceholder: "file"
    )
}
```

#### Create commands

Here's an example of a complete command implementation.

```swift
import Powerline

struct Greeter: Command {

    // Positional argument accepted by the command
    let positionalArgument: PositionalArgument? = PositionalArgument(name: "names", variadic: true)

    // Short description of what the command does
    let summary: String = "Greets people!"

    // Flags accepted by the command
    let flags: Set<Flag> = [.verbose]

    // Named arguments, accepted by the command
    let namedArguments: Set<NamedArgument> = [.output]

    // Invoked when the command is run
    //
    // - Parameter process: Process grants access to the parameters
    //   of the running process such as options, environment,
    ///  stdout, stdin, and more
    func run(process: CommandProcess) throws {

        // No positional arguments? This command requires at least one
        guard !process.positionalArguments.isEmpty else {
            throw CommandError("There's no one to greet :(", invalidUsage: true)
        }

        // Check flags
        let verbose: Bool = process.flags.contains(.verbose)

        if verbose {
            // Prints to stdout
            process.print("Verbose mode enabled")
        }

        var resultString: String = ""

        // Loop through positional arguments
        for name in process.positionalArguments {
            resultString += "Hello " + name + "!\n"
        }

        // Get value from named argument
        if let outputFile: String = try process.value(forNamedArgument: .output) {
            try resultString.write(toFile: outputFile, atomically: true, encoding: .utf8)
        } else {
            // Print greetings
            process.print(resultString)
        }

    }
}
```

#### Subcommands

You can build complex commands by adding subcommands, like so:

```swift
struct Greeter: Command {
    let summary: String = "Greets people!"
    let subcommands: [String: Command] = ["polite": PoliteGreeter()]
}
```

Running `greeter polite` will now invoke that subcommand.

#### Run a command

In your `main.swift` file, simply add

```swift
Greeter().runOrExit()
```

You can also handle errors yourself, by running

```Swift
do {
  try Greeter().run()
} catch {
  print("\(error)")
}
```

#### Throwing errors

You can throw any error you want, and handle them as you wish. When running commands using `runOrExit()` , throwing a `CommandError` will output the message you provide to `stderr`.

Setting `invalidUsage` to true will cause the usage output to be printed.

```swift
throw CommandError("Wrong usage", invalidUsage: true)
```

Build your executable

```swift
$ swift build
```

Run the executable

```swift
$ .build/debug/greeter --help
```

Here's the output you'll see:

<img src="Images/output-screenshot.png" />

The command is now ready to use! 👾

## Additionally

### Printing to stdout and stderr

```swift
func commandHandler(process: Command.Process) throws {
    // Print to stdout
    process.print("Hello")
    // Print to stderr
    process.error("Hello")
}
```



### Colorize strings

You can colorize output using `String` extensions. Here are some examples:

```swift
"Success".green
"My favorite colors are " + "green".red + " and " + "blue".blue
"This string is white on black".white.onBlack
```



### Running shell commands

A shell command will throw an error if it exists with a non-zero value.

```swift
func commandHandler(process: Command.Process) throws {
	
    // Run a command synchronously
    let shellResult = try process.run("ls -a1")
    print(shellResult.standardOutput) // Optional
    print(shellResult.standardError)  // Optional
    
    // Run a command asynchronously
    let process = try process.run("ls -a1") { error, result in
        // Run asynchronously
    }

    process.suspend()
    process.resume()
}
```

### Prompting

You can read from `stdin` in a few useful ways:

```swift
func commandHandler(process: Command.Process) throws {

    if let input = process.readInput() {
        // Do something with input
    }

    if process.confirm("Are you sure?") {
        // User is sure
    }

    let options = ["One", "Two", "Three", "Four"]

    // `default` is optional, forcing the user to make an active choice
    let selectedOption = process.select(
        options,
        default: options[1],
        message: "Select your favorite number!"
    )
}
```

## Credits

- David Ask ([@davidask](https://github.com/davidask))

## License

Pin is released under the MIT license. See LICENSE for details.

## About Formbound

[Formbound AB](https://github.com/formbound) is a software development firm devoted to open-source development.