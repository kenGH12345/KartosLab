"""Crop same rect from ORIGINAL and FLUTTER, upscale, stack vertically."""
import sys
from PIL import Image

state = sys.argv[1]
box = tuple(int(v) for v in sys.argv[2].split(','))
scale = float(sys.argv[3]) if len(sys.argv) > 3 else 2.0
base = r'requirements/req-projectile-motion/visual-qa'
o = Image.open(f'{base}/ORIGINAL/{state}.png').crop(box)
f = Image.open(f'{base}/FLUTTER/{state}.png').crop(box)
w, h = o.size
c = Image.new('RGB', (int(w * scale), int(h * 2 * scale + 6)), (255, 0, 0))
o = o.resize((int(w * scale), int(h * scale)), Image.LANCZOS)
f = f.resize((int(w * scale), int(h * scale)), Image.LANCZOS)
c.paste(o, (0, 0))
c.paste(f, (0, int(h * scale) + 6))
out = f'{base}/DIFF/cz_{state}_{box[0]}_{box[1]}.png'
c.save(out)
print('WROTE', out, c.size)
