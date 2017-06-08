import class Foundation.FileHandle

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
