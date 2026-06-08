import Foundation

struct ScanSummary {
    var jobs: [ConversionJob]
    var skippedCount: Int
}

final class FileScanner {
    private let fileManager: FileManager
    private let imageProbe: ImageDecodeProbe
    private let videoProbe: VideoDecodeProbe

    init(
        fileManager: FileManager = .default,
        imageProbe: ImageDecodeProbe = ImageDecodeProbe(),
        videoProbe: VideoDecodeProbe = VideoDecodeProbe()
    ) {
        self.fileManager = fileManager
        self.imageProbe = imageProbe
        self.videoProbe = videoProbe
    }

    func scan(inputs: [URL], outputFolder: URL, outputFormat: OutputFormat) -> ScanSummary {
        var resolver = OutputPathResolver(outputFolder: outputFolder, outputFormat: outputFormat, fileManager: fileManager)
        return scan(inputs: inputs, resolver: &resolver) { [imageProbe] url in
            imageProbe.canDecodeImage(at: url)
        } skippedReason: {
            "macOS cannot decode this image"
        }
    }

    func scan(inputs: [URL], outputFolder: URL, videoOutputFormat: VideoOutputFormat) -> ScanSummary {
        var resolver = OutputPathResolver(outputFolder: outputFolder, videoOutputFormat: videoOutputFormat, fileManager: fileManager)
        return scan(inputs: inputs, resolver: &resolver) { [videoProbe] url in
            videoProbe.canDecodeVideo(at: url)
        } skippedReason: {
            "This video format is not supported"
        }
    }

    private func scan(
        inputs: [URL],
        resolver: inout OutputPathResolver,
        canDecode: (URL) -> Bool,
        skippedReason: () -> String
    ) -> ScanSummary {
        var jobs: [ConversionJob] = []

        for input in inputs {
            let standardizedInput = input.standardizedFileURL
            let values = try? standardizedInput.resourceValues(forKeys: [.isDirectoryKey, .isRegularFileKey])

            if values?.isDirectory == true {
                jobs.append(contentsOf: scanDirectory(standardizedInput, resolver: &resolver, canDecode: canDecode, skippedReason: skippedReason))
            } else if values?.isRegularFile == true {
                jobs.append(makeJob(for: standardizedInput, relativePath: standardizedInput.lastPathComponent, resolver: &resolver, canDecode: canDecode, skippedReason: skippedReason))
            } else {
                jobs.append(
                    ConversionJob(
                        sourceURL: standardizedInput,
                        relativePath: standardizedInput.lastPathComponent,
                        targetURL: nil,
                        status: .skipped("Not a regular file")
                    )
                )
            }
        }

        return ScanSummary(
            jobs: jobs,
            skippedCount: jobs.filter { job in
                if case .skipped = job.status {
                    return true
                }
                return false
            }.count
        )
    }

    private func scanDirectory(
        _ root: URL,
        resolver: inout OutputPathResolver,
        canDecode: (URL) -> Bool,
        skippedReason: () -> String
    ) -> [ConversionJob] {
        guard let enumerator = fileManager.enumerator(
            at: root,
            includingPropertiesForKeys: [.isRegularFileKey, .isDirectoryKey, .isPackageKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            return [
                ConversionJob(
                    sourceURL: root,
                    relativePath: root.lastPathComponent,
                    targetURL: nil,
                    status: .skipped("Cannot open directory")
                )
            ]
        }

        var jobs: [ConversionJob] = []

        for case let fileURL as URL in enumerator {
            let values = try? fileURL.resourceValues(forKeys: [.isRegularFileKey])
            guard values?.isRegularFile == true else {
                continue
            }

            let relativePath = relativePath(for: fileURL.standardizedFileURL, under: root.standardizedFileURL)
            jobs.append(makeJob(for: fileURL.standardizedFileURL, relativePath: relativePath, resolver: &resolver, canDecode: canDecode, skippedReason: skippedReason))
        }

        return jobs
    }

    private func makeJob(
        for sourceURL: URL,
        relativePath: String,
        resolver: inout OutputPathResolver,
        canDecode: (URL) -> Bool,
        skippedReason: () -> String
    ) -> ConversionJob {
        guard canDecode(sourceURL) else {
            return ConversionJob(
                sourceURL: sourceURL,
                relativePath: relativePath,
                targetURL: nil,
                status: .skipped(skippedReason())
            )
        }

        return ConversionJob(
            sourceURL: sourceURL,
            relativePath: relativePath,
            targetURL: resolver.resolve(relativePath: relativePath),
            status: .queued
        )
    }

    private func relativePath(for fileURL: URL, under rootURL: URL) -> String {
        let rootPath = rootURL.path
        let filePath = fileURL.path
        let descendant: String

        if filePath.hasPrefix(rootPath + "/") {
            descendant = String(filePath.dropFirst(rootPath.count + 1))
        } else {
            descendant = fileURL.lastPathComponent
        }

        return [rootURL.lastPathComponent, descendant]
            .filter { !$0.isEmpty }
            .joined(separator: "/")
    }
}
