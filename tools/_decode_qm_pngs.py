import base64
import pathlib
import re

root = pathlib.Path(r"D:\OneDrive\Desktop\KartosLab\KartosLab")
pairs = [
    (
        root / "phet sourses" / "quantum-measurement-main" / "images" / "greenPhoton_png.ts",
        root / "assets" / "simulations" / "quantum_measurement" / "images" / "greenPhoton.png",
    ),
    (
        root / "phet sourses" / "quantum-measurement-main" / "images" / "spinScreenIcon_png.ts",
        root / "assets" / "simulations" / "quantum_measurement" / "images" / "spinScreenIcon.png",
    ),
]
for src, dst in pairs:
    text = src.read_text(encoding="utf-8")
    m = re.search(r"data:image/png;base64,([A-Za-z0-9+/=]+)", text)
    if not m:
        raise SystemExit(f"no payload in {src}")
    dst.parent.mkdir(parents=True, exist_ok=True)
    data = base64.b64decode(m.group(1))
    dst.write_bytes(data)
    print(f"{dst.name} {len(data)} bytes")
