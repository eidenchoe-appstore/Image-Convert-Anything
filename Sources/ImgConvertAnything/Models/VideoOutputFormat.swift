import Foundation

enum VideoOutputFormat: String, CaseIterable, Identifiable, Sendable {
    case gif
    case webm

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .gif:
            return "GIF"
        case .webm:
            return "WebM"
        }
    }

    var detail: String {
        switch self {
        case .gif:
            return "Animated image for previews and sharing"
        case .webm:
            return "Compact web video using VP9"
        }
    }

    var fileExtension: String {
        switch self {
        case .gif:
            return "gif"
        case .webm:
            return "webm"
        }
    }
}
