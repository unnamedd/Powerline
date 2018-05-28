#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

@_exported import struct Foundation.URL
import class Foundation.FileManager

public extension Context {

    /// Returns the current directory path of the context
    var currentDirectoryPath: String {
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

    /// Returns the current directory URL of the context
    var urlForCurrentDirectory: URL {
        get {
            return URL(fileURLWithPath: currentDirectoryPath, isDirectory: true)
        }
        set {
            currentDirectoryPath = newValue.path
        }
    }

    func relativePath(for path: String) throws -> String {
        guard let url = URL(string: path, relativeTo: urlForCurrentDirectory) else {
            throw CommandError(message: "Failed to resolve path for \(path)")
        }
        return url.relativePath
    }
}
