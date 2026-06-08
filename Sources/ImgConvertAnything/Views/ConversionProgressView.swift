import SwiftUI

struct ConversionProgressView: View {
    @ObservedObject var store: ConversionStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.isScanning ? "Scanning" : store.isConverting ? "Converting" : "Ready")
                        .font(.headline)

                    Text("\(store.processedCount) of \(store.jobs.count) processed")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    store.revealOutputFolder()
                } label: {
                    Label("Open Output", systemImage: "folder")
                }
                .disabled(store.outputFolder == nil)
            }

            ProgressView(value: store.progressValue)

            HStack(spacing: 10) {
                StatPill(title: "Done", value: store.successCount, color: .green)
                StatPill(title: "Skipped", value: store.skippedCount, color: .orange)
                StatPill(title: "Failed", value: store.failedCount, color: .red)
                StatPill(title: "Cancelled", value: store.cancelledCount, color: .secondary)
                Spacer()
            }
        }
    }
}

private struct StatPill: View {
    let title: String
    let value: Int
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
            Text(title)
                .foregroundStyle(.secondary)
            Text("\(value)")
                .fontWeight(.semibold)
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.quaternary, in: Capsule())
    }
}
