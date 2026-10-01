"""Locate cannon base dark cluster in a screenshot to verify geometry."""
import sys
from PIL import Image

path = sys.argv[1]
im = Image.open(path).convert('RGB')
px = im.load()

cols = {}
for x in range(0, 600):
    n = sum(1 for y in range(596, 645) if sum(px[x, y]) < 150)
    if n > 3:
        cols[x] = n

runs = []
cur = None
for x in sorted(cols):
    if cur is None or x > cur[1] + 3:
        if cur:
            runs.append(cur)
        cur = [x, x]
    else:
        cur[1] = x
if cur:
    runs.append(cur)
print(path.split('\\')[-1], 'dark runs (cannon base candidates):', runs)
