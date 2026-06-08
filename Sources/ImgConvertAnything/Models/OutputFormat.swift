import Foundation

enum OutputFormat: String, CaseIterable, Identifiable, Sendable {
    case png
    case jpeg
    case heic
    case tiff
    case gif
    case bmp
    case jpeg2000

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .png:
            return "PNG"
        case .jpeg:
            return "JPEG"
        case .heic:
            return "HEIC"
        case .tiff:
            return "TIFF"
        case .gif:
            return "GIF"
        case .bmp:
            return "BMP"
        case .jpeg2000:
            return "JPEG 2000"
        }
    }

    var detail: String {
        switch self {
        case .png:
            return "Lossless, broad compatibility"
        case .jpeg:
            return "Small files, adjustable quality"
        case .heic:
            return "Modern compressed photo format"
        case .tiff:
            return "High-quality archive format"
        case .gif:
            return "Single-frame GIF output"
        case .bmp:
            return "Bitmap output"
        case .jpeg2000:
            return "JPEG 2000 image"
        }
    }

    var fileExtension: String {
        switch self {
        case .png:
            return "png"
        case .jpeg:
            return "jpg"
        case .heic:
            return "heic"
        case .tiff:
            return "tiff"
        case .gif:
            return "gif"
        case .bmp:
            return "bmp"
        case .jpeg2000:
            return "jp2"
        }
    }

    var contentTypeIdentifier: String {
        switch self {
        case .png:
            return "public.png"
        case .jpeg:
            return "public.jpeg"
        case .heic:
            return "public.heic"
        case .tiff:
            return "public.tiff"
        case .gif:
            return "com.compuserve.gif"
        case .bmp:
            return "com.microsoft.bmp"
        case .jpeg2000:
            return "public.jpeg-2000"
        }
    }

    var supportsQuality: Bool {
        switch self {
        case .jpeg, .heic, .jpeg2000:
            return true
        case .png, .tiff, .gif, .bmp:
            return false
        }
    }
}
