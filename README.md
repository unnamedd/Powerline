
<p align="center">
<img src="Images/header.png" height="250" />
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




## Basic usage

```swift
import Powerline

struct HelloWorld : Command {

    let summary: String = "Prints Hello world!"

    func process(context: Context) throws {
        context.print("Hello world!".green)
    }
}

try HelloWorld().run()
```




## Credits

- David Ask ([@davidask](https://github.com/davidask))

## License

Pin is released under the MIT license. See LICENSE for details.

## About Formbound

[Formbound AB](https://github.com/formbound) is a software development firm devoted to open-source development.