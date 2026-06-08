import CoreImage
import Foundation
import ImageIO

enum ImageConversionError: LocalizedError {
    case cannotDecode
    case cannotRender
    case cannotEncode

    var errorDescription: String? {
        switch self {
        case .cannotDecode:
            return "Cannot decode source image"
        case .cannotRender:
            return "Cannot render source image"
        case .cannotEncode:
            return "Cannot encode output image"
        }
    }
}

final class ImageConversionService {
    private let fileManager: FileManager
    private let context: CIContext

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.context = CIContext(options: [.useSoftwareRenderer: false])
    }

    func convert(sourceURL: URL, targetURL: URL, format: OutputFormat, jpegQuality: Double) throws {
        let image = try loadImage(from: sourceURL)
        let outputDirectory = targetURL.deletingLastPathComponent()
        try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

        guard !image.extent.isInfinite, !image.extent.isEmpty else {
            throw ImageConversionError.cannotRender
        }

        guard let renderedImage = context.createCGImage(image, from: image.extent.integral) else {
            throw ImageConversionError.cannotRender
        }

        let outputData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            outputData,
            format.contentType.identifier as CFString,
            1,
            nil
        ) else {
            throw ImageConversionError.cannotEncode
        }

        let options: CFDictionary?
        switch format {
        case .jpeg:
            let quality = min(max(jpegQuality, 0.1), 1.0)
            options = [
                kCGImageDestinationLossyCompressionQuality: quality
            ] as CFDictionary
        case .png:
            options = nil
        }

        CGImageDestinationAddImage(destination, renderedImage, options)

        guard CGImageDestinationFinalize(destination) else {
            throw ImageConversionError.cannotEncode
        }

        try (outputData as Data).write(to: targetURL, options: [.atomic])
    }

    private func loadImage(from url: URL) throws -> CIImage {
        if let image = CIImage(contentsOf: url, options: [.applyOrientationProperty: true]) {
            return image
        }

        guard
            let source = CGImageSourceCreateWithURL(url as CFURL, nil),
            let cgImage = CGImageSourceCreateImageAtIndex(source, 0, [
                kCGImageSourceShouldCache: true
            ] as CFDictionary)
        else {
            throw ImageConversionError.cannotDecode
        }

        return CIImage(cgImage: cgImage)
    }
}
