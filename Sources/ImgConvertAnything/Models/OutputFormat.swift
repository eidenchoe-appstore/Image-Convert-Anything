import Foundation
import UniformTypeIdentifiers

enum OutputFormat: String, CaseIterable, Identifiable, Sendable {
    case jpeg
    case png

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .jpeg:
            return "JPEG"
        case .png:
            return "PNG"
        }
    }

    var fileExtension: String {
        switch self {
        case .jpeg:
            return "jpg"
        case .png:
            return "png"
        }
    }

    var contentType: UTType {
        switch self {
        case .jpeg:
            return .jpeg
        case .png:
            return .png
        }
    }
}
