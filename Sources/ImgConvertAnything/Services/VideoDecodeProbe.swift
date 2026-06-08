import Foundation

final class VideoDecodeProbe {
    private let supportedExtensions: Set<String> = [
        "mov", "mp4", "m4v", "avi", "mkv", "webm", "mpeg", "mpg", "3gp", "3g2"
    ]

    func canDecodeVideo(at url: URL) -> Bool {
        supportedExtensions.contains(url.pathExtension.lowercased())
    }
}
