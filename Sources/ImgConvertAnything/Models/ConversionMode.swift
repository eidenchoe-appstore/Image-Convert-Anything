import Foundation

enum ConversionMode: String, CaseIterable, Identifiable {
    case images
    case videos

    var id: String { rawValue }

    var title: String {
        switch self {
        case .images:
            return "Images"
        case .videos:
            return "Videos"
        }
    }

    var systemImageName: String {
        switch self {
        case .images:
            return "photo.stack"
        case .videos:
            return "film.stack"
        }
    }

    var inputSummary: String {
        switch self {
        case .images:
            return "RAW, JPEG, PNG, TIFF, HEIC, WebP, GIF, BMP"
        case .videos:
            return "MOV, MP4, M4V, AVI, MKV, WebM"
        }
    }
}
