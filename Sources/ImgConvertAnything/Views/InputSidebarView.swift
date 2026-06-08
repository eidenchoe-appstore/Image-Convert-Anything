import SwiftUI

struct InputSidebarView: View {
    @ObservedObject var store: ConversionStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Picker("Mode", selection: $store.mode) {
                ForEach(ConversionMode.allCases) { mode in
                    Label(mode.title, systemImage: mode.systemImageName)
                        .tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .disabled(store.isConverting)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(store.mode.title) Inputs")
                    .font(.title3.weight(.semibold))
                Text("Add files or folders with Finder, or drop them below.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                Button {
                    store.presentInputPanel()
                } label: {
                    Label("Add \(store.mode.title)", systemImage: "plus")
                }

                Button {
                    store.clearInputs()
                } label: {
                    Image(systemName: "trash")
                }
                .help("Clear inputs")
                .disabled(store.activeInputURLs.isEmpty || store.isConverting)
            }

            DropZoneView(mode: store.mode, addURLs: store.addInputURLs)

            Text("Supported: \(store.mode.inputSummary)")
                .font(.caption)
                .foregroundStyle(.secondary)

            List {
                ForEach(store.activeInputURLs, id: \.self) { url in
                    InputRowView(url: url, mode: store.mode)
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
    let mode: ConversionMode

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
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

    private var iconName: String {
        if url.isDirectoryURL {
            return "folder"
        }

        switch mode {
        case .images:
            return "photo"
        case .videos:
            return "film"
        }
    }
}
