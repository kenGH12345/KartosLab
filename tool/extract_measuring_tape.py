import re
import base64
from pathlib import Path

src = Path(r'phet sourses/scenery-phet/images/measuringTape_png.ts')
text = src.read_text(encoding='utf-8')
m = re.search(r'data:image/png;base64,([A-Za-z0-9+/=]+)', text)
if not m:
    raise SystemExit('no base64 found')
data = base64.b64decode(m.group(1))
out = Path(r'assets/simulations/projectile_motion/measuringTape.png')
out.write_bytes(data)
print(f'wrote {out} ({len(data)} bytes)')
