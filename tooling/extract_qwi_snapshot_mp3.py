import base64
import pathlib
import re

root = pathlib.Path(__file__).resolve().parents[1]
js = (root / 'phet sourses/quantum-wave-interference-main/quantum-wave-interference-main/sounds/snapshotCaptured_mp3.js').read_text(encoding='utf-8')
m = re.search(r"data:audio/mpeg;base64,([^']+)", js)
if not m:
    raise SystemExit('base64 payload not found')
data = base64.b64decode(m.group(1))
out = root / 'assets/simulations/quantum_wave_interference/sounds/snapshotCaptured.mp3'
out.parent.mkdir(parents=True, exist_ok=True)
out.write_bytes(data)
print(f'wrote {len(data)} bytes -> {out}')
