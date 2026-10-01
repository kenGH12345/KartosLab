"""Crop same rect from ORIGINAL and FLUTTER, stack vertically."""
import sys
from PIL import Image

state = sys.argv[1] if len(sys.argv) > 1 else '01_Intro_initial'
box = tuple(int(v) for v in sys.argv[2].split(',')) if len(sys.argv) > 2 \
    else (0, 380, 500, 740)
base = r'requirements/req-projectile-motion/visual-qa'
o = Image.open(f'{base}/ORIGINAL/{state}.png').crop(box)
f = Image.open(f'{base}/FLUTTER/{state}.png').crop(box)
w, h = o.size
c = Image.new('RGB', (w, h * 2 + 4), (255, 0, 0))
c.paste(o, (0, 0))
c.paste(f, (0, h + 4))
out = f'{base}/DIFF/crop_{state}_{box[0]}_{box[1]}.png'
c.save(out)
print('WROTE', out, c.size)
