import struct Foundation.Data
import class Foundation.FileHandle

internal protocol FileHandleStream {
    var fileHandle: FileHandle { get }
    var encoding: String.Encoding { get }
}

internal protocol ReadableStream: FileHandleStream {}
internal protocol WritableStream: FileHandleStream {}

extension ReadableStream {
    internal func readToEndOfFile() -> String? {
        guard let data: Data = readToEndOfFile() else {
            return nil
        }
        return String(data: data, encoding: encoding)
    }

    internal func read() -> Data? {
        let data = fileHandle.availableData
        return data.isEmpty ? nil : data
    }

    internal func read() -> String? {
        guard let data: Data = read() else {
            return nil
        }

        return String(data: data, encoding: encoding)
    }

    internal func readToEndOfFile() -> Data? {
        let data = fileHandle.readDataToEndOfFile()
        return data.isEmpty ? nil : data
    }
}

extension WritableStream {
    internal func write(_ string: String, terminator: String) {
        write(string + terminator)
    }

    internal func write(_ data: Data) {
        fileHandle.write(data)
    }

    internal func write(_ string: String) {
        guard let data = string.data(using: encoding) else {
            fatalError("Failed to convert string to data using encoding \(encoding)")
        }

        write(data)
    }
}

internal struct OutputStream: WritableStream {
    public let fileHandle: FileHandle
    public var encoding: String.Encoding

}

internal struct InputStream: ReadableStream {
    public let fileHandle: FileHandle
    public var encoding: String.Encoding
}

internal struct Stream: ReadableStream, WritableStream {
    public let fileHandle: FileHandle
    public var encoding: String.Encoding
}
