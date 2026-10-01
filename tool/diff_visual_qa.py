"""Visual QA diff: pixel-compare ORIGINAL vs FLUTTER screenshot pair.

Usage:
  python tool/diff_visual_qa.py <original.png> <flutter.png> <diff_out.png>

Prints one JSON line with stats; writes a heatmap diff PNG
(red = high delta, black = identical) scaled to the FLUTTER size.
"""
import json
import sys

from PIL import Image, ImageChops


def main() -> int:
    orig_path, flut_path, out_path = sys.argv[1], sys.argv[2], sys.argv[3]
    orig = Image.open(orig_path).convert('RGB')
    flut = Image.open(flut_path).convert('RGB')
    if orig.size != flut.size:
        orig = orig.resize(flut.size, Image.BILINEAR)

    diff = ImageChops.difference(orig, flut)
    gray = diff.convert('L')
    hist = gray.histogram()
    total = gray.size[0] * gray.size[1]
    sum_abs = sum(i * n for i, n in enumerate(hist))
    changed = total - hist[0]
    big = sum(n for i, n in enumerate(hist) if i > 32)

    # heatmap: amplify delta, map to red over black
    heat = gray.point(lambda v: min(255, v * 4))
    heatmap = Image.merge('RGB', (heat, heat.point(lambda v: 0), heat.point(lambda v: 0)))
    heatmap.save(out_path)

    print(json.dumps({
        'pair': [orig_path.split('/')[-1], flut_path.split('/')[-1]],
        'size': list(flut.size),
        'mean_abs_diff': round(sum_abs / total, 3),
        'pct_pixels_changed': round(100.0 * changed / total, 2),
        'pct_pixels_delta_gt32': round(100.0 * big / total, 2),
        'diff_png': out_path,
    }))
    return 0


if __name__ == '__main__':
    sys.exit(main())
