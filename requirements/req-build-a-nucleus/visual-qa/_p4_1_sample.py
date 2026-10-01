"""P4-1 screenshot samples. Median of 5x5, skip if variance high (AA edge)."""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent


def hex_of(rgb: tuple[int, int, int]) -> str:
    return '#{:02X}{:02X}{:02X}'.format(*rgb)


def sample(im: Image.Image, x: int, y: int, r: int = 2) -> dict:
    x = max(r, min(im.width - r - 1, x))
    y = max(r, min(im.height - r - 1, y))
    pix = im.convert('RGB')
    cells = []
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            cells.append(pix.getpixel((x + dx, y + dy)))
    med = tuple(sorted(c[i] for c in cells)[len(cells) // 2] for i in range(3))
    var = sum((c[i] - med[i]) ** 2 for c in cells for i in range(3)) / len(cells)
    return {
        'xy': [x, y],
        'rgb': list(med),
        'hex': hex_of(med),
        'var': round(var, 1),
        'edge_suspect': var > 400,
    }


def run() -> None:
    out: dict = {}

    orig = Image.open(ROOT / 'decay-first' / 'original_decay_screen1.png')
    out['original_decay_fe69'] = {
        'size': [orig.width, orig.height],
        'note': '1024x672 page. Avoid AA edges.',
        'samples': {
            'page_bg_left': sample(orig, 80, 280),
            'page_bg_center_away_nucleus': sample(orig, 200, 200),
            'electron_cloud_mid': sample(orig, 360, 310),
            'nucleus_cluster_center': sample(orig, 341, 340),
            'half_life_info_bg': sample(orig, 200, 40),
            'info_button': sample(orig, 140, 28),
            'available_decays_panel': sample(orig, 880, 280),
            'decay_button_enabled': sample(orig, 820, 220),
            'decay_button_disabled': sample(orig, 820, 160),
            'counter_panel': sample(orig, 900, 80),
            'symbol_panel': sample(orig, 900, 130),
            'reset_button': sample(orig, 980, 580),
            'undo_button': sample(orig, 720, 400),
            'joist_bar': sample(orig, 512, 650),
            'electron_cloud_checkbox_area': sample(orig, 780, 560),
        },
    }

    fl = Image.open(ROOT / 'decay-first' / 'flutter_decay_fe69.png')
    # logical 1280x800 @ DPR 2
    def L(x: float, y: float) -> tuple[int, int]:
        return int(x * 2), int(y * 2)

    out['flutter_decay_fe69'] = {
        'size': [fl.width, fl.height],
        'note': '2560x1600 physical, logical*2.',
        'samples': {
            'scaffold_bg': sample(fl, *L(200, 300)),
            'appbar': sample(fl, *L(640, 28)),
            'canvas_bg_near_nucleus': sample(fl, *L(426, 543)),
            'electron_cloud': sample(fl, *L(480, 543)),
            'available_decays_panel': sample(fl, *L(1228, 250)),
            'decay_alpha_btn': sample(fl, *L(1228, 297)),
            'decay_beta_minus_btn': sample(fl, *L(1228, 342)),
            'reset_icon_area': sample(fl, *L(1228, 680)),
            'half_life_band': sample(fl, *L(640, 208)),
            'generator_area': sample(fl, *L(427, 757)),
        },
    }

    ch = Image.open(ROOT / 'chart-intro' / 'flutter_chart_intro_c12_partial.png')
    out['flutter_chart_intro_c12_partial'] = {
        'size': [ch.width, ch.height],
        'note': '1280x800 DPR1. NineGrid FittedBox shrinks midRight.',
        'samples': {
            'scaffold_bg': sample(ch, 400, 200),
            'appbar': sample(ch, 640, 28),
            'periodic_table_panel': sample(ch, 1228, 82),
            'chart_panel': sample(ch, 1228, 380),
            'element_area': sample(ch, 52, 65),
        },
    }

    zg = Image.open(ROOT / 'chart-intro' / 'flutter_chart_intro_c12_zoom.png')
    out['flutter_chart_intro_c12_zoom'] = {
        'size': [zg.width, zg.height],
        'samples': {
            'chart_panel': sample(zg, 1228, 380),
            'full_chart_btn': sample(zg, 1240, 431),
        },
    }

    dg = Image.open(ROOT / 'chart-intro' / 'flutter_chart_intro_c12_dialog.png')
    out['flutter_chart_intro_c12_dialog'] = {
        'size': [dg.width, dg.height],
        'samples': {
            'dialog_bg': sample(dg, 620, 280),
            'dialog_info': sample(dg, 644, 350),
            'scrim': sample(dg, 80, 80),
        },
    }

    dest = ROOT / 'p4_1_screenshot_samples.json'
    dest.write_text(json.dumps(out, indent=2), encoding='utf-8')
    print(dest)
    for name, block in out.items():
        print('\n==', name, block.get('size'))
        for k, v in block['samples'].items():
            flag = ' EDGE?' if v['edge_suspect'] else ''
            print(f"  {k:32} {v['hex']} {v['rgb']} var={v['var']}{flag}")


if __name__ == '__main__':
    run()
