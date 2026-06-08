import SwiftUI

struct ConversionToolbarView: View {
    @ObservedObject var store: ConversionStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.triangle.2.circlepath.camera")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(.blue)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Image Convert Anything")
                            .font(.title2.weight(.semibold))
                        Text(store.outputFolder?.displayPath ?? "Choose an output folder")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }

                Spacer()

                Button {
                    store.presentOutputPanel()
                } label: {
                    Label("Output", systemImage: "folder.badge.plus")
                }

                Button {
                    store.startConversion()
                } label: {
                    Label("Convert", systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(!store.canConvert)

                Button {
                    store.cancelConversion()
                } label: {
                    Label("Cancel", systemImage: "stop.fill")
                }
                .disabled(!store.isConverting)
            }

            HStack(alignment: .center, spacing: 16) {
                LabeledContent("Output Format") {
                    Picker("Output Format", selection: $store.outputFormat) {
                        ForEach(OutputFormat.allCases) { format in
                            Label(format.displayName, systemImage: format.systemImageName)
                                .tag(format)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 170)
                }
                .frame(width: 300, alignment: .leading)
                .disabled(store.isConverting)

                Text(store.outputFormat.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 190, alignment: .leading)
                    .lineLimit(2)

                HStack(spacing: 10) {
                    Text("Quality")
                        .foregroundStyle(store.outputFormat.supportsQuality ? .primary : .secondary)
                    Slider(value: $store.jpegQuality, in: 0.1...1.0, step: 0.01)
                        .frame(width: 170)
                    Text("\(Int(store.jpegQuality * 100))%")
                        .monospacedDigit()
                        .frame(width: 42, alignment: .trailing)
                }
                .disabled(!store.outputFormat.supportsQuality || store.isConverting)

                Spacer()
            }
        }
    }
}

private extension OutputFormat {
    var systemImageName: String {
        switch self {
        case .png:
            return "photo"
        case .jpeg:
            return "camera"
        case .heic:
            return "iphone"
        case .tiff:
            return "archivebox"
        case .gif:
            return "sparkles"
        case .bmp:
            return "square.grid.3x3"
        case .jpeg2000:
            return "photo.on.rectangle"
        }
    }
}
