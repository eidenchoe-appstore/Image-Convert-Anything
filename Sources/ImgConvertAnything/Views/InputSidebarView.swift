import SwiftUI

struct InputSidebarView: View {
    @ObservedObject var store: ConversionStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Inputs")
                    .font(.title3.weight(.semibold))
                Text("Add files or folders with Finder, or drop them below.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                Button {
                    store.presentInputPanel()
                } label: {
                    Label("Add Files/Folders", systemImage: "plus")
                }

                Button {
                    store.clearInputs()
                } label: {
                    Image(systemName: "trash")
                }
                .help("Clear inputs")
                .disabled(store.inputURLs.isEmpty || store.isConverting)
            }

            DropZoneView(addURLs: store.addInputURLs)

            Text("Supported when macOS can decode it: RAW, JPEG, PNG, TIFF, HEIC, WebP, GIF, BMP, and more.")
                .font(.caption)
                .foregroundStyle(.secondary)

            List {
                ForEach(store.inputURLs, id: \.self) { url in
                    InputRowView(url: url)
                        .padding(.vertical, 2)
                }
                .onDelete(perform: store.removeInputs)
            }
            .listStyle(.sidebar)
        }
        .padding(16)
    }
}

private struct InputRowView: View {
    let url: URL

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: url.isDirectoryURL ? "folder" : "photo")
                .foregroundStyle(url.isDirectoryURL ? .blue : .secondary)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(url.lastPathComponent)
                    .lineLimit(1)
                Text(url.deletingLastPathComponent().displayPath)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
    }
}
