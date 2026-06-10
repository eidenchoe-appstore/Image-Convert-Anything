# Image Convert Anything

A small macOS batch converter for images and videos. Drop files or folders, choose an output format, and let the app preserve your folder structure while converting.

[![Latest Release](https://img.shields.io/github/v/release/eidenchoe-appstore/Image-Convert-Anything?label=release)](https://github.com/eidenchoe-appstore/Image-Convert-Anything/releases/latest)
[![Download DMG](https://img.shields.io/badge/download-DMG-blue)](https://github.com/eidenchoe-appstore/Image-Convert-Anything/releases/latest/download/ImageConvertAnything.dmg)
[![macOS](https://img.shields.io/badge/macOS-14%2B-lightgrey)](#requirements)

## Download

[Download ImageConvertAnything.dmg](https://github.com/eidenchoe-appstore/Image-Convert-Anything/releases/latest/download/ImageConvertAnything.dmg)

Open the DMG, then drag `Image Convert Anything.app` into `Applications`.

## What You Get

| Feature | Description |
| --- | --- |
| Image batch conversion | Convert RAW and common image files into PNG, JPEG, HEIC, TIFF, GIF, BMP, or JPEG 2000. |
| Video format conversion | Convert common video files into GIF, MP4, MOV, M4V, AVI, MKV, or WebM. |
| Folder-first workflow | Drop folders or select them from Finder; subfolders are scanned recursively. |
| Structure preservation | Output files keep the source folder structure inside the selected destination. |
| Safe filenames | Existing output files are not overwritten; duplicates get numbered names. |
| Default output folder | Set a default destination once and convert without choosing an output path every time. |
| Auto reveal | After a successful conversion, the output folder opens automatically. |
| Native macOS UI | SwiftUI app with Finder panels, drag and drop, progress, logs, and cancellable jobs. |

## Requirements

- macOS 14 or later.
- Image conversion uses macOS Core Image and ImageIO.
- Video conversion requires `ffmpeg`.

## About ffmpeg

The app does not automatically install ffmpeg from the DMG. A DMG installer should not silently install Homebrew packages or command-line dependencies because that requires network access, user trust decisions, and may require administrator-level changes outside the app bundle.

For video conversion, install ffmpeg yourself:

```bash
brew install ffmpeg
```

The app automatically detects common Homebrew locations:

```text
/opt/homebrew/bin/ffmpeg
/usr/local/bin/ffmpeg
```

Image conversion works without ffmpeg. Only the `Videos` tab needs it.

## Image Workflow

1. Choose `Images`.
2. Drop files/folders, or click `Add Images`.
3. Pick the output format.
4. Choose a session output folder, or use the saved default output folder.
5. Press `Convert`.

### Image Export Formats

| Format | Extension | Notes |
| --- | --- | --- |
| PNG | `.png` | Default output; lossless and broadly compatible. |
| JPEG | `.jpg` | Smaller files with adjustable quality. |
| HEIC | `.heic` | Modern compressed photo format on supported macOS systems. |
| TIFF | `.tiff` | High-quality archive format. |
| GIF | `.gif` | Single-frame image output. |
| BMP | `.bmp` | Bitmap output. |
| JPEG 2000 | `.jp2` | JPEG 2000 output on supported macOS systems. |

### Image Input

The app accepts RAW, JPEG, PNG, TIFF, HEIC, WebP, GIF, BMP, and other image formats that macOS can decode.

## Video Workflow

1. Choose `Videos`.
2. Drop files/folders, or click `Add Videos`.
3. Choose `GIF`, `MP4`, `MOV`, `M4V`, `AVI`, `MKV`, or `WebM`.
4. Tune FPS, maximum width, and quality when the selected format supports it.
5. Press `Convert`.

### Video Export Formats

| Format | Extension | Notes |
| --- | --- | --- |
| GIF | `.gif` | Animated image output for previews and sharing. |
| MP4 | `.mp4` | H.264/AAC output for broad compatibility. |
| MOV | `.mov` | QuickTime-style H.264/AAC output for macOS workflows. |
| M4V | `.m4v` | Apple-friendly H.264/AAC output. |
| AVI | `.avi` | Legacy AVI output using MPEG-4 video and MP3 audio. |
| MKV | `.mkv` | Matroska output using H.264/AAC. |
| WebM | `.webm` | Compact web video output using VP9/Opus. |

### Video Input

The app accepts common video files such as MOV, MP4, M4V, AVI, MKV, MPEG, and WebM.

## Settings

Open Settings to choose the default output folder and toggle automatic output reveal. If no session output folder is selected, the app uses:

```text
~/Pictures/Image Convert Anything
```

## Build From Source

```bash
git clone https://github.com/eidenchoe-appstore/Image-Convert-Anything.git
cd Image-Convert-Anything
./script/build_and_run.sh --verify
```

## Package a DMG

```bash
./script/package_dmg.sh
```

The generated DMG is written to:

```text
dist/ImageConvertAnything.dmg
```

## App Icon

The app icon source is `app_icon.icon`, an Apple Icon Composer document. The build and package scripts render it with Icon Composer's `ictool` and package the generated `AppIcon.icns` into the app bundle.

## Distribution Notes

This release is ad-hoc signed for local installation and testing. It is not Developer ID notarized. macOS may show a first-run warning for unsigned or unnotarized apps.
