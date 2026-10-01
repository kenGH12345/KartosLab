"""Compare official 1024x618 frames to Flutter simulation viewports.

Historical 834x504 crops are not used. A pixel counts as different when the
maximum channel delta is greater than 12 (anti-alias / PNG rounding).
"""
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(r"D:\OneDrive\Desktop\KartosLab\KartosLab\requirements\req-bending-light\visual-qa")
OFFICIAL = ROOT / "official"
FLUTTER = ROOT / "flutter"
OUT = ROOT / "final4"
OUT.mkdir(parents=True, exist_ok=True)

PAIRS = [
    ("INTRO", "OFFICIAL_INTRO.png", "FINAL4_INTRO.png"),
    ("MORE_TOOLS", "OFFICIAL_MORE_TOOLS.png", "FINAL4_MORE_TOOLS.png"),
    ("PRISMS", "OFFICIAL_PRISMS.png", "FINAL4_PRISMS.png"),
    ("WHITE_LIGHT", "OFFICIAL_WHITE_LIGHT.png", "FINAL4_WHITE_LIGHT.png"),
    ("GRAPH", "OFFICIAL_GRAPH.png", "FINAL4_GRAPH.png"),
    ("SENSORS", "OFFICIAL_SENSORS.png", "FINAL4_SENSORS.png"),
]

NAV_TOP = 569
DELTA = 12


def load(path: Path) -> np.ndarray:
    im = Image.open(path).convert("RGB")
    if im.size != (1024, 618):
        raise SystemExit(f"{path} is {im.size}, expected 1024x618")
    return np.asarray(im, dtype=np.int16)


def metrics(a: np.ndarray, b: np.ndarray) -> dict:
    d = np.abs(a - b)
    mean = d.mean(axis=(0, 1))
    mx = d.max(axis=2)
    return {
        "mean": float(mean.mean()),
        "r": float(mean[0]),
        "g": float(mean[1]),
        "b": float(mean[2]),
        "ratio": float((mx > DELTA).mean()),
        "ratio0": float((mx > 0).mean()),
    }


def heat(a: np.ndarray, b: np.ndarray) -> Image.Image:
    d = np.abs(a - b).max(axis=2).astype(np.float32)
    d = np.clip(d / 64.0, 0, 1)
    rgb = np.zeros((*d.shape, 3), dtype=np.uint8)
    rgb[..., 0] = (d * 255).astype(np.uint8)
    rgb[..., 1] = ((1 - d) * 40).astype(np.uint8)
    return Image.fromarray(rgb, "RGB")


def main() -> None:
    lines = ["scene,full_mean,full_ratio,stage_mean,stage_ratio,stage_r,stage_g,stage_b"]
    for name, off_name, flu_name in PAIRS:
        a = load(OFFICIAL / off_name)
        b = load(FLUTTER / flu_name)
        full = metrics(a, b)
        stage = metrics(a[:NAV_TOP], b[:NAV_TOP])
        left = Image.fromarray(a.astype(np.uint8), "RGB")
        right = Image.fromarray(b.astype(np.uint8), "RGB")
        side = Image.new("RGB", (1024 * 2 + 8, 618), (20, 20, 20))
        side.paste(left, (0, 0))
        side.paste(right, (1024 + 8, 0))
        side.save(OUT / f"FINAL4_{name}_SIDE_BY_SIDE.png")
        overlay = Image.blend(left, right, 0.5)
        overlay.save(OUT / f"FINAL4_{name}_OVERLAY.png")
        heat(a, b).save(OUT / f"FINAL4_{name}_DIFF.png")
        lines.append(
            f"{name},{full['mean']:.2f},{full['ratio']:.4f},"
            f"{stage['mean']:.2f},{stage['ratio']:.4f},"
            f"{stage['r']:.2f},{stage['g']:.2f},{stage['b']:.2f}"
        )
        print(name, "full", round(full["mean"], 2), "ratio", round(full["ratio"], 4),
              "stage", round(stage["mean"], 2), "ratio", round(stage["ratio"], 4))
    (OUT / "metrics.csv").write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
