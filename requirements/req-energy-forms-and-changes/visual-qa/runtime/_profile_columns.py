from pathlib import Path

import numpy as np
from PIL import Image

qa = Path(
    r"d:/OneDrive/Desktop/KartosLab/KartosLab/requirements/"
    r"req-energy-forms-and-changes/visual-qa/runtime"
)
o = np.array(Image.open(qa / "original" / "intro_initial.png").convert("RGB"))
f = np.array(Image.open(qa / "flutter" / "intro_initial.png").convert("RGB"))
print("shapes", o.shape, f.shape)


def profile(img, x0, x1, label):
    band = img[:, x0:x1]
    dark = (band[:, :, 0] < 45) & (band[:, :, 1] < 45) & (band[:, :, 2] < 45)
    # heater grey-blue body
    grey = (
        (band[:, :, 0] > 120)
        & (band[:, :, 0] < 190)
        & (band[:, :, 1] > 140)
        & (band[:, :, 1] < 210)
        & (band[:, :, 2] > 150)
    )
    wood = (band[:, :, 0] > 140) & (band[:, :, 1] > 100) & (band[:, :, 2] < 100) & (
        band[:, :, 0] > band[:, :, 2] + 40
    )
    for name, m in [("dark", dark), ("grey", grey), ("wood", wood)]:
        ys = np.where(m.any(axis=1))[0]
        if len(ys) == 0:
            print(label, name, "none")
        else:
            print(label, name, int(ys.min()), int(ys.max()), "h", int(ys.max() - ys.min()))


# Left heater roughly x=380-480 in 1024 layout from visual
for x0, x1, name in [(360, 470, "Lheater"), (520, 630, "Rheater"), (80, 180, "Iron")]:
    print("---", name, "ORIG")
    profile(o, x0, x1, "O")
    print("---", name, "FLUT")
    profile(f, x0, x1, "F")

# Shelf wood y: find continuous wood band
wood_row = (
    (o[:, :, 0] > 140)
    & (o[:, :, 1] > 100)
    & (o[:, :, 2] < 110)
    & (o[:, :, 0] > o[:, :, 2] + 40)
).mean(axis=1)
ys = np.where(wood_row > 0.15)[0]
print("O wood band", int(ys.min()) if len(ys) else None, int(ys.max()) if len(ys) else None)
wood_row_f = (
    (f[:, :, 0] > 140)
    & (f[:, :, 1] > 100)
    & (f[:, :, 2] < 110)
    & (f[:, :, 0] > f[:, :, 2] + 40)
).mean(axis=1)
ysf = np.where(wood_row_f > 0.15)[0]
print("F wood band", int(ysf.min()) if len(ysf) else None, int(ysf.max()) if len(ysf) else None)
