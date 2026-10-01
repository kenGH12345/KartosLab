"""Batch diff ORIGINAL vs FLUTTER for plinko-probability visual-qa."""
import json
import os
import glob
from PIL import Image, ImageChops

ROOT = os.path.join('requirements', 'req-plinko-probability', 'visual-qa')
DIFF = os.path.join(ROOT, 'DIFF')
os.makedirs(DIFF, exist_ok=True)

states = []
for op in sorted(glob.glob(os.path.join(ROOT, 'ORIGINAL', '*.png'))):
    name = os.path.basename(op)
    fp = os.path.join(ROOT, 'FLUTTER', name)
    if not os.path.exists(fp):
        print('MISSING', name)
        continue
    orig = Image.open(op).convert('RGB')
    flut = Image.open(fp).convert('RGB')
    if orig.size != flut.size:
        orig = orig.resize(flut.size, Image.BILINEAR)
    diff = ImageChops.difference(orig, flut)
    gray = diff.convert('L')
    hist = gray.histogram()
    total = gray.size[0] * gray.size[1]
    sum_abs = sum(i * n for i, n in enumerate(hist))
    changed = total - hist[0]
    big = sum(n for i, n in enumerate(hist) if i > 32)
    heat = gray.point(lambda v: min(255, v * 4))
    heatmap = Image.merge('RGB', (heat, heat.point(lambda v: 0), heat.point(lambda v: 0)))
    out = os.path.join(DIFF, name.replace('.png', '_diff.png'))
    heatmap.save(out)
    row = {
        'state': name.replace('.png', ''),
        'mean_abs_diff': round(sum_abs / total, 3),
        'pct_pixels_changed': round(100.0 * changed / total, 2),
        'pct_pixels_delta_gt32': round(100.0 * big / total, 2),
        'diff_png': out.replace('\\', '/'),
    }
    states.append(row)
    print(f"{row['state']}: mean={row['mean_abs_diff']} changed%={row['pct_pixels_changed']} gt32%={row['pct_pixels_delta_gt32']}")

with open(os.path.join(ROOT, 'diff_stats.jsonl'), 'w', encoding='utf-8') as f:
    for s in states:
        f.write(json.dumps(s) + '\n')
print('pairs', len(states))
