extension Context {
    /// Reads the input from stdin
    ///
    /// - Returns: A string, or nil if the input is empty
    public func read() -> String? {
        guard let input = standardInput.read()?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }
        return input.isEmpty ? nil : input
    }

    public func read<T: StandardInputInitializable>() -> T {

        while true {
            guard let input = read() else {
                print("Please try again:".yellow, terminator: " ")
                continue
            }

            guard let value = T(input: input) else {
                print(StandardInputInitializableError.failedConversion(of: input, to: T.self).description)
                print("Please try again:".yellow, terminator: " ")
                continue
            }

            return value
        }
    }

    public func read<T: StandardInputInitializable>(message: String) -> T {
        print("\(message): ".bold.magenta, terminator: "")

        return read()
    }

    /// Prompts the user to type either `y` or `n`.
    ///
    /// - Parameter message: A message to provide
    /// - Returns: `true` if the input was `y`, `false` if the input was `n`.
    public func confirm(_ message: String) -> Bool {
        print(message.bold.magenta, "[y/N]", terminator: " ")

        while true {
            let input = read()?.lowercased() ?? ""

            switch input {
            case "y":
                return true
            case "n":
                return false
            default:
                print("Please enter yes or no. [y/N]:".yellow, terminator: " ")
            }
        }
    }

    /// Prompts the user to select one of several values
    ///
    /// - Parameters:
    ///   - options: An array of strings representing the selectable values
    ///   - defaultValue: Optional default value. Does not have to be contained in the original options
    ///   - message: A message to provide
    /// - Returns: The selected value or default value, if provided
    public func select(_ options: [String], default defaultValue: String? = nil, message: String) -> String {
        print(message.bold.magenta)
        for (i, option) in options.enumerated() {
            if let defaultValue = defaultValue, i == options.index(of: defaultValue) {
                print("\(i + 1))".blue.bold, option, "(Default)".dimmed)
            } else {
                print("\(i + 1))".blue, option)
            }
        }

        if let defaultValue = defaultValue {
            print("Select an option. Press ENTER for default value (\(defaultValue.italic)):".blue, terminator: " ")
        } else {
            print("Select an option:".blue, terminator: " ")
        }

        while true {
            guard let input = read() else {
                guard let defaultValue = defaultValue else {
                    print("You have to select an option:".yellow, terminator: " ")
                    continue
                }

                return defaultValue
            }

            guard let index = Int(input), (options.startIndex ..< options.endIndex).contains(index - 1) else {
                if let defaultValue = defaultValue {
                    print(
                        "Please select an option between) and \(options.endIndex), or press ENTER for default value (\(defaultValue.italic)):".yellow, terminator: " ")
                } else {
                    print("Please select an option between \(options.startIndex + 1) and \(options.endIndex):".yellow, terminator: " ")
                }
                continue
            }

            return options[index - 1]
        }
    }
}
