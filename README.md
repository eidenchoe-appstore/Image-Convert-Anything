# Image Convert Anything

`Image Convert Anything` is a local macOS app that batch converts RAW and other macOS-readable image files into common output formats.

## Download

Download the latest DMG from GitHub Releases:

[Download ImageConvertAnything.dmg](https://github.com/eidenchoe-appstore/Image-Convert-Anything/releases/latest/download/ImageConvertAnything.dmg)

Open the DMG, then drag `Image Convert Anything.app` into `Applications`.

## Features

- Drag and drop files or folders into the app.
- Select input files and folders with Finder panels.
- Recursively scan folders and preserve the input folder structure in the output folder.
- Read RAW, JPEG, PNG, TIFF, HEIC, WebP, GIF, BMP, and other formats supported by macOS image frameworks.
- Export to PNG, JPEG, HEIC, TIFF, GIF, BMP, or JPEG 2000.
- Use PNG as the default output format.
- Control quality for lossy formats such as JPEG, HEIC, and JPEG 2000.
- Skip files that macOS cannot decode without stopping the full batch.
- Preserve input folder structure in the selected output folder.
- Avoid overwriting files by adding numeric suffixes.
- Build a local installable DMG with `hdiutil`.

## Output Formats

| Format | Extension | Notes |
| --- | --- | --- |
| PNG | `.png` | Default output; lossless and broadly compatible. |
| JPEG | `.jpg` | Smaller files with adjustable quality. |
| HEIC | `.heic` | Modern compressed photo format on supported macOS systems. |
| TIFF | `.tiff` | High-quality archive format. |
| GIF | `.gif` | Single-frame GIF output. |
| BMP | `.bmp` | Bitmap output. |
| JPEG 2000 | `.jp2` | JPEG 2000 output on supported macOS systems. |

## Package Included

The repository includes a prebuilt local DMG at:

```text
dist/ImageConvertAnything.dmg
```

For normal installation, prefer the GitHub Release download link above.

## Build And Run

```bash
./script/build_and_run.sh --verify
```

## Package DMG

```bash
./script/package_dmg.sh
```

The DMG is created at:

```text
dist/ImageConvertAnything.dmg
```

This package is for local installation and testing. It is not Developer ID signed or notarized.
