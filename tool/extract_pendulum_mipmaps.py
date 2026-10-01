"""Extract highest-resolution PhET mipmap PNGs for Pendulum Lab."""

from __future__ import annotations

import base64
import re
from pathlib import Path

ROOT = Path(
    r"D:\OneDrive\Desktop\KartosLab\KartosLab\phet sourses"
    r"\pendulum-lab-main\pendulum-lab-main\mipmaps"
)
OUT = Path(r"D:\OneDrive\Desktop\KartosLab\KartosLab\assets\simulations\pendulum_lab")
PATTERN = re.compile(
    r"new MipmapElement\(\s*(\d+),\s*(\d+),\s*'data:image/png;base64,([^']+)'"
)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for path in sorted(ROOT.glob("*_png.ts")):
        text = path.read_text(encoding="utf-8")
        match = PATTERN.search(text)
        if match is None:
            print("FAIL", path.name)
            continue
        width, height, b64 = match.group(1), match.group(2), match.group(3)
        name = path.name.replace("_png.ts", ".png")
        dest = OUT / name
        dest.write_bytes(base64.b64decode(b64))
        print(f"{name} {width}x{height} {dest.stat().st_size} bytes")


if __name__ == "__main__":
    main()
