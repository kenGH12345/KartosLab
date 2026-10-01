#!/usr/bin/env python3
"""Extract scenery-phet assets used by Energy Skate Park."""
from __future__ import annotations

import base64
import re
import shutil
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
SPHET = REPO / "phet sourses" / "scenery-phet"
DST = REPO / "assets" / "energy_skate_park" / "scenery_phet"

PATTERN = re.compile(r"data:image/(png|jpeg|jpg|svg\+xml);base64,([^'\"]+)")


def extract_png_ts(ts_path: Path, out_name: str | None = None) -> Path | None:
    text = ts_path.read_text(encoding="utf-8")
    m = PATTERN.search(text)
    if not m:
        return None
    ext = "png" if m.group(1) == "png" else "jpg"
    name = out_name or ts_path.stem.replace("_png", "").replace("_jpg", "") + f".{ext}"
    DST.mkdir(parents=True, exist_ok=True)
    out = DST / name
    out.write_bytes(base64.b64decode(m.group(2)))
    return out


def main() -> None:
    DST.mkdir(parents=True, exist_ok=True)
    tape = extract_png_ts(SPHET / "images" / "measuringTape_png.ts", "measuringTape.png")
    if tape:
        print(f"OK {tape.relative_to(REPO)}")
    svg_src = SPHET / "images" / "eraser.svg"
    svg_dst = DST / "eraser.svg"
    if svg_src.exists():
        shutil.copy2(svg_src, svg_dst)
        print(f"OK {svg_dst.relative_to(REPO)}")


if __name__ == "__main__":
    main()
