import Foundation

enum VideoOutputFormat: String, CaseIterable, Identifiable, Sendable {
    case gif
    case mp4
    case mov
    case m4v
    case avi
    case mkv
    case webm

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .gif:
            return "GIF"
        case .mp4:
            return "MP4"
        case .mov:
            return "MOV"
        case .m4v:
            return "M4V"
        case .avi:
            return "AVI"
        case .mkv:
            return "MKV"
        case .webm:
            return "WebM"
        }
    }

    var detail: String {
        switch self {
        case .gif:
            return "Animated image for previews and sharing"
        case .mp4:
            return "H.264 video for broad compatibility"
        case .mov:
            return "QuickTime video for macOS workflows"
        case .m4v:
            return "Apple-friendly H.264 video"
        case .avi:
            return "Legacy AVI container"
        case .mkv:
            return "Flexible Matroska video container"
        case .webm:
            return "Compact web video using VP9"
        }
    }

    var fileExtension: String {
        switch self {
        case .gif:
            return "gif"
        case .mp4:
            return "mp4"
        case .mov:
            return "mov"
        case .m4v:
            return "m4v"
        case .avi:
            return "avi"
        case .mkv:
            return "mkv"
        case .webm:
            return "webm"
        }
    }

    var supportsQuality: Bool {
        switch self {
        case .gif:
            return false
        case .mp4, .mov, .m4v, .avi, .mkv, .webm:
            return true
        }
    }

    var preservesAudio: Bool {
        switch self {
        case .gif:
            return false
        case .mp4, .mov, .m4v, .avi, .mkv, .webm:
            return true
        }
    }
}
