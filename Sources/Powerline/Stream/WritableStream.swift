import struct Foundation.Data

public protocol WritableStream: FileHandleStream {}

public extension WritableStream {

    func write(_ string: String, terminator: String) {
        write(string + terminator)
    }

    func write(_ data: Data) {
        fileHandle.write(data)
    }

    func write(_ string: String) {
        guard let data = string.data(using: encoding) else {
            fatalError("Failed to convert string to data using encoding \(encoding)")
        }

        write(data)
    }
}
