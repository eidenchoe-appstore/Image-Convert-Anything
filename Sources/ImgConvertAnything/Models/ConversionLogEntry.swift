import Foundation

struct ConversionLogEntry: Identifiable, Equatable {
    let id = UUID()
    let date = Date()
    let level: LogLevel
    let message: String
}

enum LogLevel: String, Equatable {
    case info = "Info"
    case success = "Success"
    case warning = "Warning"
    case error = "Error"
}
