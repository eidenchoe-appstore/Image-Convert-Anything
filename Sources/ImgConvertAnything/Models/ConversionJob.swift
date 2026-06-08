import Foundation

struct ConversionJob: Identifiable, Equatable {
    let id = UUID()
    let sourceURL: URL
    let relativePath: String
    let targetURL: URL?
    var status: ConversionStatus
}

enum ConversionStatus: Equatable {
    case queued
    case processing
    case succeeded
    case skipped(String)
    case failed(String)
    case cancelled

    var isTerminal: Bool {
        switch self {
        case .succeeded, .skipped, .failed, .cancelled:
            return true
        case .queued, .processing:
            return false
        }
    }

    var title: String {
        switch self {
        case .queued:
            return "Queued"
        case .processing:
            return "Converting"
        case .succeeded:
            return "Done"
        case .skipped:
            return "Skipped"
        case .failed:
            return "Failed"
        case .cancelled:
            return "Cancelled"
        }
    }

    var detail: String {
        switch self {
        case .skipped(let reason), .failed(let reason):
            return reason
        case .queued, .processing, .succeeded, .cancelled:
            return title
        }
    }
}
