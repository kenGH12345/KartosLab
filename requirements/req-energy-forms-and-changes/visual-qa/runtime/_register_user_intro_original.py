"""Register user-provided Original Intro reset → 1024×618 + overlay."""
from pathlib import Path

import numpy as np
from PIL import Image

SRC = Path(
    r"C:/Users/LENOVO/.cursor/projects/d-OneDrive-Desktop-KartosLab-KartosLab/assets/"
    r"c__Users_LENOVO_AppData_Roaming_Cursor_User_workspaceStorage_"
    r"d7095bd426b652e89538891894a36817_images_image-33c6c38a-a7bf-4432-a7e2-616c8422d008.png"
)
QA = Path(
    r"d:/OneDrive/Desktop/KartosLab/KartosLab/requirements/"
    r"req-energy-forms-and-changes/visual-qa/runtime"
)
TARGET = (1024, 618)

im = Image.open(SRC).convert("RGBA")
# Drop pure-black bottom chrome if any
a = np.array(im.convert("RGB"))
row = a.mean(axis=(1, 2))
y = len(row) - 1
while y > 0 and row[y] < 40:
    y -= 1
content = im.crop((0, 0, im.size[0], y + 1))
# Fit into 1024×618 preserving aspect (pad cream)
tw, th = TARGET
cw, ch = content.size
scale = min(tw / cw, th / ch)
nw, nh = int(cw * scale), int(ch * scale)
scaled = content.resize((nw, nh), Image.Resampling.LANCZOS)
canvas = Image.new("RGBA", TARGET, (249, 244, 205, 255))
canvas.paste(scaled, ((tw - nw) // 2, (th - nh) // 2), scaled)
out = QA / "original" / "intro_initial.png"
out.parent.mkdir(parents=True, exist_ok=True)
canvas.convert("RGB").save(out)
print("wrote", out, canvas.size)

fl_path = QA / "flutter" / "intro_initial.png"
if fl_path.exists():
    fl = Image.open(fl_path).convert("RGBA").resize(TARGET, Image.Resampling.LANCZOS)
    ov = Image.blend(canvas.convert("RGBA"), fl, 0.5)
    (QA / "overlay").mkdir(parents=True, exist_ok=True)
    (QA / "diff").mkdir(parents=True, exist_ok=True)
    ov.save(QA / "overlay" / "intro_initial_overlay.png")
    aa = np.array(canvas.convert("RGB"), dtype=np.int16)
    bb = np.array(fl.convert("RGB"), dtype=np.int16)
    d = np.abs(aa - bb).astype(np.uint8)
    mag = d.max(axis=2)
    heat = np.zeros_like(aa, dtype=np.uint8)
    heat[:, :, 0] = mag
    heat[:, :, 1] = (mag * 0.3).astype(np.uint8)
    Image.fromarray(heat, "RGB").save(QA / "diff" / "intro_initial_absdiff.png")
    print(f"overlay mean={float(mag.mean()):.1f} pct>30={float((mag>30).mean()*100):.1f}%")
