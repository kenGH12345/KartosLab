from pathlib import Path
import re

root = Path(
    r"D:\OneDrive\Desktop\KartosLab\KartosLab\assets\simulations\membrane_transport\images"
)
n = 0
for p in root.glob("*.svg"):
    t = p.read_text(encoding="utf-8")
    t2 = re.sub(r'(stroke-width=")(\d+(?:\.\d+)?)px(")', r"\1\2\3", t)
    t2 = re.sub(r" {2,}", " ", t2)
    if t2 != t:
        p.write_text(t2, encoding="utf-8")
        n += 1
print("fixed", n)
print((root / "oxygen.svg").read_text(encoding="utf-8")[180:450])
