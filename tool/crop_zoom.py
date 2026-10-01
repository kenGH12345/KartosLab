"""Crop a rect from one image and upscale."""
import sys
from PIL import Image

path = sys.argv[1]
box = tuple(int(v) for v in sys.argv[2].split(','))
scale = float(sys.argv[3]) if len(sys.argv) > 3 else 2.0
out = sys.argv[4] if len(sys.argv) > 4 else None
im = Image.open(path).crop(box)
im = im.resize((int(im.width * scale), int(im.height * scale)),
               Image.NEAREST)
if out:
    im.save(out)
    print('WROTE', out, im.size)
