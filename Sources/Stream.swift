import Foundation

public protocol FileHandleStream {
    var fileHandle: FileHandle { get }
    var encoding: String.Encoding { get }
}

public protocol ReadableStream: FileHandleStream {}
public protocol WritableStream: FileHandleStream {}

extension ReadableStream {
    public func readToEndOfFile() -> String? {
        guard let data: Data = readToEndOfFile() else {
            return nil
        }
        return String(data: data, encoding: encoding)
    }

    public func read() -> Data? {
        let data = fileHandle.availableData
        return data.isEmpty ? nil : data
    }

    public func read() -> String? {
        guard let data: Data = read() else {
            return nil
        }

        return String(data: data, encoding: encoding)
    }

    public func readToEndOfFile() -> Data? {
        let data = fileHandle.readDataToEndOfFile()
        return data.isEmpty ? nil : data
    }
}

extension WritableStream {
    public func write(_ string: String, terminator: String) {
        write(string + terminator)
    }

    public func write(_ data: Data) {
        fileHandle.write(data)
    }

    public func write(_ string: String) {
        guard let data = string.data(using: encoding) else {
            fatalError("Failed to convert string to data using encoding \(encoding)")
        }

        write(data)
    }
}

public struct OutputStream: WritableStream {
    public let fileHandle: FileHandle
    public var encoding: String.Encoding

}

public struct InputStream: ReadableStream {
    public let fileHandle: FileHandle
    public var encoding: String.Encoding
}

public struct Stream: ReadableStream, WritableStream {
    public let fileHandle: FileHandle
    public var encoding: String.Encoding
}
