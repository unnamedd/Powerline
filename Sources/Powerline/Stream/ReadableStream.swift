import struct Foundation.Data

public protocol ReadableStream: FileHandleStream {}

public extension ReadableStream {

    func readToEndOfFile() -> String? {
        guard let data: Data = readToEndOfFile() else {
            return nil
        }
        return String(data: data, encoding: encoding)
    }

    func read() -> Data? {
        let data = fileHandle.availableData
        return data.isEmpty ? nil : data
    }

    func read() -> String? {
        guard let data: Data = read() else {
            return nil
        }

        return String(data: data, encoding: encoding)
    }

    func readToEndOfFile() -> Data? {
        let data = fileHandle.readDataToEndOfFile()
        return data.isEmpty ? nil : data
    }
}
