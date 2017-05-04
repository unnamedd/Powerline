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
