import AppKit
import Foundation

@MainActor
final class ConversionStore: ObservableObject {
    @Published var mode: ConversionMode = .images {
        didSet {
            jobs.removeAll()
        }
    }

    @Published var imageInputURLs: [URL] = []
    @Published var videoInputURLs: [URL] = []
    @Published var outputFolder: URL?
    @Published var defaultOutputFolder: URL = ConversionStore.fallbackDefaultOutputFolder {
        didSet {
            defaults.set(defaultOutputFolder.path, forKey: Defaults.defaultOutputFolderPath)
        }
    }

    @Published var openOutputFolderAfterConversion = true {
        didSet {
            defaults.set(openOutputFolderAfterConversion, forKey: Defaults.openOutputFolderAfterConversion)
        }
    }

    @Published var imageOutputFormat: OutputFormat = .png
    @Published var imageQuality: Double = 0.9
    @Published var videoOutputFormat: VideoOutputFormat = .gif
    @Published var videoQuality: Double = 0.85
    @Published var videoFPS: Double = 12
    @Published var videoMaxWidth: Double = 720
    @Published var jobs: [ConversionJob] = []
    @Published var logs: [ConversionLogEntry] = []
    @Published var isScanning = false
    @Published var isConverting = false

    private enum Defaults {
        static let defaultOutputFolderPath = "defaultOutputFolderPath"
        static let openOutputFolderAfterConversion = "openOutputFolderAfterConversion"
    }

    private static var fallbackDefaultOutputFolder: URL {
        FileManager.default
            .urls(for: .picturesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("Image Convert Anything", isDirectory: true)
        ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Pictures/Image Convert Anything", isDirectory: true)
    }

    private let defaults = UserDefaults.standard
    private var runningTask: Task<Void, Never>?

    init() {
        if let path = defaults.string(forKey: Defaults.defaultOutputFolderPath), !path.isEmpty {
            defaultOutputFolder = URL(fileURLWithPath: path)
        } else {
            defaults.set(defaultOutputFolder.path, forKey: Defaults.defaultOutputFolderPath)
        }

        if defaults.object(forKey: Defaults.openOutputFolderAfterConversion) == nil {
            defaults.set(true, forKey: Defaults.openOutputFolderAfterConversion)
        } else {
            openOutputFolderAfterConversion = defaults.bool(forKey: Defaults.openOutputFolderAfterConversion)
        }
    }

    var activeInputURLs: [URL] {
        switch mode {
        case .images:
            return imageInputURLs
        case .videos:
            return videoInputURLs
        }
    }

    var effectiveOutputFolder: URL {
        outputFolder ?? defaultOutputFolder
    }

    var canConvert: Bool {
        !activeInputURLs.isEmpty && !isConverting
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
        panel.title = "Select \(mode.title) Or Folders"
        panel.prompt = "Add \(mode.title)"
        panel.message = "Choose \(mode.title.lowercased()) or folders. The app will scan folders recursively and convert supported files."
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
        panel.message = "Converted media will be written here for this session. Original files are never modified."
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.resolvesAliases = true

        if panel.runModal() == .OK {
            outputFolder = panel.urls.first
            if let outputFolder {
                addLog(.info, "Session output folder: \(outputFolder.path)")
            }
        }
    }

    func presentDefaultOutputPanel() {
        let panel = NSOpenPanel()
        panel.title = "Choose Default Output Folder"
        panel.prompt = "Save Default"
        panel.message = "This folder is used automatically when no session output folder is selected."
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.resolvesAliases = true

        if panel.runModal() == .OK, let url = panel.urls.first {
            defaultOutputFolder = url.standardizedFileURL
            addLog(.info, "Default output folder: \(defaultOutputFolder.path)")
        }
    }

    func clearSessionOutputFolder() {
        outputFolder = nil
        addLog(.info, "Using default output folder: \(defaultOutputFolder.path)")
    }

    func addInputURLs(_ urls: [URL]) {
        let standardized = urls.map(\.standardizedFileURL)
        var current = activeInputURLs
        var seen = Set(current.map(\.path))
        let newURLs = standardized.filter { url in
            seen.insert(url.path).inserted
        }

        current.append(contentsOf: newURLs)
        setActiveInputURLs(current)

        if !newURLs.isEmpty {
            addLog(.info, "Added \(newURLs.count) \(mode.title.lowercased()) input item(s)")
        }
    }

    func removeInputs(at offsets: IndexSet) {
        var current = activeInputURLs
        for index in offsets.sorted(by: >) {
            current.remove(at: index)
        }
        setActiveInputURLs(current)
    }

    func clearInputs() {
        setActiveInputURLs([])
        jobs.removeAll()
        addLog(.info, "Cleared \(mode.title.lowercased()) input list")
    }

    func clearLogs() {
        logs.removeAll()
    }

    func revealOutputFolder() {
        NSWorkspace.shared.open(effectiveOutputFolder)
    }

    func startConversion() {
        guard canConvert else {
            addLog(.warning, "No \(mode.title.lowercased()) input files or folders selected")
            return
        }

        runningTask?.cancel()
        let selectedMode = mode
        let inputs = activeInputURLs
        let destination = effectiveOutputFolder
        let selectedImageFormat = imageOutputFormat
        let selectedImageQuality = imageQuality
        let selectedVideoFormat = videoOutputFormat
        let selectedVideoSettings = VideoConversionSettings(
            fps: Int(videoFPS.rounded()),
            maxWidth: Int(videoMaxWidth.rounded()),
            quality: videoQuality
        )
        let shouldOpenOutput = openOutputFolderAfterConversion

        isScanning = true
        isConverting = true
        jobs.removeAll()
        addLog(.info, "Scanning \(inputs.count) \(selectedMode.title.lowercased()) input item(s)")
        addLog(.info, "Output folder: \(destination.path)")

        runningTask = Task { [weak self] in
            guard let self else {
                return
            }

            let scanSummary = await Task.detached(priority: .userInitiated) {
                switch selectedMode {
                case .images:
                    return FileScanner().scan(inputs: inputs, outputFolder: destination, outputFormat: selectedImageFormat)
                case .videos:
                    return FileScanner().scan(inputs: inputs, outputFolder: destination, videoOutputFormat: selectedVideoFormat)
                }
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
                addLog(.warning, "No supported \(selectedMode.title.lowercased()) files found")
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
                        switch selectedMode {
                        case .images:
                            try ImageConversionService().convert(
                                sourceURL: sourceURL,
                                targetURL: targetURL,
                                format: selectedImageFormat,
                                jpegQuality: selectedImageQuality
                            )
                        case .videos:
                            try VideoConversionService().convert(
                                sourceURL: sourceURL,
                                targetURL: targetURL,
                                format: selectedVideoFormat,
                                settings: selectedVideoSettings
                            )
                        }
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

            let completedSuccessCount = successCount
            isConverting = false
            isScanning = false
            runningTask = nil
            addLog(.info, "Finished. Success \(successCount), skipped \(skippedCount), failed \(failedCount), cancelled \(cancelledCount)")

            if shouldOpenOutput && completedSuccessCount > 0 {
                NSWorkspace.shared.open(destination)
            }
        }
    }

    func cancelConversion() {
        runningTask?.cancel()
    }

    private func setActiveInputURLs(_ urls: [URL]) {
        switch mode {
        case .images:
            imageInputURLs = urls
        case .videos:
            videoInputURLs = urls
        }
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
