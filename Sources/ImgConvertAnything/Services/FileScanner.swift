import Foundation

struct ScanSummary {
    var jobs: [ConversionJob]
    var skippedCount: Int
}

final class FileScanner {
    private let fileManager: FileManager
    private let probe: ImageDecodeProbe

    init(fileManager: FileManager = .default, probe: ImageDecodeProbe = ImageDecodeProbe()) {
        self.fileManager = fileManager
        self.probe = probe
    }

    func scan(inputs: [URL], outputFolder: URL, outputFormat: OutputFormat) -> ScanSummary {
        var resolver = OutputPathResolver(outputFolder: outputFolder, outputFormat: outputFormat, fileManager: fileManager)
        var jobs: [ConversionJob] = []

        for input in inputs {
            let standardizedInput = input.standardizedFileURL
            let values = try? standardizedInput.resourceValues(forKeys: [.isDirectoryKey, .isRegularFileKey])

            if values?.isDirectory == true {
                jobs.append(contentsOf: scanDirectory(standardizedInput, resolver: &resolver))
            } else if values?.isRegularFile == true {
                jobs.append(makeJob(for: standardizedInput, relativePath: standardizedInput.lastPathComponent, resolver: &resolver))
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

    private func scanDirectory(_ root: URL, resolver: inout OutputPathResolver) -> [ConversionJob] {
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
            jobs.append(makeJob(for: fileURL.standardizedFileURL, relativePath: relativePath, resolver: &resolver))
        }

        return jobs
    }

    private func makeJob(for sourceURL: URL, relativePath: String, resolver: inout OutputPathResolver) -> ConversionJob {
        guard probe.canDecodeImage(at: sourceURL) else {
            return ConversionJob(
                sourceURL: sourceURL,
                relativePath: relativePath,
                targetURL: nil,
                status: .skipped("macOS cannot decode this image")
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
