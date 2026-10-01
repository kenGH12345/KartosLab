"""Measure david figure bounding box (non-background pixels in region)."""
import sys
from PIL import Image

path = sys.argv[1]
x0, x1, y0, y1 = (int(v) for v in sys.argv[2].split(','))
im = Image.open(path).convert('RGB')
px = im.load()

def is_bg(c):
    # sky gradient blues, grass green, road gray, dashed yellow
    r, g, b = c
    if abs(r - 0) < 30 and abs(g - 173) < 30 and abs(b - 78) < 30:
        return True  # grass
    if abs(r - 77) < 25 and abs(g - 77) < 25 and abs(b - 75) < 25:
        return True  # road
    if b > 180 and g > 120:
        return True  # sky
    if r > 200 and g > 200 and b < 90:
        return True  # dashed yellow
    return False

xs = []
ys = []
for y in range(y0, y1):
    for x in range(x0, x1):
        if not is_bg(px[x, y]):
            xs.append(x)
            ys.append(y)
if xs:
    print(path.split('\\')[-1],
          'bbox x:', min(xs), max(xs), 'y:', min(ys), max(ys),
          'w:', max(xs) - min(xs), 'h:', max(ys) - min(ys))
else:
    print(path.split('\\')[-1], 'nothing found')
