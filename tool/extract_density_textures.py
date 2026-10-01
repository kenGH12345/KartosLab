#!/usr/bin/env python3
"""Extract PhET *_col_jpg.ts base64 payloads to assets/density/images/materials/."""
import base64
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
SRC = ROOT / "phet sourses" / "density-buoyancy-common-main" / "images"
OUT = ROOT / "assets" / "density" / "images" / "materials"

MAPPING = [
    ("Styrofoam_001_col_jpg.ts", "styrofoam_col.jpg"),
    ("Wood26_col_jpg.ts", "wood_col.jpg"),
    ("Ice01_col_jpg.ts", "ice_col.jpg"),
    ("Plastic018B_col_jpg.ts", "pvc_col.jpg"),
    ("Bricks25_col_jpg.ts", "brick_col.jpg"),
    ("Metal10_col_jpg.ts", "aluminum_col.jpg"),
    ("Metal08_col_jpg.ts", "copper_col.jpg"),
    ("DiamondPlate01_col_jpg.ts", "steel_col.jpg"),
    ("Metal007_col_jpg.ts", "gold_col.jpg"),
]


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    for ts_name, jpg_name in MAPPING:
        text = (SRC / ts_name).read_text(encoding="utf-8")
        match = re.search(r"base64,([^']+)", text)
        if not match:
            print(f"ERROR: no base64 in {ts_name}", file=sys.stderr)
            return 1
        data = base64.b64decode(match.group(1))
        out_path = OUT / jpg_name
        out_path.write_bytes(data)
        print(f"{jpg_name}: {len(data)} bytes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
