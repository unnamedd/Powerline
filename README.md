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

### Arguments

Begin by creating named arguments, flags and positional arguments, like so:

```swift
extension Flag {
  static let verbose = Flag(
      name: "verbose",                 // --verbose
      character: "v",                  // -v
      summary: "Prints debug output"   // Printed out in help
  )
}
```

```swift
extension NamedArgument {
  static let output = NamedArgument(
    name: "output",              // --output <file>
    character: "o",              // -o <file>
    summary: "File to write to", // Printed out in help
    valuePlaceholder: "file"     // Placeholder for value printed out in help
  )
}
```

```swift
extension PositionalArgument {
  static let files = PositionalArgument(
  	name: "file",                 // Printed out in help
  	summary: "A file to process", // Printed out in help
  	variadic: true                // Whether multiple values are supported
  )
}
```

### Commands

```swift
extension Command {
    static let filePrinter = Command(
        name: "filePrinter",                     // Name of command
        summary: "Prints the contents of files", // Summary shown in help
        subcommands: [],                         // Add aditional subcommands if needed
        positionalArgument: .files,              // Positional arguments
        namedArguments: [.output],               // Named arguments
        flags: [.verbose]                        // Flags,
        handler: filePrinterCommandHandler       // Handler closure
    )
    
    private static func filePrinterCommandHandler(result: Command.Result) throws {
    
    	// Check flags
    	let verbose: Bool = result.flags.contains(.verbose)
    
    	if verbose {
    		result.stdout("Verbose enabled")
    	}
    	
    	// Iterate over positional arguments
    	for argument in result.positionalArguments {
    		result.stdout("Processing", argument)
    	}
    	
    	// Get value of named parameter
    	guard let output = result.string(for: .output) else {
    		throw CommandError(error: "Missing output parameter")
    	}
    	
    	// Automatically cast and nil assert, throw error on failure
		let outputOrThrow: Int = try result.value(for: .output)
		
		// Run a shell command
		let cmdResult = try result.cmd("curl -v http://www.google.com")
		
		guard let cmdResult.standardOutput else {
			
			if let cmdStderr = cmdResult.standardError {
				result.stderr(cmdStderr)
			}	
		
			throw CommandError(error: "Curl didn't result in stdout")
		}
    }
}
```

### Running commands
```swift
// Run with process info arguments
Command.filePrinter.run()

// Run with custom arguments
Command.filePrinter.run(arguments: ["arg1", "arg2])

// Run with process info arugments, exit on error
Command.filePrinter.runOrExit()

// Run with custom arugments, exit on error
Command.filePrinter.runOrExit(arguments: ["arg1", "arg2])
```

## Credits

- David Ask ([@davidask](https://github.com/davidask))

## License

Pin is released under the MIT license. See LICENSE for details.

## About Formbound

[Formbound AB](https://github.com/formbound) is a software development firm devoted to open-source development.