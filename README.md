# Image Convert Anything

`Image Convert Anything` is a local macOS app that batch converts RAW and other macOS-readable image files to JPEG or PNG.

## Download

Download the latest DMG from GitHub Releases:

[Download ImageConvertAnything.dmg](https://github.com/eidenchoe-appstore/Image-Convert-Anything/releases/latest/download/ImageConvertAnything.dmg)

Open the DMG, then drag `Image Convert Anything.app` into `Applications`.

## Features

- Drag and drop files or folders into the app.
- Select input files and folders with Finder panels.
- Recursively scan folders and preserve the input folder structure in the output folder.
- Convert RAW, JPEG, PNG, TIFF, HEIC, WebP, GIF, BMP, and other formats supported by macOS image frameworks.
- Convert to JPEG or PNG.
- Control JPEG output quality.
- Skip files that macOS cannot decode without stopping the full batch.
- Preserve input folder structure in the selected output folder.
- Avoid overwriting files by adding numeric suffixes.
- Build a local installable DMG with `hdiutil`.

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
