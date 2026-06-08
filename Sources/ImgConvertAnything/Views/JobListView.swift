import SwiftUI

struct JobListView: View {
    let jobs: [ConversionJob]

    var body: some View {
        if jobs.isEmpty {
            ContentUnavailableView("No Jobs", systemImage: "photo.stack", description: Text("Add input and start conversion."))
        } else {
            List(jobs) { job in
                JobRowView(job: job)
                    .padding(.vertical, 3)
            }
            .listStyle(.inset)
        }
    }
}

private struct JobRowView: View {
    let job: ConversionJob

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: statusIconName)
                .foregroundStyle(statusColor)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 3) {
                Text(job.sourceURL.lastPathComponent)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(job.relativePath)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(job.status.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(statusColor)

                if let targetURL = job.targetURL {
                    Text(targetURL.lastPathComponent)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else {
                    Text(job.status.detail)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }

    private var statusIconName: String {
        switch job.status {
        case .queued:
            return "clock"
        case .processing:
            return "arrow.triangle.2.circlepath"
        case .succeeded:
            return "checkmark.circle.fill"
        case .skipped:
            return "forward.circle"
        case .failed:
            return "xmark.octagon.fill"
        case .cancelled:
            return "stop.circle"
        }
    }

    private var statusColor: Color {
        switch job.status {
        case .queued:
            return .secondary
        case .processing:
            return .blue
        case .succeeded:
            return .green
        case .skipped:
            return .orange
        case .failed:
            return .red
        case .cancelled:
            return .secondary
        }
    }
}
