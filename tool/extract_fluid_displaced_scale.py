import base64
import pathlib
import re

src = pathlib.Path(
    "phet sourses/density-buoyancy-common-main/images/fluid_displaced_scale_icon_png.ts"
)
text = src.read_text(encoding="utf-8")
match = re.search(r"base64,([A-Za-z0-9+/=]+)", text)
if not match:
    raise SystemExit("base64 payload not found")
out = pathlib.Path("assets/buoyancy/images/fluid_displaced_scale_icon.png")
out.parent.mkdir(parents=True, exist_ok=True)
out.write_bytes(base64.b64decode(match.group(1)))
print(f"wrote {out} ({out.stat().st_size} bytes)")
