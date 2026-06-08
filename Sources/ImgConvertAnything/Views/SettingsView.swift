import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: ConversionStore

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Default Output Folder")
                        .font(.headline)

                    Text(store.defaultOutputFolder.displayPath)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .truncationMode(.middle)

                    Button {
                        store.presentDefaultOutputPanel()
                    } label: {
                        Label("Choose Default Folder", systemImage: "folder.badge.gearshape")
                    }
                }

                Toggle("Open output folder after successful conversion", isOn: $store.openOutputFolderAfterConversion)
            }

            Section {
                HStack {
                    Circle()
                        .fill(FFmpegLocator.findFFmpeg() == nil ? .orange : .green)
                        .frame(width: 8, height: 8)
                    Text(FFmpegLocator.findFFmpeg() == nil ? "ffmpeg not found" : "ffmpeg ready for GIF/WebM video conversion")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(width: 560)
    }
}
