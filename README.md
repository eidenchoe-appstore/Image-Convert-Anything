# <img src="icon.png" alt="Image Convert Anything icon" width="34"> Image Convert Anything

Batch-convert images and videos on macOS with a simple Finder-friendly workflow.

[Download the latest DMG](https://github.com/eidenchoe-appstore/Image-Convert-Anything/releases/latest/download/ImageConvertAnything.dmg)

Open the DMG, then drag `Image Convert Anything.app` into `Applications`.

## Highlights

| Feature | What it does |
| --- | --- |
| Image converter | Reads RAW, JPEG, PNG, TIFF, HEIC, WebP, GIF, BMP, and other formats supported by macOS image frameworks. |
| Video converter | Converts common video files such as MOV, MP4, M4V, AVI, MKV, and WebM into GIF or WebM. |
| Finder-first input | Add files and folders from Finder panels, or drag them directly into the app. |
| Folder batch mode | Scans folders recursively and preserves the original folder structure in the output folder. |
| Flexible export | Exports images to PNG, JPEG, HEIC, TIFF, GIF, BMP, or JPEG 2000. PNG is the default. |
| Video tuning | Controls GIF/WebM frame rate, maximum width, and WebM quality. |
| Default output folder | Uses a saved default output folder when no session output folder is selected. |
| Auto reveal | Opens the output folder automatically after a successful conversion. |

## Image Workflow

1. Choose the `Images` tab.
2. Drop image files/folders, or select them with `Add Images`.
3. Pick an output format.
4. Choose a session output folder, or use the saved default folder.
5. Press `Convert`.

Supported image export formats:

| Format | Extension | Notes |
| --- | --- | --- |
| PNG | `.png` | Default output; lossless and broadly compatible. |
| JPEG | `.jpg` | Smaller files with adjustable quality. |
| HEIC | `.heic` | Modern compressed photo format on supported macOS systems. |
| TIFF | `.tiff` | High-quality archive format. |
| GIF | `.gif` | Single-frame GIF output. |
| BMP | `.bmp` | Bitmap output. |
| JPEG 2000 | `.jp2` | JPEG 2000 output on supported macOS systems. |

## Video Workflow

1. Choose the `Videos` tab.
2. Drop video files/folders, or select them with `Add Videos`.
3. Choose `GIF` or `WebM`.
4. Set FPS, maximum width, and WebM quality when needed.
5. Press `Convert`.

Video conversion uses `ffmpeg`. The app automatically detects Homebrew-style installs such as `/opt/homebrew/bin/ffmpeg` and `/usr/local/bin/ffmpeg`. If video conversion is unavailable, install it with:

```bash
brew install ffmpeg
```

## Settings

Open Settings to choose the default output folder and decide whether the app should reveal the output folder after conversion. If no session output folder is selected, the app uses:

```text
~/Pictures/Image Convert Anything
```

## Package Included

The repository includes a prebuilt local DMG at:

```text
dist/ImageConvertAnything.dmg
```

For normal installation, use the GitHub Release download link above.

## Build And Run

```bash
./script/build_and_run.sh --verify
```

## Package DMG

```bash
./script/package_dmg.sh
```

This package is for local installation and testing. It is ad-hoc signed, not Developer ID notarized.
