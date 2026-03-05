# tl-tools

Bash utility for organizing and processing timelapse photo projects.

## Dependencies

```bash
brew install ffmpeg dcraw
```

## Usage

```bash
tl-tools.sh [option]
```

| Option | Description | Run from |
|--------|-------------|----------|
| `-d`, `--demo` | Organize RAW/JPG files into subfolders and create `demo.mp4` | Folder with project subfolders |
| `-360` | Organize 360 camera files (DNG, INSP, INSV) into subfolders | Folder with project subfolders |
| `-lr` | Move Lightroom folders from `Raw/` up to project root | Folder with project subfolders |
| `-p`, `--project` | Create blank After Effects `.aep` and `.txt` description files | Folder with project subfolders |
| `-bfr` | Collect ARW files from subfolders into a single `Raw/` folder | Project folder with ARW in subfolders |
| `-bfn` | Keep every nth ARW file, move selected to `<folder>_KEEP` | Folder containing ARW files |

## `-d` workflow

Processes each subfolder:

1. Moves RAW files (ARW, CR2, NEF) → `<project>/Raw/`
2. If JPG files exist → moves to `<project>/Jpg/`, encodes `demo.mp4` at 25fps
3. If only RAW files → extracts camera thumbnails with `dcraw`, encodes a scaled preview `demo.mp4` (1280px wide)

Re-running is safe — already-organized folders are skipped.

## `-p` workflow

For each subfolder creates:
- `<name>.aep` — copy of `~/Projects/tl-tools/templates/ae_template.aep`
- `<name>.txt` — description file with fields: Lens, Aperture, Shutter, Interval, ND, Pivot Point, Location
