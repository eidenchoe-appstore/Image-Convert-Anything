import SwiftUI

struct ConversionToolbarView: View {
    @ObservedObject var store: ConversionStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            controls
        }
    }

    private var header: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: 12) {
                titleBlock
                Spacer(minLength: 12)
                actionButtons
            }

            VStack(alignment: .leading, spacing: 12) {
                titleBlock
                actionButtons
            }
        }
    }

    private var titleBlock: some View {
        HStack(spacing: 12) {
            Image(systemName: store.mode == .images ? "photo.stack" : "film.stack")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(store.mode == .images ? .blue : .purple)
                .frame(width: 34)

            VStack(alignment: .leading, spacing: 4) {
                Text(store.mode == .images ? "Image Converter" : "Video Converter")
                    .font(.title2.weight(.semibold))
                Text(store.outputFolder?.displayPath ?? "Default: \(store.defaultOutputFolder.displayPath)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 8) {
            Button {
                store.presentOutputPanel()
            } label: {
                Label("Session Output", systemImage: "folder.badge.plus")
            }

            Button {
                store.clearSessionOutputFolder()
            } label: {
                Image(systemName: "arrow.counterclockwise")
            }
            .help("Use default output folder")
            .disabled(store.outputFolder == nil || store.isConverting)

            SettingsLink {
                Image(systemName: "gearshape")
            }
            .help("Settings")

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
    }

    private var controls: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 18) {
                formatControl
                qualityControl
                if store.mode == .videos {
                    videoSizingControl
                    ffmpegStatus
                }
                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 12) {
                formatControl
                qualityControl
                if store.mode == .videos {
                    videoSizingControl
                    ffmpegStatus
                }
            }
        }
    }

    @ViewBuilder
    private var formatControl: some View {
        if store.mode == .images {
            LabeledContent("Output Format") {
                Picker("Output Format", selection: $store.imageOutputFormat) {
                    ForEach(OutputFormat.allCases) { format in
                        Label(format.displayName, systemImage: format.systemImageName)
                            .tag(format)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 170)
            }
            .frame(minWidth: 260, idealWidth: 300, maxWidth: 340, alignment: .leading)
            .disabled(store.isConverting)

            Text(store.imageOutputFormat.detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(minWidth: 150, idealWidth: 190, maxWidth: 230, alignment: .leading)
                .lineLimit(2)
        } else {
            LabeledContent("Output Format") {
                Picker("Output Format", selection: $store.videoOutputFormat) {
                    ForEach(VideoOutputFormat.allCases) { format in
                        Label(format.displayName, systemImage: format.systemImageName)
                            .tag(format)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 170)
            }
            .frame(minWidth: 260, idealWidth: 300, maxWidth: 340, alignment: .leading)
            .disabled(store.isConverting)

            Text(store.videoOutputFormat.detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(minWidth: 150, idealWidth: 190, maxWidth: 230, alignment: .leading)
                .lineLimit(2)
        }
    }

    private var qualityControl: some View {
        let supportsQuality = store.mode == .images
            ? store.imageOutputFormat.supportsQuality
            : store.videoOutputFormat.supportsQuality

        return HStack(spacing: 10) {
            Text("Quality")
                .foregroundStyle(supportsQuality ? .primary : .secondary)
            Slider(
                value: store.mode == .images ? $store.imageQuality : $store.videoQuality,
                in: 0.1...1.0,
                step: 0.01
            )
            .frame(minWidth: 120, idealWidth: 170, maxWidth: 220)
            Text("\(Int((store.mode == .images ? store.imageQuality : store.videoQuality) * 100))%")
                .monospacedDigit()
                .frame(width: 42, alignment: .trailing)
        }
        .disabled(!supportsQuality || store.isConverting)
    }

    private var videoSizingControl: some View {
        HStack(spacing: 12) {
            Stepper("FPS \(Int(store.videoFPS))", value: $store.videoFPS, in: 1...30, step: 1)
                .frame(width: 110, alignment: .leading)
            Stepper("Width \(Int(store.videoMaxWidth))", value: $store.videoMaxWidth, in: 240...1920, step: 120)
                .frame(width: 140, alignment: .leading)
        }
        .disabled(store.isConverting)
    }

    private var ffmpegStatus: some View {
        let isAvailable = FFmpegLocator.findFFmpeg() != nil

        return HStack(spacing: 6) {
            Circle()
                .fill(isAvailable ? .green : .orange)
                .frame(width: 7, height: 7)
            Text(isAvailable ? "ffmpeg ready" : "Install ffmpeg")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.quaternary, in: Capsule())
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

private extension VideoOutputFormat {
    var systemImageName: String {
        switch self {
        case .gif:
            return "sparkles"
        case .webm:
            return "globe"
        }
    }

    var supportsQuality: Bool {
        switch self {
        case .webm:
            return true
        case .gif:
            return false
        }
    }
}
