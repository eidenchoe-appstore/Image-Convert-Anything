# Image Convert Anything

`Image Convert Anything` is a local macOS app that batch converts RAW and other macOS-readable image files to JPEG or PNG.

## Features

- Drag and drop files or folders.
- Select input files/folders with Finder panels.
- Convert RAW, JPEG, PNG, TIFF, HEIC, WebP, GIF, BMP, and other formats supported by macOS image frameworks.
- Preserve input folder structure in the selected output folder.
- Avoid overwriting files by adding numeric suffixes.
- Build a local installable DMG with `hdiutil`.

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
