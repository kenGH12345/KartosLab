import base64
import pathlib
import re

root = pathlib.Path(__file__).resolve().parents[1]
ts = (root / 'phet sourses/scenery-phet/images/measuringTape_png.ts').read_text(encoding='utf-8')
m = re.search(r"data:image/png;base64,([^']+)", ts)
if not m:
    raise SystemExit('png base64 not found')
data = base64.b64decode(m.group(1))
out = root / 'assets/simulations/quantum_wave_interference/images/measuringTape.png'
out.parent.mkdir(parents=True, exist_ok=True)
out.write_bytes(data)
print(f'wrote {len(data)} bytes -> {out}')
