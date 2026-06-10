import Foundation

struct VideoConversionSettings: Sendable {
    let fps: Int
    let maxWidth: Int
    let quality: Double
}

enum VideoConversionError: LocalizedError {
    case ffmpegNotFound
    case ffmpegFailed(String)

    var errorDescription: String? {
        switch self {
        case .ffmpegNotFound:
            return "ffmpeg was not found. Install it with Homebrew to enable video conversion."
        case .ffmpegFailed(let message):
            return message.isEmpty ? "ffmpeg failed to convert this video" : message
        }
    }
}

final class VideoConversionService {
    private let fileManager: FileManager
    private let ffmpegURL: URL?

    init(fileManager: FileManager = .default, ffmpegURL: URL? = FFmpegLocator.findFFmpeg()) {
        self.fileManager = fileManager
        self.ffmpegURL = ffmpegURL
    }

    func convert(
        sourceURL: URL,
        targetURL: URL,
        format: VideoOutputFormat,
        settings: VideoConversionSettings
    ) throws {
        guard let ffmpegURL else {
            throw VideoConversionError.ffmpegNotFound
        }

        let outputDirectory = targetURL.deletingLastPathComponent()
        try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

        let maxWidth = max(160, settings.maxWidth)
        let fps = max(1, settings.fps)
        let scaleFilter = "scale='min(\(maxWidth),iw)':-2:flags=lanczos,fps=\(fps)"
        let arguments: [String]

        switch format {
        case .gif:
            arguments = [
                "-y",
                "-i", sourceURL.path,
                "-vf", scaleFilter,
                "-loop", "0",
                targetURL.path
            ]
        case .mp4:
            arguments = h264Arguments(
                sourceURL: sourceURL,
                targetURL: targetURL,
                scaleFilter: scaleFilter,
                quality: settings.quality,
                extraArguments: ["-movflags", "+faststart"]
            )
        case .mov:
            arguments = h264Arguments(
                sourceURL: sourceURL,
                targetURL: targetURL,
                scaleFilter: scaleFilter,
                quality: settings.quality,
                extraArguments: []
            )
        case .m4v:
            arguments = h264Arguments(
                sourceURL: sourceURL,
                targetURL: targetURL,
                scaleFilter: scaleFilter,
                quality: settings.quality,
                extraArguments: ["-movflags", "+faststart"]
            )
        case .avi:
            let quality = min(max(settings.quality, 0.1), 1.0)
            let qscale = Int((31.0 - (quality * 29.0)).rounded())
            arguments = [
                "-y",
                "-i", sourceURL.path,
                "-vf", scaleFilter,
                "-c:v", "mpeg4",
                "-q:v", "\(qscale)",
                "-c:a", "libmp3lame",
                "-b:a", "160k",
                targetURL.path
            ]
        case .mkv:
            arguments = h264Arguments(
                sourceURL: sourceURL,
                targetURL: targetURL,
                scaleFilter: scaleFilter,
                quality: settings.quality,
                extraArguments: []
            )
        case .webm:
            let quality = min(max(settings.quality, 0.1), 1.0)
            let crf = Int((45.0 - (quality * 25.0)).rounded())
            arguments = [
                "-y",
                "-i", sourceURL.path,
                "-vf", scaleFilter,
                "-c:v", "libvpx-vp9",
                "-crf", "\(crf)",
                "-b:v", "0",
                "-c:a", "libopus",
                "-b:a", "128k",
                targetURL.path
            ]
        }

        try runFFmpeg(executableURL: ffmpegURL, arguments: arguments)
    }

    private func runFFmpeg(executableURL: URL, arguments: [String]) throws {
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments

        let pipe = Pipe()
        process.standardOutput = Pipe()
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let message = String(data: data, encoding: .utf8)?
                .split(separator: "\n")
                .suffix(4)
                .joined(separator: "\n") ?? ""
            throw VideoConversionError.ffmpegFailed(message)
        }
    }

    private func h264Arguments(
        sourceURL: URL,
        targetURL: URL,
        scaleFilter: String,
        quality: Double,
        extraArguments: [String]
    ) -> [String] {
        let clampedQuality = min(max(quality, 0.1), 1.0)
        let crf = Int((35.0 - (clampedQuality * 17.0)).rounded())

        return [
            "-y",
            "-i", sourceURL.path,
            "-vf", scaleFilter,
            "-c:v", "libx264",
            "-preset", "medium",
            "-crf", "\(crf)",
            "-pix_fmt", "yuv420p",
            "-c:a", "aac",
            "-b:a", "160k"
        ] + extraArguments + [
            targetURL.path
        ]
    }
}

enum FFmpegLocator {
    static func findFFmpeg() -> URL? {
        let candidates = [
            "/opt/homebrew/bin/ffmpeg",
            "/usr/local/bin/ffmpeg",
            "/usr/bin/ffmpeg"
        ]

        for path in candidates where FileManager.default.isExecutableFile(atPath: path) {
            return URL(fileURLWithPath: path)
        }

        let pathDirectories = ProcessInfo.processInfo.environment["PATH"]?
            .split(separator: ":")
            .map(String.init) ?? []

        for directory in pathDirectories {
            let candidate = URL(fileURLWithPath: directory).appendingPathComponent("ffmpeg")
            if FileManager.default.isExecutableFile(atPath: candidate.path) {
                return candidate
            }
        }

        return nil
    }
}
