"""Sample pixel colors at given points."""
import sys
from PIL import Image

path = sys.argv[1]
im = Image.open(path).convert('RGB')
px = im.load()
for pt in sys.argv[2:]:
    x, y = (int(v) for v in pt.split(','))
    # 3x3 average
    rs = gs = bs = 0
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            r, g, b = px[x + dx, y + dy]
            rs += r; gs += g; bs += b
    print(f'({x},{y}) -> ({rs//9},{gs//9},{bs//9})')
