"""Locate + measure the stopwatch panel in a screenshot by color clustering.

Finds large connected-ish regions of saturated (non-grey, non-white) pixels
in a region of interest, prints bounding box + mean color for each.
Usage: python tool/analyze_color_regions.py <png> [x0 y0 x1 y1]
"""
import sys
from collections import deque

from PIL import Image


def main() -> int:
    path = sys.argv[1]
    roi = tuple(int(v) for v in sys.argv[2:6]) if len(sys.argv) > 2 else None
    im = Image.open(path).convert('RGB')
    if roi:
        im = im.crop(roi)
    w, h = im.size
    px = im.load()

    def saturated(p):
        r, g, b = p
        mx, mn = max(p), min(p)
        return mx - mn > 40 and mx < 250  # colored, not near-white

    mask = bytearray(w * h)
    for y in range(h):
        for x in range(w):
            if saturated(px[x, y]):
                mask[y * w + x] = 1

    seen = bytearray(w * h)
    regions = []
    for y in range(h):
        for x in range(w):
            i = y * w + x
            if not mask[i] or seen[i]:
                continue
            # BFS
            q = deque([(x, y)])
            seen[i] = 1
            minx = maxx = x
            miny = maxy = y
            n = 0
            sr = sg = sb = 0
            while q:
                cx, cy = q.popleft()
                n += 1
                minx, maxx = min(minx, cx), max(maxx, cx)
                miny, maxy = min(miny, cy), max(maxy, cy)
                r, g, b = px[cx, cy]
                sr += r
                sg += g
                sb += b
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = cx + dx, cy + dy
                    if 0 <= nx < w and 0 <= ny < h:
                        j = ny * w + nx
                        if mask[j] and not seen[j]:
                            seen[j] = 1
                            q.append((nx, ny))
            if n > 300:  # ignore speckles
                regions.append({
                    'bbox': [minx, miny, maxx, maxy],
                    'w': maxx - minx + 1, 'h': maxy - miny + 1,
                    'pixels': n,
                    'mean_rgb': [sr // n, sg // n, sb // n],
                })
    regions.sort(key=lambda r: -r['pixels'])
    offx, offy = (roi[0], roi[1]) if roi else (0, 0)
    for r in regions[:8]:
        b = r['bbox']
        print(f"bbox(abs)=({b[0]+offx},{b[1]+offy})-({b[2]+offx},{b[3]+offy}) "
              f"size={r['w']}x{r['h']} px={r['pixels']} mean={tuple(r['mean_rgb'])}")
    return 0


if __name__ == '__main__':
    sys.exit(main())
