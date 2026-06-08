import SwiftUI
import UniformTypeIdentifiers

struct DropZoneView: View {
    let addURLs: ([URL]) -> Void
    @State private var isTargeted = false

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "square.and.arrow.down.on.square")
                .font(.system(size: 30, weight: .medium))
                .foregroundStyle(isTargeted ? .blue : .secondary)

            Text("Drop files or folders")
                .font(.headline)

            Text("RAW, JPEG, PNG, TIFF, HEIC, WebP, GIF, BMP")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(isTargeted ? Color.blue.opacity(0.12) : Color.secondary.opacity(0.08))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(isTargeted ? .blue : .secondary.opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
        )
        .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isTargeted) { providers in
            loadFileURLs(from: providers)
            return true
        }
    }

    private func loadFileURLs(from providers: [NSItemProvider]) {
        let group = DispatchGroup()
        let lock = NSLock()
        var urls: [URL] = []

        for provider in providers where provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
            group.enter()
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                defer { group.leave() }

                let url: URL?
                if let data = item as? Data {
                    url = URL(dataRepresentation: data, relativeTo: nil)
                } else if let itemURL = item as? URL {
                    url = itemURL
                } else if let itemURL = item as? NSURL {
                    url = itemURL as URL
                } else {
                    url = nil
                }

                if let url {
                    lock.lock()
                    urls.append(url.standardizedFileURL)
                    lock.unlock()
                }
            }
        }

        group.notify(queue: .main) {
            addURLs(urls)
        }
    }
}
