"""FINAL6 regional comparison. Does not overwrite FINAL4 or FINAL5."""
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(r"D:\OneDrive\Desktop\KartosLab\KartosLab\requirements\req-bending-light\visual-qa")
OFFICIAL = ROOT / "official"
FLUTTER = ROOT / "flutter"
OUT = ROOT / "final6"
OUT.mkdir(parents=True, exist_ok=True)

DELTA = 12
SCALE = 569 / 504
OX = (1024 - 834 * SCALE) / 2


def load(path: Path) -> np.ndarray:
    im = Image.open(path).convert("RGB")
    if im.size != (1024, 618):
        raise SystemExit(f"{path} is {im.size}")
    return np.asarray(im, dtype=np.int16)


def box(stage_box):
    x0, y0, x1, y1 = stage_box
    return (
        int(round(OX + x0 * SCALE)),
        int(round(y0 * SCALE)),
        int(round(OX + x1 * SCALE)),
        int(round(y1 * SCALE)),
    )


def crop_save(name, image, rect):
    x0, y0, x1, y1 = rect
    x0, y0 = max(0, x0), max(0, y0)
    x1, y1 = min(1024, x1), min(618, y1)
    Image.fromarray(image[y0:y1, x0:x1].astype(np.uint8)).save(OUT / name)
    return x0, y0, x1, y1


def metrics(a, b, rect):
    x0, y0, x1, y1 = rect
    da = a[y0:y1, x0:x1]
    db = b[y0:y1, x0:x1]
    d = np.abs(da - db)
    return float(d.mean()), float((d.max(axis=2) > DELTA).mean())


def main():
    intro_f = load(FLUTTER / "FINAL6_INTRO.png")
    more_f = load(FLUTTER / "FINAL6_MORE_TOOLS.png")
    graph_f = load(FLUTTER / "FINAL6_GRAPH.png")
    sensors_f = load(FLUTTER / "FINAL6_SENSORS.png")
    intro_o = load(OFFICIAL / "OFFICIAL_INTRO.png")
    more_o = load(OFFICIAL / "OFFICIAL_MORE_TOOLS.png")
    graph_o = load(OFFICIAL / "OFFICIAL_GRAPH.png")
    sensors_o = load(OFFICIAL / "OFFICIAL_SENSORS.png")

    panel = box((560, 90, 834, 470))
    toolbox = box((0, 300, 170, 504))
    graph = (50, 330, 230, 490)
    sensors = box((80, 140, 520, 430))
    play = box((180, 80, 560, 430))
    background = (0, 0, 40, 40)

    crop_save("FINAL6_PANEL.png", intro_f, panel)
    crop_save("FINAL6_TOOLBOX.png", more_f, toolbox)
    crop_save("FINAL6_GRAPH_DETAIL.png", graph_f, graph)

    rows = [
        ("Panel", intro_f, intro_o, panel),
        ("Toolbox", more_f, more_o, toolbox),
        ("Graph", graph_f, graph_o, graph),
        ("Sensors", sensors_f, sensors_o, sensors),
        ("Play Area", intro_f, intro_o, play),
        ("Background", intro_f, intro_o, background),
    ]
    print("region,mean,ratio,rect")
    for name, a, b, rect in rows:
        mean, ratio = metrics(a, b, rect)
        print(f"{name},{mean:.2f},{ratio:.3f},{rect}")


if __name__ == "__main__":
    main()
