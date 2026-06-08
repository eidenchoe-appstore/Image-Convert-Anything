// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "ImgConvertAnything",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "ImgConvertAnything",
            targets: ["ImgConvertAnything"]
        )
    ],
    targets: [
        .executableTarget(
            name: "ImgConvertAnything",
            path: "Sources/ImgConvertAnything",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("CoreImage"),
                .linkedFramework("ImageIO"),
                .linkedFramework("SwiftUI"),
                .linkedFramework("UniformTypeIdentifiers")
            ]
        )
    ]
)
