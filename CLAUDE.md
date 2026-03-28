# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Converts a YouTube playlist (or single video) into a single M4B audiobook with per-video chapter markers and cover art. Single Bash implementation.

## Architecture

The script follows a 6-step pipeline:

1. **Fetch metadata** — `yt-dlp --flat-playlist` to get playlist title and uploader; falls back to single-video metadata
2. **Download audio** — `yt-dlp -x -f bestaudio` with indexed filenames (`%03d - title.ext`); `--no-overwrites` enables resume
3. **Normalize audio** — two-pass EBU R128 loudness normalization via ffmpeg `loudnorm` filter (skip with `-n`); tracks completed files for resume
4. **Build concat list + chapters** — ffmpeg concat demuxer `list.txt` and `;FFMETADATA1` chapter file, using `ffprobe` for per-file durations; optional silence gaps between chapters
5. **Cover art** — `yt-dlp --write-thumbnail --convert-thumbnails jpg`, or user-provided image via `-c`
6. **Encode M4B** — `ffmpeg` concat → AAC with chapters, cover art, and metadata

External dependencies: `yt-dlp`, `ffmpeg`, `ffprobe` (must be on PATH).

## File Map

- `playlist-to-audiobook.sh` — Bash implementation

## Key Conventions

- ffmpeg concat list paths must use **forward slashes** and escape single quotes as `'\''`
- Chapter metadata files must start with exactly `;FFMETADATA1` on the first byte
- Filenames are sanitized by replacing `<>:"/\|?*'` with `_`

## Testing

No test suite. Manual testing requires a real YouTube playlist URL and the external tools installed.

```bash
./playlist-to-audiobook.sh -u "<playlist-url>"
```
