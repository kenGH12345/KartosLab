"""FINAL5 comparison. Same crop and threshold as FINAL4. Does not overwrite FINAL4."""
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(r"D:\OneDrive\Desktop\KartosLab\KartosLab\requirements\req-bending-light\visual-qa")
OFFICIAL = ROOT / "official"
FLUTTER = ROOT / "flutter"
OUT = ROOT / "final5"
OUT.mkdir(parents=True, exist_ok=True)

PAIRS = [
    ("INTRO", "OFFICIAL_INTRO.png", "FINAL5_INTRO.png"),
    ("MORE_TOOLS", "OFFICIAL_MORE_TOOLS.png", "FINAL5_MORE_TOOLS.png"),
    ("PRISMS", "OFFICIAL_PRISMS.png", "FINAL5_PRISMS.png"),
    ("WHITE_LIGHT", "OFFICIAL_WHITE_LIGHT.png", "FINAL5_WHITE_LIGHT.png"),
    ("GRAPH", "OFFICIAL_GRAPH.png", "FINAL5_GRAPH.png"),
    ("SENSORS", "OFFICIAL_SENSORS.png", "FINAL5_SENSORS.png"),
]
NAV_TOP = 569
DELTA = 12


def load(path: Path) -> np.ndarray:
    im = Image.open(path).convert("RGB")
    if im.size != (1024, 618):
        raise SystemExit(f"{path} is {im.size}")
    return np.asarray(im, dtype=np.int16)


def metrics(a: np.ndarray, b: np.ndarray) -> tuple[float, float]:
    d = np.abs(a - b)
    mean = float(d.mean())
    ratio = float((d.max(axis=2) > DELTA).mean())
    return mean, ratio


def main() -> None:
    lines = ["scene,stage_mean,stage_ratio"]
    for name, off_name, flu_name in PAIRS:
        a = load(OFFICIAL / off_name)
        b = load(FLUTTER / flu_name)
        mean, ratio = metrics(a[:NAV_TOP], b[:NAV_TOP])
        left = Image.fromarray(a.astype(np.uint8), "RGB")
        right = Image.fromarray(b.astype(np.uint8), "RGB")
        side = Image.new("RGB", (1024 * 2 + 8, 618), (20, 20, 20))
        side.paste(left, (0, 0))
        side.paste(right, (1024 + 8, 0))
        side.save(OUT / f"FINAL5_{name}_SIDE_BY_SIDE.png")
        Image.blend(left, right, 0.5).save(OUT / f"FINAL5_{name}_OVERLAY.png")
        lines.append(f"{name},{mean:.2f},{ratio:.4f}")
        print(name, round(mean, 2), round(ratio, 4))
    # Panel and toolbox crops from Intro, the screen that shows both.
    a = load(OFFICIAL / "OFFICIAL_INTRO.png")
    b = load(FLUTTER / "FINAL5_INTRO.png")
    for label, box in (("PANEL", (700, 0, 1024, 280)), ("TOOLBOX", (0, 300, 220, 520))):
        aa = Image.fromarray(a[box[1]:box[3], box[0]:box[2]].astype(np.uint8), "RGB")
        bb = Image.fromarray(b[box[1]:box[3], box[0]:box[2]].astype(np.uint8), "RGB")
        Image.blend(aa, bb, 0.5).save(OUT / f"FINAL5_{label}_OVERLAY.png")
    (OUT / "metrics.csv").write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
