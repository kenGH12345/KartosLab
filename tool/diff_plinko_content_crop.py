"""Content-crop Diff for Plinko Probability Visual QA.

A-class: PhET navbar (~63px at 1280x800) on ORIGINAL only.
B-class: sim content — crop navbar, scale ORIGINAL content to FLUTTER size, then diff.

Also writes regional mean_abs for board / cylinders / right-panel / chrome.
"""
from __future__ import annotations

import json
import os
import glob
from PIL import Image, ImageChops
import numpy as np

ROOT = os.path.join('requirements', 'req-plinko-probability', 'visual-qa')
DIFF = os.path.join(ROOT, 'DIFF_CONTENT')
os.makedirs(DIFF, exist_ok=True)

# Empirically: ORIGINAL black navbar starts ~y=737 at 1280x800
NAVBAR_H = 63

# Regional boxes in FLUTTER/content-aligned coords (1280x800)
REGIONS = {
    'board_pegs': (280, 40, 780, 420),      # triangle board
    'cylinders_hist': (200, 420, 900, 720),  # bins / histogram
    'right_panel': (980, 20, 1260, 520),     # Intro/Lab controls
    'hopper_mode': (700, 0, 980, 80),        # Lab hopperMode strip
    'bottom_chrome': (20, 680, 1260, 790),   # eraser / sound / reset
}


def detect_navbar_top(im: Image.Image) -> int:
    arr = np.asarray(im.convert('RGB'), dtype=np.float32)
    row_mean = arr.mean(axis=(1, 2))
    h = arr.shape[0]
    nav = h
    for y in range(h - 1, -1, -1):
        # Letterbox may be near-black (~0) or Scaffold dark gray (~54).
        if row_mean[y] < 80:
            nav = y
        else:
            break
    return nav if nav < h else h


def align_pair(orig: Image.Image, flut: Image.Image):
    """Crop navbar from both; resize to common content size if needed."""
    o = orig.convert('RGB')
    f = flut.convert('RGB')
    onav = detect_navbar_top(o)
    fnav = detect_navbar_top(f)
    if o.size[1] - onav < 20:
        onav = o.size[1] - NAVBAR_H
    if f.size[1] - fnav < 20:
        fnav = f.size[1]  # flutter may fill full height (legacy) or have letterbox
    o_content = o.crop((0, 0, o.size[0], onav))
    f_content = f.crop((0, 0, f.size[0], fnav))
    # Common size: FLUTTER content (preferred after letterbox capture)
    target = f_content.size
    if o_content.size != target:
        o_aligned = o_content.resize(target, Image.Resampling.BILINEAR)
    else:
        o_aligned = o_content
    return o_aligned, f_content, onav, fnav


def stats(diff_gray: Image.Image):
    hist = diff_gray.histogram()
    total = diff_gray.size[0] * diff_gray.size[1]
    sum_abs = sum(i * n for i, n in enumerate(hist))
    changed = total - hist[0]
    big = sum(n for i, n in enumerate(hist) if i > 32)
    return {
        'mean_abs_diff': round(sum_abs / total, 3),
        'pct_pixels_changed': round(100.0 * changed / total, 2),
        'pct_pixels_delta_gt32': round(100.0 * big / total, 2),
    }


def region_mean(arr: np.ndarray, box):
    x0, y0, x1, y1 = box
    h, w = arr.shape[:2]
    x0, x1 = max(0, x0), min(w, x1)
    y0, y1 = max(0, y0), min(h, y1)
    patch = arr[y0:y1, x0:x1]
    if patch.size == 0:
        return None
    return round(float(np.abs(patch).mean()), 3)


states = []
for op in sorted(glob.glob(os.path.join(ROOT, 'ORIGINAL', '*.png'))):
    name = os.path.basename(op)
    fp = os.path.join(ROOT, 'FLUTTER', name)
    if not os.path.exists(fp):
        print('MISSING', name)
        continue
    orig = Image.open(op)
    flut = Image.open(fp)
    o_al, f_al, onav, fnav = align_pair(orig, flut)
    diff = ImageChops.difference(o_al, f_al)
    gray = diff.convert('L')
    row = {
        'state': name.replace('.png', ''),
        'orig_navbar_top': onav,
        'flut_navbar_top': fnav,
        **stats(gray),
    }

    # heatmap
    heat = gray.point(lambda v: min(255, v * 4))
    heatmap = Image.merge('RGB', (heat, heat.point(lambda _: 0), heat.point(lambda _: 0)))
    out = os.path.join(DIFF, name.replace('.png', '_content_diff.png'))
    heatmap.save(out)
    row['diff_png'] = out.replace('\\', '/')

    # side-by-side crop preview for key states
    if name.startswith('01_'):
        w, h = o_al.size
        preview = Image.new('RGB', (w, h * 2 + 4), (255, 0, 0))
        preview.paste(o_al, (0, 0))
        preview.paste(f_al, (0, h + 4))
        preview.save(os.path.join(DIFF, name.replace('.png', '_stack.png')))

    o_arr = np.asarray(o_al, dtype=np.float32)
    f_arr = np.asarray(f_al, dtype=np.float32)
    d_arr = o_arr - f_arr
    regions = {}
    for rname, box in REGIONS.items():
        regions[rname] = region_mean(d_arr, box)
    row['regions'] = regions

    states.append(row)
    print(
        f"{row['state']}: mean={row['mean_abs_diff']} "
        f"changed%={row['pct_pixels_changed']} gt32%={row['pct_pixels_delta_gt32']} "
        f"navO={onav}/F={fnav} regions={regions}"
    )

out_jsonl = os.path.join(ROOT, 'diff_content_stats.jsonl')
with open(out_jsonl, 'w', encoding='utf-8') as f:
    for s in states:
        f.write(json.dumps(s) + '\n')

# Summary
if states:
    means = [s['mean_abs_diff'] for s in states]
    print('---')
    print(f'pairs={len(states)} content_mean_avg={sum(means)/len(means):.3f} '
          f'min={min(means):.3f} max={max(means):.3f}')
    # region averages
    for rname in REGIONS:
        vals = [s['regions'][rname] for s in states if s['regions'].get(rname) is not None]
        if vals:
            print(f'  region {rname}: avg_mean_abs={sum(vals)/len(vals):.3f}')
print('wrote', out_jsonl)
