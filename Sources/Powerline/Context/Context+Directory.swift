#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

@_exported import struct Foundation.URL
import class Foundation.FileManager

extension Context {

    public var currentDirectory: String {
        get {
            return FileManager.default.currentDirectoryPath
        }
        set {
            guard FileManager.default.changeCurrentDirectoryPath(newValue) else {
                standardError.write("Failed to change current directory path", terminator: "\n")
                exit(EXIT_FAILURE)
            }
        }
    }

    /// The current directory url of the process
    public var urlForCurrentDirectory: URL {
        get {
            return URL(fileURLWithPath: currentDirectory, isDirectory: true)
        }
        set {
            currentDirectory = newValue.path
        }
    }

    public func relativePath(for path: String) throws -> String {
        guard let url = URL(string: path, relativeTo: urlForCurrentDirectory) else {
            throw CommandError(message: "Failed to resolve path for \(path)")
        }
        return url.relativePath
    }
}
