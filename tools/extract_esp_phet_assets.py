#!/usr/bin/env python3
"""Extract base64 images from PhET energy-skate-park *_png.ts / *_jpg.ts files."""
from __future__ import annotations

import base64
import re
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
SRC = REPO / "phet sourses" / "energy-skate-park-main" / "energy-skate-park-main" / "images"
DST = REPO / "assets" / "energy_skate_park"

PATTERN = re.compile(r"data:image/(png|jpeg|jpg);base64,([^'\"]+)")


def extract_file(ts_path: Path, rel_dir: Path) -> Path | None:
    text = ts_path.read_text(encoding="utf-8")
    m = PATTERN.search(text)
    if not m:
        return None
    ext = "png" if m.group(1) == "png" else "jpg"
    stem = ts_path.stem
    for suffix in ("_png", "_jpg", "_jpeg"):
        if stem.endswith(suffix):
            stem = stem[: -len(suffix)]
            break
    out_dir = DST / rel_dir
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / f"{stem}.{ext}"
    out_path.write_bytes(base64.b64decode(m.group(2)))
    return out_path


def main() -> None:
    count = 0
    for ts_path in SRC.rglob("*_png.ts"):
        rel = ts_path.parent.relative_to(SRC)
        out = extract_file(ts_path, rel)
        if out:
            count += 1
            print(f"OK {out.relative_to(REPO)}")
    for ts_path in SRC.rglob("*_jpg.ts"):
        rel = ts_path.parent.relative_to(SRC)
        out = extract_file(ts_path, rel)
        if out:
            count += 1
            print(f"OK {out.relative_to(REPO)}")
    print(f"Extracted {count} files -> {DST.relative_to(REPO)}")


if __name__ == "__main__":
    main()
