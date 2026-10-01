"""Find cannon barrel pixels (dark reddish-gray) bounding box."""
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
        # barrel dark reddish: r 120-200, g 80-160, b 80-160, r>g>=b
        if 110 < r < 210 and 70 < g < 170 and 70 < b < 170 \
                and r > g + 15 and g >= b - 12:
            xs.append(x)
            ys.append(y)
if xs:
    print(path.split('\\')[-2], 'barrel bbox x:', min(xs), max(xs),
          'y:', min(ys), max(ys), 'w:', max(xs)-min(xs), 'h:', max(ys)-min(ys))
else:
    print(path.split('\\')[-2], 'no barrel found')
