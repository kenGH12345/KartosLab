"""Print run-length encoded color profile of one row."""
import sys
from PIL import Image

path = sys.argv[1]
y = int(sys.argv[2])
x0, x1 = int(sys.argv[3]), int(sys.argv[4])
im = Image.open(path).convert('RGB')
px = im.load()

def cls(c):
    r, g, b = c
    if abs(r - 0) < 30 and abs(g - 173) < 30 and abs(b - 78) < 30:
        return 'grass'
    if abs(r - 77) < 25 and abs(g - 77) < 25 and abs(b - 75) < 25:
        return 'road'
    if b > 180 and g > 120 and r < 200:
        return 'sky'
    if r > 200 and g > 200 and b < 90:
        return 'dash'
    if r > 230 and g > 230 and b > 230:
        return 'white'
    if r < 20 and g < 20 and b < 20:
        return 'black'
    return f'({r},{g},{b})'

runs = []
prev = None
for x in range(x0, x1):
    c = cls(px[x, y])
    if c != prev:
        runs.append([x, x, c])
        prev = c
    else:
        runs[-1][1] = x
print(path.split('\\')[-1], f'y={y}')
for r in runs:
    print(' ', r[0], '-', r[1], r[2])
