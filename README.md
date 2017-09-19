
<p align="center">
<img src="https://raw.githubusercontent.com/formbound/Powerline/master/Images/header.png" height="250" />
</p>

# Powerline

Powerline is a library for writing fast and reliable command-line applications in Swift, for Linux and macOS.

## Features

- [x] Subcommands
- [x] Type-safe argument parsing
- [x] Shell commands
- [x] Prompting
- [x] String coloring

## Glossary

Due to lack of argument parsing standards, Powerline adopts a similar style to that of git. Here's how Powerline distinguishes types of arguments:

- **Option**
  A key-value argument. `--message "Message"` or `-m "Message"`
- **Flag**
  An on-off switch defining a condition.  `--verbose` or `-v`
  - Multiple flags can be combined. `-a -b -c`, equals `-abc`
  - A series of flags can contain a trailing option `-abcm "Message"`
- **Parameter**
  An argument that is a value in itself



## Creating an executable

* Create a new folder and run `swift package init —type executable`
* Add `Powerline` as a dependency to your package

```swift
// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Example",
    dependencies: [
        .package(url: "https://github.com/formbound/Powerline", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Example",
            dependencies: ["Powerline"]),
    ]
)
```



```swift
import Powerline

struct HelloWorld : Command {

    let summary: String = "Prints Hello world!"

    func process(context: Context) throws {
        context.print("Hello world!".green)
    }
}

let main = HelloWorld()

try main.run()
```



## Documentation

Read the code documentation at [powerline.formbound.org](http://powerline.formbound.org)

## License

Powerline is released under the MIT license. See LICENSE for details.

## About Formbound

Formbound AB is a software development firm devoted to open-source development.
