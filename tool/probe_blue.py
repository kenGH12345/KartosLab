"""Find blue-circle pixels (cannon muzzle) bounding box."""
import sys
from PIL import Image

path = sys.argv[1]
x0, y0, x1, y1 = (int(v) for v in sys.argv[2].split(','))
im = Image.open(path).convert('RGB')
px = im.load()
xs, ys = [], []
for y in range(y0, y1):
    for x in range(x0, x1):
        r, g, b = px[x, y]
        # cannon blue ~ (30-60, 150-190, 220-240); sky is lighter (g>190)
        if b > 190 and 100 < g < 195 and r < 110:
            xs.append(x)
            ys.append(y)
if xs:
    print(path.split('\\')[-1], 'blue bbox x:', min(xs), max(xs),
          'y:', min(ys), max(ys), 'w:', max(xs)-min(xs), 'h:', max(ys)-min(ys))
else:
    print(path.split('\\')[-1], 'no blue found')
