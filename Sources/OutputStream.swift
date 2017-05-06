import Foundation

public protocol CommandOutput: TextOutputStream {
}

extension CommandOutput {
    public mutating func writeln(_ s: String) {
        write("\(s)\n")
    }
}

public struct StandardOutputStream: CommandOutput {
    static let stream = StandardErrorStream()

    public mutating func write(_ s: String) {
        guard let data = s.data(using: .utf8) else {
            return
        }

        FileHandle.standardOutput.write(data)
    }
}

public struct StandardErrorStream: CommandOutput {
    static let stream = StandardErrorStream()

    public mutating func write(_ s: String) {
        guard let data = s.data(using: .utf8) else {
            return
        }

        FileHandle.standardError.write(data)
    }
}
