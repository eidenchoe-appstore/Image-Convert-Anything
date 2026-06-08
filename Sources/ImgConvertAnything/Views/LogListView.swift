import SwiftUI

struct LogListView: View {
    let logs: [ConversionLogEntry]
    let clearAction: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                Button {
                    clearAction()
                } label: {
                    Label("Clear", systemImage: "trash")
                }
                .disabled(logs.isEmpty)
            }

            if logs.isEmpty {
                ContentUnavailableView("No Logs", systemImage: "text.alignleft")
            } else {
                List(logs) { entry in
                    HStack(alignment: .top, spacing: 8) {
                        Text(DateFormatting.logTimeFormatter.string(from: entry.date))
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .frame(width: 72, alignment: .leading)

                        Text(entry.level.rawValue)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(levelColor(entry.level))
                            .frame(width: 58, alignment: .leading)

                        Text(entry.message)
                            .font(.caption)
                            .textSelection(.enabled)
                    }
                    .padding(.vertical, 2)
                }
                .listStyle(.inset)
            }
        }
        .padding(.top, 8)
    }

    private func levelColor(_ level: LogLevel) -> Color {
        switch level {
        case .info:
            return .secondary
        case .success:
            return .green
        case .warning:
            return .orange
        case .error:
            return .red
        }
    }
}
