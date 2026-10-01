"""Extract PNG assets from PhET charges-and-fields mipmap TS modules."""
from __future__ import annotations

import base64
import pathlib
import re

root = pathlib.Path(
    r"phet sourses/charges-and-fields-main/charges-and-fields-main/mipmaps"
)
out = pathlib.Path(r"assets/simulations/charges_and_fields")
out.mkdir(parents=True, exist_ok=True)

for ts in sorted(root.glob("*_png.ts")):
    text = ts.read_text(encoding="utf-8")
    name = ts.name.replace("_png.ts", ".png")
    m = re.search(r"data:image/png;base64,([A-Za-z0-9+/=]+)", text)
    if m:
        data = base64.b64decode(m.group(1))
        (out / name).write_bytes(data)
        print(f"{name}: {len(data)} bytes (base64)")
        continue
    m2 = re.search(r"new Uint8Array\(\[([^\]]+)\]\)", text)
    if m2:
        nums = [int(x.strip()) for x in m2.group(1).split(",") if x.strip()]
        data = bytes(nums)
        (out / name).write_bytes(data)
        print(f"{name}: {len(data)} bytes (uint8)")
        continue
    print(f"FAIL {ts.name}")
    print(text[:300])
