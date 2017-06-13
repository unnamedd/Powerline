import class Foundation.FileHandle

public protocol FileHandleStream {
    var fileHandle: FileHandle { get }
    var encoding: String.Encoding { get }
}
