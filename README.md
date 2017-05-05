<p align="center">

<img src="Images/header-image.png" height="250" />

</p>

# Powerline

Powerline is a library for writing solid command-line interfaces in Swift, for Linux and macOS.

## Glossary
* **Command**
   A command is a space-delimited string , where the first string component is the name of an executable.

* **Argument**
   An argument is a string component of a command.


* **Named argument**
   A named argument is a key-value argument written like this `--message Hello` or `-m Hello`.

* **Flag**
   A flag is a on-off switch which presence (or lack thereof) defines a condition. Flags can be written as such: `--verbose` or `-v`.

   * Multiple flags can be combined, so instead of writing `-a -b -c`, writing `-abc` works too.
   * A series of flags can contain a named argument last, e.g. `git commit -am "Changes"`.

* **Positional argument**
   A positional one or more values as a simple strings in a command.



## Usage
Creating structured commands with Powerline is easy. The best way to produce type-safe and clean code is to add arguments and commands via extensions.

Let's create a CLI that greets people.

### Set up the project

```swift
$ mkdir powerline-example
$ cd powerline-example
swift package init --type executable
```

In your `Package.swift` file, add `Powerline` as a dependency:

```swift
import PackageDescription

let package = Package(
    name: "Powerline-example2",
    dependencies: [
        .Package(url: "https://github.com/formbound/Powerline", majorVersion: 0, minor: 1)
    ]
)
```

Create flags, named arguments, and positional arguments like so:

```swift
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

    static let count = NamedArgument(
        name: "count",
        character: "c",
        summary: "Number of times to say Hello world",
        valuePlaceholder: "n"
    )
}

extension PositionalArgument {
    static let names = PositionalArgument(
        name: "names",
        summary: "Names to greet",
        variadic: true
    )
}
```

Create the command in an extension if you like, or store it in any way you wish.

```swift
extension Command {
    static let greeter = Command(
        name: "greeter",
        summary: "Greets people",
        subcommands: [],
        positionalArgument: .names,
        namedArguments: [.output, .count],
        flags: [.verbose],
        handler: greeterHandler
    )

    private static func greeterHandler(result: Command.Result) throws {

        // Make sure there's anyone to greet to begin with
        guard !result.positionalArguments.isEmpty else {
            throw CommandError(error: "No names to greet!")
        }

        // Check --verbose flag
        let verbose: Bool = result.flags.contains(.verbose)

        // Safely cast and access the value from a named argument
        let greetCount: Int = try result.value(for: .count) ?? 1

        // String to print or output
        var resultString: String = ""

        for i in 0..<greetCount {

            if verbose {
                print("Greeting round \(i)")
            }

            // Loop through positional arguments
            for name in result.positionalArguments {

                if verbose {
                    print("Greeting \(name)")
                }

                resultString += "Hello " + name + "!\n"
            }
        }

        // If we have an output file in the named arguments, write to that file
        if let outputFile: String = try result.value(for: .output) {
            try resultString.write(toFile: outputFile, atomically: true, encoding: .utf8)
        }
            // Otherwise, print the output
        else {
            result.stdout(resultString)
        }
    }
}
```

In your `main.swift` file, simply add

```swift
Command.greeter.runOrExit()
```

Build your executable

```swift
$ swift build
```

Run the executable

```swift
$ .build/debug/powerline-example --help
```

Here's the output you'll see

```sh
NAME
	greeter - Greets people

USAGE
	greeter [options]

OPTIONS
	-v,  --verbose
		Prints debug output

	-h, --help
		Show usage description

	-o, --output <file>
		File to write to

	-c, --count <n>
		Number of times to say Hello world
```

The command is now ready to use! 👾

## Additionally

### Printing to standard out and standard error

```swift
func commandHandler(result: Command.Result) throws {
    result.stdout("Hello")
    result.stderr("Hello")
}
```

### Running shell commands

```swift
func commandHandler(result: Command.Result) throws {
    let shellResult = try result.cmd("ls -a1")
    print(shellResult.standardOutput)
    print(shellResult.standardError)

    let process = try result.cmd("ls -a1") { error, result in
        // Run asynchronously
    }

    process.suspend()
    process.resume()
}
```

## Credits

- David Ask ([@davidask](https://github.com/davidask))

## License

Pin is released under the MIT license. See LICENSE for details.

## About Formbound

[Formbound AB](https://github.com/formbound) is a software development firm devoted to open-source development.