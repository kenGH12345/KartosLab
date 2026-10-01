#!/usr/bin/env python3
"""Extract base64 PNGs from PhET *_png.ts modules into assets/energy_forms_and_changes/."""
from __future__ import annotations

import base64
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "phet sourses" / "energy-forms-and-changes-main" / "energy-forms-and-changes-main" / "images"
DST = ROOT / "assets" / "energy_forms_and_changes"

PATTERN = re.compile(r"data:image/png;base64,([A-Za-z0-9+/=]+)")


def main() -> int:
    if not SRC.is_dir():
        print(f"MISSING SRC: {SRC}", file=sys.stderr)
        return 1
    DST.mkdir(parents=True, exist_ok=True)
    count = 0
    for ts in sorted(SRC.glob("*_png.ts")):
        text = ts.read_text(encoding="utf-8", errors="replace")
        m = PATTERN.search(text)
        if not m:
            print(f"SKIP (no png): {ts.name}")
            continue
        name = ts.name.replace("_png.ts", ".png")
        (DST / name).write_bytes(base64.b64decode(m.group(1)))
        count += 1
    print(f"Extracted {count} PNGs → {DST}")
    return 0 if count else 2


if __name__ == "__main__":
    raise SystemExit(main())
