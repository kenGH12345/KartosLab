"""Build visual-qa manifest.json + run DIFF for every ORIGINAL/FLUTTER pair.

Scans requirements/req-pendulum-lab/visual-qa/{ORIGINAL,FLUTTER} for
NN_Name.png (+ .meta.txt), pairs states by filename, runs the pixel diff
into DIFF/, and writes manifest.json:

  { "viewport": ..., "dpr": 1, "states": [ { "state", "screen",
      "original": {...}|null, "flutter": {...}|null, "diff": {...}|null } ] }

Usage: python tool/build_visual_manifest.py
"""
import json
import re
import subprocess
import sys
from pathlib import Path

VQ = Path('requirements/req-pendulum-lab/visual-qa')
STATE_RE = re.compile(r'^(\d+)_([A-Za-z]+)_(.+)\.png$')


def parse_meta(meta_path: Path) -> dict:
    out = {}
    if meta_path.exists():
        for line in meta_path.read_text(encoding='utf-8').splitlines():
            if ': ' in line:
                k, v = line.split(': ', 1)
                out[k.strip()] = v.strip()
    return out


def collect(folder: Path) -> dict:
    states = {}
    if not folder.is_dir():
        return states
    for png in sorted(folder.glob('*.png')):
        m = STATE_RE.match(png.name)
        if not m:
            continue  # e.g. smoke_test.png handled separately
        key = png.stem
        meta = parse_meta(png.with_suffix('.meta.txt'))
        states[key] = {
            'screenshot': f'{folder.name}/{png.name}',
            'bytes': png.stat().st_size,
            'captured_at': meta.get('captured_at'),
            'source': meta.get('source'),
            'actions': json.loads(meta['actions']) if 'actions' in meta else None,
        }
    return states


def main() -> int:
    original = collect(VQ / 'ORIGINAL')
    flutter = collect(VQ / 'FLUTTER')
    (VQ / 'DIFF').mkdir(exist_ok=True)

    all_keys = sorted(set(original) | set(flutter))
    entries = []
    for key in all_keys:
        m = STATE_RE.match(key + '.png')
        num, screen, state = m.group(1), m.group(2).lower(), m.group(3)
        entry = {
            'state': key,
            'screen': screen,
            'original': original.get(key),
            'flutter': flutter.get(key),
            'diff': None,
        }
        if key in original and key in flutter:
            diff_png = VQ / 'DIFF' / f'{key}_diff.png'
            proc = subprocess.run(
                [sys.executable, 'tool/diff_visual_qa.py',
                 str(VQ / 'ORIGINAL' / f'{key}.png'),
                 str(VQ / 'FLUTTER' / f'{key}.png'),
                 str(diff_png)],
                capture_output=True, text=True)
            if proc.returncode == 0:
                stats = json.loads(proc.stdout.strip())
                entry['diff'] = {
                    'png': f'DIFF/{key}_diff.png',
                    'mean_abs_diff': stats['mean_abs_diff'],
                    'pct_pixels_changed': stats['pct_pixels_changed'],
                    'pct_pixels_delta_gt32': stats['pct_pixels_delta_gt32'],
                }
            else:
                entry['diff'] = {'error': proc.stderr.strip()[:300]}
        entries.append(entry)

    manifest = {
        'simulation': 'pendulum-lab',
        'viewport': '1280x800',
        'dpr': 1,
        'original_source': 'phet.colorado.edu latest published build',
        'flutter_source': 'local widget-test capture (RepaintBoundary.toImage)',
        'states': entries,
    }
    out = VQ / 'manifest.json'
    out.write_text(json.dumps(manifest, indent=2, ensure_ascii=False), encoding='utf-8')

    paired = sum(1 for e in entries if e['diff'] and 'png' in (e['diff'] or {}))
    only_o = [e['state'] for e in entries if e['original'] and not e['flutter']]
    only_f = [e['state'] for e in entries if e['flutter'] and not e['original']]
    print(json.dumps({
        'states_total': len(entries),
        'pairs_diffed': paired,
        'original_only': only_o,
        'flutter_only': only_f,
        'manifest': str(out),
    }, indent=1))
    return 0


if __name__ == '__main__':
    sys.exit(main())
