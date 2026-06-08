import Foundation

struct OutputPathResolver {
    private let outputFolder: URL
    private let outputExtension: String
    private let fileManager: FileManager
    private var reservedPaths: Set<String> = []

    init(outputFolder: URL, outputFormat: OutputFormat, fileManager: FileManager = .default) {
        self.init(outputFolder: outputFolder, outputExtension: outputFormat.fileExtension, fileManager: fileManager)
    }

    init(outputFolder: URL, videoOutputFormat: VideoOutputFormat, fileManager: FileManager = .default) {
        self.init(outputFolder: outputFolder, outputExtension: videoOutputFormat.fileExtension, fileManager: fileManager)
    }

    init(outputFolder: URL, outputExtension: String, fileManager: FileManager = .default) {
        self.outputFolder = outputFolder.standardizedFileURL
        self.outputExtension = outputExtension
        self.fileManager = fileManager
    }

    mutating func resolve(relativePath: String) -> URL {
        let baseRelativePath = (relativePath as NSString).deletingPathExtension
        let relativeDirectory = (baseRelativePath as NSString).deletingLastPathComponent
        let baseName = (baseRelativePath as NSString).lastPathComponent
        let directoryURL = relativeDirectory.isEmpty
            ? outputFolder
            : outputFolder.appendingPathComponent(relativeDirectory, isDirectory: true)
        var candidate = directoryURL
            .appendingPathComponent(baseName)
            .appendingPathExtension(outputExtension)
            .standardizedFileURL
        var suffix = 1

        while fileManager.fileExists(atPath: candidate.path) || reservedPaths.contains(candidate.path) {
            candidate = directoryURL
                .appendingPathComponent("\(baseName) (\(suffix))")
                .appendingPathExtension(outputExtension)
                .standardizedFileURL
            suffix += 1
        }

        reservedPaths.insert(candidate.path)
        return candidate
    }
}
