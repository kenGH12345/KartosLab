from pathlib import Path

import numpy as np
from PIL import Image

src = Path(
    r"C:/Users/LENOVO/.cursor/projects/d-OneDrive-Desktop-KartosLab-KartosLab/assets/"
    r"c__Users_LENOVO_AppData_Roaming_Cursor_User_workspaceStorage_"
    r"d7095bd426b652e89538891894a36817_images_image-33c6c38a-a7bf-4432-a7e2-616c8422d008.png"
)
qa = Path(
    r"d:/OneDrive/Desktop/KartosLab/KartosLab/requirements/"
    r"req-energy-forms-and-changes/visual-qa"
)
orig_dir = qa / "runtime" / "original"
phet_dir = qa / "phet-screenshots"
flutter = qa / "runtime" / "flutter" / "intro_initial.png"
orig_dir.mkdir(parents=True, exist_ok=True)
phet_dir.mkdir(parents=True, exist_ok=True)

im = Image.open(src).convert("RGB")
print("raw", im.size)
a = np.array(im)
row_mean = a.mean(axis=(1, 2))

# Drop bottom black chrome
y = len(row_mean) - 1
while y > 0 and row_mean[y] < 50:
    y -= 1

# Find cream content band
cream = [
    i
    for i, r in enumerate(a.mean(axis=1))
    if r[0] > 200 and r[1] > 190 and r[2] > 150
]
if cream:
    print("cream", cream[0], cream[-1])
    content = im.crop((0, cream[0], im.size[0], min(cream[-1], y) + 1))
else:
    content = im.crop((0, 0, im.size[0], y + 1))
print("content", content.size)

target = (1024, 618)
resized = content.resize(target, Image.Resampling.LANCZOS)
resized.save(orig_dir / "intro_initial.png")
content.save(phet_dir / "energy-forms-and-changes-screenshot-screen1.png")
print("saved original")

b = np.array(resized)
region = b[250:580, 300:720]
dark = (region[:, :, 0] < 50) & (region[:, :, 1] < 50) & (region[:, :, 2] < 50)
grey = (
    (region[:, :, 0] > 130)
    & (region[:, :, 0] < 200)
    & (region[:, :, 1] > 140)
    & (region[:, :, 1] < 210)
    & (np.abs(region[:, :, 0].astype(int) - region[:, :, 1]) < 40)
)
wood = (
    (region[:, :, 0] > 160)
    & (region[:, :, 1] > 120)
    & (region[:, :, 1] < 180)
    & (region[:, :, 2] < 120)
)
for name, mask in [("dark", dark), ("grey", grey), ("woodish", wood)]:
    ys = np.where(mask.any(axis=1))[0]
    if len(ys):
        print(name, "rel", int(ys[0]), int(ys[-1]), "abs", 250 + int(ys[0]), 250 + int(ys[-1]))

if flutter.exists():
    fl = np.array(Image.open(flutter).convert("RGB").resize(target))
    region_f = fl[250:580, 300:720]
    dark_f = (region_f[:, :, 0] < 50) & (region_f[:, :, 1] < 50) & (region_f[:, :, 2] < 50)
    grey_f = (
        (region_f[:, :, 0] > 130)
        & (region_f[:, :, 0] < 200)
        & (region_f[:, :, 1] > 140)
        & (region_f[:, :, 1] < 210)
    )
    for name, mask in [("Fdark", dark_f), ("Fgrey", grey_f)]:
        ys = np.where(mask.any(axis=1))[0]
        if len(ys):
            print(name, "rel", int(ys[0]), int(ys[-1]), "abs", 250 + int(ys[0]), 250 + int(ys[-1]))
