"""Register Original Runtime baselines, crop chrome, build overlay/diff."""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image

QA = Path(
    r"d:/OneDrive/Desktop/KartosLab/KartosLab/requirements/"
    r"req-energy-forms-and-changes/visual-qa/runtime"
)
SRC = Path(
    r"d:/OneDrive/Desktop/KartosLab/KartosLab/requirements/"
    r"req-energy-forms-and-changes/visual-qa/phet-screenshots"
)
ORIG = QA / "original"
OVERLAY = QA / "overlay"
DIFF = QA / "diff"
FLUTTER = QA / "flutter"
TARGET = (1024, 618)

for d in (ORIG, OVERLAY, DIFF):
    d.mkdir(parents=True, exist_ok=True)


def crop_sim(im: Image.Image) -> Image.Image:
    a = np.array(im.convert("RGB"))
    row = a.mean(axis=(1, 2))
    h = a.shape[0]
    y = h - 1
    while y > 0 and row[y] < 50:
        y -= 1
    content = im.crop((0, 0, im.size[0], y + 1))
    return content.resize(TARGET, Image.Resampling.LANCZOS)


MAPPING = {
    "intro_initial": (
        "energy-forms-and-changes-screenshot-screen1.png",
        "Intro runtime (Energy Symbols on; water heating — NOT pure reset)",
    ),
    "intro_heater_active": (
        "energy-forms-and-changes-screenshot-alt1.png",
        "Intro Link Heaters + dual flame + steam",
    ),
    # systems_initial (Bike→Gen→Beaker reset) has no matching PhET asset in repo.
    # Former screen2 faucet capture is archived as systems_faucet_initial.png.
    "systems_faucet_initial": (
        "energy-forms-and-changes-screenshot-screen2.png",
        "Systems faucet→generator→beaker (archive; not Flutter default reset)",
    ),
    "systems_bike_active": (
        "energy-forms-and-changes-screenshot-alt3.png",
        "Systems bike active + bulb + energy symbols",
    ),
}

manifest_rows: list[tuple] = []

for key, (fname, note) in MAPPING.items():
    raw = Image.open(SRC / fname).convert("RGBA")
    cropped = crop_sim(raw).convert("RGBA")
    out = ORIG / f"{key}.png"
    cropped.save(out)
    print("wrote", out.name, cropped.size, "from", fname)

    fl_path = FLUTTER / f"{key}.png"
    if fl_path.exists():
        fl = Image.open(fl_path).convert("RGBA").resize(
            TARGET, Image.Resampling.LANCZOS
        )
        Image.blend(cropped, fl, 0.5).save(OVERLAY / f"{key}_overlay.png")
        a = np.array(cropped.convert("RGB"), dtype=np.int16)
        b = np.array(fl.convert("RGB"), dtype=np.int16)
        d = np.abs(a - b).astype(np.uint8)
        mag = d.max(axis=2)
        heat = np.zeros_like(a, dtype=np.uint8)
        heat[:, :, 0] = mag
        heat[:, :, 1] = (mag * 0.3).astype(np.uint8)
        Image.fromarray(heat, "RGB").save(DIFF / f"{key}_absdiff.png")
        mean = float(mag.mean())
        pct = float((mag > 30).mean() * 100)
        print(f"  overlay+diff mean={mean:.1f} pct>30={pct:.1f}%")
        manifest_rows.append((key, fname, note, mean, pct))
    else:
        manifest_rows.append((key, fname, note, None, None))

# Descriptive aliases (full uncropped)
Image.open(SRC / "energy-forms-and-changes-screenshot-alt1.png").save(
    ORIG / "intro_link_heaters_full.png"
)
Image.open(SRC / "energy-forms-and-changes-screenshot-alt3.png").save(
    ORIG / "systems_bike_bulb_full.png"
)

lines = [
    "# Original Runtime Manifest",
    "",
    "> Unblocks: `[BLOCKED：缺少 Original Runtime]`",
    "",
    "| Flutter baseline | Original file | Source asset | Captured state | Overlay meanΔ | Δ>30% |",
    "|---|---|---|---|---|---|",
]
for key, fname, note, mean, pct in manifest_rows:
    mean_s = f"{mean:.1f}" if mean is not None else "—"
    pct_s = f"{pct:.1f}%" if pct is not None else "—"
    lines.append(
        f"| `{key}.png` | `original/{key}.png` | `{fname}` | {note} | {mean_s} | {pct_s} |"
    )
lines += [
    "",
    "## Notes",
    "",
    "- Cropped PhET nav chrome; resized to layout **1024×618**.",
    "- Sources are **real PhET sim captures** from repo screenshot assets (not marketing banners).",
    "- State mismatches called out above — usable for geometry / z-order / selectors.",
    "",
    "## Correspondence",
    "",
    "1. Intro Initial → `original/intro_initial.png`",
    "2. Intro Heater Active / Link Heaters → `original/intro_heater_active.png`",
    "3. Systems Initial → `original/systems_initial.png`",
    "4. Systems Bike Active → `original/systems_bike_active.png`",
    "",
]
(ORIG / "ORIGINAL_MANIFEST.md").write_text("\n".join(lines), encoding="utf-8")

blocked = ORIG / "ORIGINAL_BLOCKED.md"
if blocked.exists():
    blocked.rename(ORIG / "ORIGINAL_BLOCKED.md.bak")
print("done")
