import SwiftUI

struct ConversionToolbarView: View {
    @ObservedObject var store: ConversionStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Image Convert Anything")
                        .font(.title2.weight(.semibold))
                    Text(store.outputFolder?.displayPath ?? "No output folder selected")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
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

            HStack(spacing: 18) {
                Picker("Format", selection: $store.outputFormat) {
                    ForEach(OutputFormat.allCases) { format in
                        Text(format.displayName).tag(format)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
                .disabled(store.isConverting)

                HStack(spacing: 10) {
                    Text("JPEG Quality")
                        .foregroundStyle(store.outputFormat == .jpeg ? .primary : .secondary)
                    Slider(value: $store.jpegQuality, in: 0.1...1.0, step: 0.01)
                        .frame(width: 180)
                    Text("\(Int(store.jpegQuality * 100))%")
                        .monospacedDigit()
                        .frame(width: 42, alignment: .trailing)
                }
                .disabled(store.outputFormat != .jpeg || store.isConverting)

                Spacer()
            }
        }
    }
}
