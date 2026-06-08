import AppKit
import Foundation

@MainActor
final class ConversionStore: ObservableObject {
    @Published var inputURLs: [URL] = []
    @Published var outputFolder: URL?
    @Published var outputFormat: OutputFormat = .png
    @Published var jpegQuality: Double = 0.9
    @Published var jobs: [ConversionJob] = []
    @Published var logs: [ConversionLogEntry] = []
    @Published var isScanning = false
    @Published var isConverting = false

    private var runningTask: Task<Void, Never>?

    var canConvert: Bool {
        !inputURLs.isEmpty && outputFolder != nil && !isConverting
    }

    var processedCount: Int {
        jobs.filter(\.status.isTerminal).count
    }

    var successCount: Int {
        jobs.filter { $0.status == .succeeded }.count
    }

    var skippedCount: Int {
        jobs.filter { job in
            if case .skipped = job.status {
                return true
            }
            return false
        }.count
    }

    var failedCount: Int {
        jobs.filter { job in
            if case .failed = job.status {
                return true
            }
            return false
        }.count
    }

    var cancelledCount: Int {
        jobs.filter { $0.status == .cancelled }.count
    }

    var progressValue: Double {
        guard !jobs.isEmpty else {
            return 0
        }

        return Double(processedCount) / Double(jobs.count)
    }

    func presentInputPanel() {
        let panel = NSOpenPanel()
        panel.title = "Select Input Files Or Folders"
        panel.prompt = "Add Inputs"
        panel.message = "Choose any image files or folders. The app will scan folders recursively and convert files that macOS can decode."
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        panel.resolvesAliases = true

        if panel.runModal() == .OK {
            addInputURLs(panel.urls)
        }
    }

    func presentOutputPanel() {
        let panel = NSOpenPanel()
        panel.title = "Choose Output Folder"
        panel.prompt = "Use Folder"
        panel.message = "Converted images will be written here. Original files are never modified."
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.resolvesAliases = true

        if panel.runModal() == .OK {
            outputFolder = panel.urls.first
            if let outputFolder {
                addLog(.info, "Output folder: \(outputFolder.path)")
            }
        }
    }

    func addInputURLs(_ urls: [URL]) {
        let standardized = urls.map(\.standardizedFileURL)
        var seen = Set(inputURLs.map(\.path))
        let newURLs = standardized.filter { url in
            seen.insert(url.path).inserted
        }
        inputURLs.append(contentsOf: newURLs)

        if !newURLs.isEmpty {
            addLog(.info, "Added \(newURLs.count) input item(s)")
        }
    }

    func removeInputs(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            inputURLs.remove(at: index)
        }
    }

    func clearInputs() {
        inputURLs.removeAll()
        jobs.removeAll()
        addLog(.info, "Cleared input list")
    }

    func clearLogs() {
        logs.removeAll()
    }

    func revealOutputFolder() {
        guard let outputFolder else {
            return
        }

        NSWorkspace.shared.open(outputFolder)
    }

    func startConversion() {
        guard canConvert, let outputFolder else {
            if inputURLs.isEmpty {
                addLog(.warning, "No input files or folders selected")
            } else if self.outputFolder == nil {
                addLog(.warning, "No output folder selected")
            }
            return
        }

        runningTask?.cancel()
        let inputs = inputURLs
        let selectedFormat = outputFormat
        let selectedQuality = jpegQuality

        isScanning = true
        isConverting = true
        jobs.removeAll()
        addLog(.info, "Scanning \(inputs.count) input item(s)")

        runningTask = Task { [weak self] in
            guard let self else {
                return
            }

            let scanSummary = await Task.detached(priority: .userInitiated) {
                FileScanner().scan(inputs: inputs, outputFolder: outputFolder, outputFormat: selectedFormat)
            }.value

            if Task.isCancelled {
                finishCancelled()
                return
            }

            jobs = scanSummary.jobs
            isScanning = false
            addLog(.info, "Prepared \(jobs.count) file(s), skipped \(scanSummary.skippedCount)")

            if jobs.isEmpty {
                isConverting = false
                runningTask = nil
                addLog(.warning, "No decodable image files found")
                return
            }

            for index in jobs.indices {
                if Task.isCancelled {
                    markRemainingCancelled(startingAt: index)
                    addLog(.warning, "Conversion cancelled")
                    break
                }

                guard jobs[index].status == .queued, let targetURL = jobs[index].targetURL else {
                    continue
                }

                let sourceURL = jobs[index].sourceURL
                jobs[index].status = .processing

                do {
                    try await Task.detached(priority: .userInitiated) {
                        try ImageConversionService().convert(
                            sourceURL: sourceURL,
                            targetURL: targetURL,
                            format: selectedFormat,
                            jpegQuality: selectedQuality
                        )
                    }.value

                    if Task.isCancelled {
                        jobs[index].status = .cancelled
                        addLog(.warning, "Cancelled: \(sourceURL.lastPathComponent)")
                    } else {
                        jobs[index].status = .succeeded
                        addLog(.success, "Converted: \(sourceURL.lastPathComponent)")
                    }
                } catch {
                    jobs[index].status = .failed(error.localizedDescription)
                    addLog(.error, "Failed: \(sourceURL.lastPathComponent) - \(error.localizedDescription)")
                }
            }

            isConverting = false
            isScanning = false
            runningTask = nil
            addLog(.info, "Finished. Success \(successCount), skipped \(skippedCount), failed \(failedCount), cancelled \(cancelledCount)")
        }
    }

    func cancelConversion() {
        runningTask?.cancel()
    }

    private func finishCancelled() {
        isConverting = false
        isScanning = false
        runningTask = nil
        addLog(.warning, "Conversion cancelled")
    }

    private func markRemainingCancelled(startingAt index: Int) {
        guard index < jobs.count else {
            return
        }

        for remainingIndex in index..<jobs.count where jobs[remainingIndex].status == .queued {
            jobs[remainingIndex].status = .cancelled
        }
    }

    private func addLog(_ level: LogLevel, _ message: String) {
        logs.append(ConversionLogEntry(level: level, message: message))

        if logs.count > 1000 {
            logs.removeFirst(logs.count - 1000)
        }
    }
}
