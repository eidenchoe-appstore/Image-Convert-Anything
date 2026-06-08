import CoreImage
import Foundation
import ImageIO

final class ImageDecodeProbe {
    func canDecodeImage(at url: URL) -> Bool {
        if CIImage(contentsOf: url, options: [.applyOrientationProperty: true]) != nil {
            return true
        }

        guard let source = CGImageSourceCreateWithURL(url as CFURL, [
            kCGImageSourceShouldCache: false
        ] as CFDictionary) else {
            return false
        }

        return CGImageSourceGetCount(source) > 0 && CGImageSourceGetType(source) != nil
    }
}
