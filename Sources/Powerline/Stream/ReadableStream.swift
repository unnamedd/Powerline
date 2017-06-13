import struct Foundation.Data

public protocol ReadableStream: FileHandleStream {}

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
