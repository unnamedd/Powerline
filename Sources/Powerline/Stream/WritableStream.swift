import struct Foundation.Data

public protocol WritableStream: FileHandleStream {}

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
