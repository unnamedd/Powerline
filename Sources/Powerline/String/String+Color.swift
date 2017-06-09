extension String {

    /// String ascii style
    public enum ASCIIStyle: String {

        /// Bold
        case bold            = "\u{001B}[1m"

        /// Dimmed
        case dim             = "\u{001B}[2m"

        /// Italic
        case italic          = "\u{001B}[3m"

        /// Underlined
        case underline       = "\u{001B}[4m"

        /// Blinking
        case blink           = "\u{001B}[5m"

        /// Reversed
        case reverse         = "\u{001B}[7m"

        /// Hidden
        case hidden          = "\u{001B}[8m"

        /// Strikethrough
        case strikethrough   = "\u{001B}[9m"

        /// No style
        case reset           = "\u{001B}[0m"

        /// Black
        case black           = "\u{001B}[30m"

        /// Red
        case red             = "\u{001B}[31m"

        /// Green
        case green           = "\u{001B}[32m"

        /// Yellow
        case yellow          = "\u{001B}[33m"

        /// Blue
        case blue            = "\u{001B}[34m"

        /// Magenta
        case magenta         = "\u{001B}[35m"

        /// Cyan
        case cyan            = "\u{001B}[36m"

        /// Light gray
        case lightGray       = "\u{001B}[37m"

        /// Dark gray
        case darkGray        = "\u{001B}[90m"

        /// Light red
        case lightRed        = "\u{001B}[91m"

        /// Light green
        case lightGreen      = "\u{001B}[92m"

        /// Light yellow
        case lightYellow     = "\u{001B}[93m"

        /// Light blue
        case lightBlue       = "\u{001B}[94m"

        /// Light magenta
        case lightMagenta    = "\u{001B}[95m"

        /// Light cyan
        case lightCyan       = "\u{001B}[96m"

        /// White
        case white           = "\u{001B}[97m"

        /// Black background
        case onBlack         = "\u{001B}[40m"

        /// Red background
        case onRed           = "\u{001B}[41m"

        /// Green background
        case onGreen         = "\u{001B}[42m"

        /// Yellow background
        case onYellow        = "\u{001B}[43m"

        /// Blue background
        case onBlue          = "\u{001B}[44m"

        /// Magenta background
        case onMagenta       = "\u{001B}[45m"

        /// Cyan background
        case onCyan          = "\u{001B}[46m"

        /// Light gray background
        case onLightGray     = "\u{001B}[47m"

        /// Dark gray background
        case onDarkGray      = "\u{001B}[100"

        /// Light red background
        case onLightRed      = "\u{001B}[101"

        /// Light green background
        case onLightGreen    = "\u{001B}[102"

        /// Light yellow background
        case onLightYellow   = "\u{001B}[103"

        /// Light blue background
        case onLightBlue     = "\u{001B}[104"

        /// Light magenta background
        case onLightMagenta  = "\u{001B}[105"

        /// Light cyan background
        case onLightCyan     = "\u{001B}[106"

        /// White background
        case onWhite         = "\u{001B}[107"
    }

    internal func with(asciiStyle: ASCIIStyle) -> String {
        return asciiStyle.rawValue + replacingOccurrences(
            of: ASCIIStyle.reset.rawValue,
            with: ASCIIStyle.reset.rawValue + asciiStyle.rawValue
        ) + ASCIIStyle.reset.rawValue
    }

    /// Applies `bold` `ASCIIStyle` to string
    public var bold: String {
        return with(asciiStyle: .bold)
    }

    /// Applies `dimmed` `ASCIIStyle` to string
    public var dimmed: String {
        return with(asciiStyle: .dim)
    }

    /// Applies `italic` `ASCIIStyle` to string
    public var italic: String {
        return with(asciiStyle: .italic)
    }

    /// Applies `underlined` `ASCIIStyle` to string
    public var underlined: String {
        return with(asciiStyle: .underline)
    }

    /// Applies `blinking` `ASCIIStyle` to string
    public var blinking: String {
        return with(asciiStyle: .blink)
    }

    /// Applies `reversed` `ASCIIStyle` to string
    public var reversed: String {
        return with(asciiStyle: .reverse)
    }

    /// Applies `hidden` `ASCIIStyle` to string
    public var hidden: String {
        return with(asciiStyle: .hidden)
    }

    /// Applies `striked` `ASCIIStyle` to string
    public var striked: String {
        return with(asciiStyle: .strikethrough)
    }

    /// Applies `reset` `ASCIIStyle` to string
    public var reset: String {
        return with(asciiStyle: .reset)
    }

    /// Applies `black` `ASCIIStyle` to string
    public var black: String {
        return with(asciiStyle: .black)
    }

    /// Applies `red` `ASCIIStyle` to string
    public var red: String {
        return with(asciiStyle: .red)
    }

    /// Applies `green` `ASCIIStyle` to string
    public var green: String {
        return with(asciiStyle: .green)
    }

    /// Applies `yellow` `ASCIIStyle` to string
    public var yellow: String {
        return with(asciiStyle: .yellow)
    }

    /// Applies `blue` `ASCIIStyle` to string
    public var blue: String {
        return with(asciiStyle: .blue)
    }

    /// Applies `magenta` `ASCIIStyle` to string
    public var magenta: String {
        return with(asciiStyle: .magenta)
    }

    /// Applies `cyan` `ASCIIStyle` to string
    public var cyan: String {
        return with(asciiStyle: .cyan)
    }

    /// Applies `lightGray` `ASCIIStyle` to string
    public var lightGray: String {
        return with(asciiStyle: .lightGray)
    }

    /// Applies `darkGray` `ASCIIStyle` to string
    public var darkGray: String {
        return with(asciiStyle: .darkGray)
    }

    /// Applies `lightRed` `ASCIIStyle` to string
    public var lightRed: String {
        return with(asciiStyle: .lightRed)
    }

    /// Applies `lightGreen` `ASCIIStyle` to string
    public var lightGreen: String {
        return with(asciiStyle: .lightGreen)
    }

    /// Applies `lightYellow` `ASCIIStyle` to string
    public var lightYellow: String {
        return with(asciiStyle: .lightYellow)
    }

    /// Applies `lightBlue` `ASCIIStyle` to string
    public var lightBlue: String {
        return with(asciiStyle: .lightBlue)
    }

    /// Applies `lightMagenta` `ASCIIStyle` to string
    public var lightMagenta: String {
        return with(asciiStyle: .lightMagenta)
    }

    /// Applies `lightCyan` `ASCIIStyle` to string
    public var lightCyan: String {
        return with(asciiStyle: .lightCyan)
    }

    /// Applies `white` `ASCIIStyle` to string
    public var white: String {
        return with(asciiStyle: .white)
    }

    /// Applies `onBlack` `ASCIIStyle` to string
    public var onBlack: String {
        return with(asciiStyle: .onBlack)
    }

    /// Applies `onRed` `ASCIIStyle` to string
    public var onRed: String {
        return with(asciiStyle: .onRed)
    }

    /// Applies `onGreen` `ASCIIStyle` to string
    public var onGreen: String {
        return with(asciiStyle: .onGreen)
    }

    /// Applies `onYellow` `ASCIIStyle` to string
    public var onYellow: String {
        return with(asciiStyle: .onYellow)
    }

    /// Applies `onBlue` `ASCIIStyle` to string
    public var onBlue: String {
        return with(asciiStyle: .onBlue)
    }

    /// Applies `onMagenta` `ASCIIStyle` to string
    public var onMagenta: String {
        return with(asciiStyle: .onMagenta)
    }

    /// Applies `onCyan` `ASCIIStyle` to string
    public var onCyan: String {
        return with(asciiStyle: .onCyan)
    }

    /// Applies `onLightGray` `ASCIIStyle` to string
    public var onLightGray: String {
        return with(asciiStyle: .onLightGray)
    }

    /// Applies `onDarkGray` `ASCIIStyle` to string
    public var onDarkGray: String {
        return with(asciiStyle: .onDarkGray)
    }

    /// Applies `onLightRed` `ASCIIStyle` to string
    public var onLightRed: String {
        return with(asciiStyle: .onLightRed)
    }

    /// Applies `onLightGreen` `ASCIIStyle` to string
    public var onLightGreen: String {
        return with(asciiStyle: .onLightGreen)
    }

    /// Applies `onLightYellow` `ASCIIStyle` to string
    public var onLightYellow: String {
        return with(asciiStyle: .onLightYellow)
    }

    /// Applies `onLightBlue` `ASCIIStyle` to string
    public var onLightBlue: String {
        return with(asciiStyle: .onLightBlue)
    }

    /// Applies `onLightMagenta` `ASCIIStyle` to string
    public var onLightMagenta: String {
        return with(asciiStyle: .onLightMagenta)
    }

    /// Applies `onLightCyan` `ASCIIStyle` to string
    public var onLightCyan: String {
        return with(asciiStyle: .onLightCyan)
    }

    /// Applies `onWhite` `ASCIIStyle` to string
    public var onWhite: String {
        return with(asciiStyle: .onWhite)
    }
}
