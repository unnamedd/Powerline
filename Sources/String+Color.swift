extension String {
    public enum OutputStyle: String {

        case bold            = "\u{001B}[1m"
        case dim             = "\u{001B}[2m"
        case italic          = "\u{001B}[3m"
        case underline       = "\u{001B}[4m"
        case blink           = "\u{001B}[5m"
        case reverse         = "\u{001B}[7m"
        case hidden          = "\u{001B}[8m"
        case strikethrough   = "\u{001B}[9m"
        case reset           = "\u{001B}[0m"

        case black           = "\u{001B}[30m"
        case red             = "\u{001B}[31m"
        case green           = "\u{001B}[32m"
        case yellow          = "\u{001B}[33m"
        case blue            = "\u{001B}[34m"
        case magenta         = "\u{001B}[35m"
        case cyan            = "\u{001B}[36m"
        case lightGray       = "\u{001B}[37m"
        case darkGray        = "\u{001B}[90m"
        case lightRed        = "\u{001B}[91m"
        case lightGreen      = "\u{001B}[92m"
        case lightYellow     = "\u{001B}[93m"
        case lightBlue       = "\u{001B}[94m"
        case lightMagenta    = "\u{001B}[95m"
        case lightCyan       = "\u{001B}[96m"
        case white           = "\u{001B}[97m"

        case onBlack         = "\u{001B}[40m"
        case onRed           = "\u{001B}[41m"
        case onGreen         = "\u{001B}[42m"
        case onYellow        = "\u{001B}[43m"
        case onBlue          = "\u{001B}[44m"
        case onMagenta       = "\u{001B}[45m"
        case onCyan          = "\u{001B}[46m"
        case onLightGray     = "\u{001B}[47m"
        case onDarkGray      = "\u{001B}[100"
        case onLightRed      = "\u{001B}[101"
        case onLightGreen    = "\u{001B}[102"
        case onLightYellow   = "\u{001B}[103"
        case onLightBlue     = "\u{001B}[104"
        case onLightMagenta  = "\u{001B}[105"
        case onLightCyan     = "\u{001B}[106"
        case onWhite         = "\u{001B}[107"
    }

    public func styled(with style: OutputStyle) -> String {
        return style.rawValue + replacingOccurrences(
            of: OutputStyle.reset.rawValue,
            with: OutputStyle.reset.rawValue + style.rawValue
        ) + OutputStyle.reset.rawValue
    }

    public var bold: String {
        return styled(with: .bold)
    }

    public var dimmed: String {
        return styled(with: .dim)
    }

    public var italic: String {
        return styled(with: .italic)
    }

    public var underlined: String {
        return styled(with: .underline)
    }

    public var blinking: String {
        return styled(with: .blink)
    }

    public var reversed: String {
        return styled(with: .reverse)
    }

    public var hidden: String {
        return styled(with: .hidden)
    }

    public var striked: String {
        return styled(with: .strikethrough)
    }

    public var reset: String {
        return styled(with: .reset)
    }

    public var black: String {
        return styled(with: .black)
    }

    public var red: String {
        return styled(with: .red)
    }

    public var green: String {
        return styled(with: .green)
    }

    public var yellow: String {
        return styled(with: .yellow)
    }

    public var blue: String {
        return styled(with: .blue)
    }

    public var magenta: String {
        return styled(with: .magenta)
    }

    public var cyan: String {
        return styled(with: .cyan)
    }

    public var lightGray: String {
        return styled(with: .lightGray)
    }

    public var darkGray: String {
        return styled(with: .darkGray)
    }

    public var lightRed: String {
        return styled(with: .lightRed)
    }

    public var lightGreen: String {
        return styled(with: .lightGreen)
    }

    public var lightYellow: String {
        return styled(with: .lightYellow)
    }

    public var lightBlue: String {
        return styled(with: .lightBlue)
    }

    public var lightMagenta: String {
        return styled(with: .lightMagenta)
    }

    public var lightCyan: String {
        return styled(with: .lightCyan)
    }

    public var white: String {
        return styled(with: .white)
    }

    public var onBlack: String {
        return styled(with: .onBlack)
    }

    public var onRed: String {
        return styled(with: .onRed)
    }

    public var onGreen: String {
        return styled(with: .onGreen)
    }

    public var onYellow: String {
        return styled(with: .onYellow)
    }

    public var onBlue: String {
        return styled(with: .onBlue)
    }

    public var onMagenta: String {
        return styled(with: .onMagenta)
    }

    public var onCyan: String {
        return styled(with: .onCyan)
    }

    public var onLightGray: String {
        return styled(with: .onLightGray)
    }

    public var onDarkGray: String {
        return styled(with: .onDarkGray)
    }

    public var onLightRed: String {
        return styled(with: .onLightRed)
    }

    public var onLightGreen: String {
        return styled(with: .onLightGreen)
    }

    public var onLightYellow: String {
        return styled(with: .onLightYellow)
    }

    public var onLightBlue: String {
        return styled(with: .onLightBlue)
    }

    public var onLightMagenta: String {
        return styled(with: .onLightMagenta)
    }

    public var onLightCyan: String {
        return styled(with: .onLightCyan)
    }

    public var onWhite: String {
        return styled(with: .onWhite)
    }
}
