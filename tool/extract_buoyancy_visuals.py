"""Extract Buoyancy source textures + duck mesh into Flutter assets/Dart."""
from pathlib import Path
import re
import base64

root = Path('.')
common = Path('phet sourses/density-buoyancy-common-main')
out_img = Path('assets/buoyancy/images')
out_img.mkdir(parents=True, exist_ok=True)

wanted = {
    'Wood26_col_jpg.ts': 'wood_col.jpg',
    'Bricks25_col_jpg.ts': 'brick_col.jpg',
    'Styrofoam_001_col_jpg.ts': 'foam_col.jpg',
    'Ice01_col_jpg.ts': 'ice_col.jpg',
    'Metal10_col_jpg.ts': 'metal_col.jpg',
    'Metal002_col_jpg.ts': 'grey_metal_col.jpg',
    'boat_icon_png.ts': 'boat_icon.png',
    'bottle_icon_png.ts': 'bottle_icon.png',
    'singleCuboidIcon_png.ts': 'single_cuboid.png',
    'doubleCuboidIcon_png.ts': 'double_cuboid.png',
}
extracted = []
for d in [common / 'images', common / 'mipmaps']:
    for ts, dest in wanted.items():
        p = d / ts
        if not p.exists():
            continue
        t = p.read_text(encoding='utf-8', errors='ignore')
        m = re.search(r"image.src = 'data:image/([^;]+);base64,([^']+)'", t)
        if not m:
            m = re.search(r"data:image/([^;]+);base64,([^']+)'", t)
        if not m:
            print('no data url', p)
            continue
        (out_img / dest).write_bytes(base64.b64decode(m.group(2)))
        extracted.append((dest, (out_img / dest).stat().st_size))
print('textures', extracted)

duck_ts = (common / 'js/buoyancy/model/shapes/DuckData.ts').read_text(encoding='utf-8')
m = re.search(
    r"'position'\s*:\s*\{[^}]*?'array'\s*:\s*\[([^\]]+)\]",
    duck_ts,
    re.S,
)
if not m:
    raise SystemExit('duck position not found')
nums = [float(x) for x in m.group(1).split(',') if x.strip()]
print('floats', len(nums), 'verts', len(nums) // 3)

im = re.search(
    r"'index'\s*:\s*\{[^}]*?'array'\s*:\s*\[([^\]]+)\]",
    duck_ts,
    re.S,
)
print('index', bool(im))
if im:
    idx = [int(float(x)) for x in im.group(1).split(',') if x.strip()]
    print('indices', len(idx), 'tris', len(idx) // 3)
    tris = len(idx) // 3
    stride = max(1, tris // 2500)
    kept = []
    for i in range(0, tris, stride):
        kept.extend(idx[i * 3:i * 3 + 3])
    used = sorted(set(kept))
    remap = {old: i for i, old in enumerate(used)}
    new_pos = []
    for old in used:
        new_pos.extend(nums[old * 3:old * 3 + 3])
    new_idx = [remap[j] for j in kept]
    print('kept verts', len(used), 'idx', len(new_idx))
else:
    ntris = len(nums) // 9
    stride = max(1, ntris // 2500)
    new_pos = []
    new_idx = []
    vi = 0
    for t in range(0, ntris, stride):
        new_pos.extend(nums[t * 9:t * 9 + 9])
        new_idx.extend([vi, vi + 1, vi + 2])
        vi += 3
    print('unindexed tris', ntris, 'kept', len(new_idx) // 3)


def fmt_nums(arr, per=12, ints=False):
    lines = []
    for i in range(0, len(arr), per):
        chunk = arr[i:i + per]
        if ints:
            lines.append('  ' + ', '.join(str(int(x)) for x in chunk) + ',')
        else:
            lines.append('  ' + ', '.join(f'{x:.6g}' for x in chunk) + ',')
    return '\n'.join(lines)


out_mesh = Path('lib/buoyancy/rendering/mesh')
out_mesh.mkdir(parents=True, exist_ok=True)
(out_mesh / 'duck_source_mesh.dart').write_text(
    f'''/// Source duck BufferGeometry from DuckData.ts (LOCAL 0c835c64).
/// Visual mesh only — physics remains ellipsoid.
library;

class DuckSourceMesh {{
  DuckSourceMesh._();

  static const positions = <double>[
{fmt_nums(new_pos)}
  ];

  static const indices = <int>[
{fmt_nums(new_idx, per=18, ints=True)}
  ];

  static int get vertexCount => positions.length ~/ 3;
  static int get triangleCount => indices.length ~/ 3;
}}
''',
    encoding='utf-8',
)
print('wrote duck', (out_mesh / 'duck_source_mesh.dart').stat().st_size)

# --- BoatDesign.getPrimaryGeometry (source algorithm, reduced samples) ---
import math


def cubic_bezier(p0, p1, p2, p3, t):
    u = 1 - t
    return (
        u * u * u * p0[0] + 3 * u * u * t * p1[0] + 3 * u * t * t * p2[0] + t * t * t * p3[0],
        u * u * u * p0[1] + 3 * u * u * t * p1[1] + 3 * u * t * t * p2[1] + t * t * t * p3[1],
    )


DESIGN_WALL = 2.4
DESIGN_H = 50.0
ONE_LITER_SCALE = 0.0011606822810277906
CX, CY = 127.01221454497677, -30.985933407134237


def height_ratio_from_design_y(y):
    return (y - (-DESIGN_H)) / (0 - (-DESIGN_H))


def control_points(height_ratio, is_inside):
    v0 = [0.0, 0.0]
    v1 = [50.0, 50.0]
    v2 = [150.0, 50.0]
    v3 = [200.0, 40.0]
    ratio = math.sqrt(max(0.0, height_ratio))
    opposite = 1 - ratio
    v0[0] += 50 * opposite
    v1[0] += 60 * opposite
    v1[1] += -20 * opposite
    v2[1] += -15 * opposite
    v3[1] += -5 * opposite
    if not is_inside:
        v0[0] += -(1.4 + 0.5 * opposite) * DESIGN_WALL
        v1[0] += -0.9 * DESIGN_WALL
        v1[1] += 0.9 * DESIGN_WALL
        v2[1] += DESIGN_WALL
        v3[0] += DESIGN_WALL
        v3[1] += (0.9 - 0.1 * ratio) * DESIGN_WALL
    return v0, v1, v2, v3


def design_to_model(x, y, z, liters=1.0):
    scale = (liters ** (1 / 3)) * ONE_LITER_SCALE
    return ((x - CX) * scale, (y - CY) * scale, z * scale)


def get_rows(is_inside, height_samples=14, parametric_samples=16):
    rows = []
    for sample in range(height_samples):
        design_y = (-DESIGN_H + (DESIGN_WALL if is_inside else 0)) * sample / (height_samples - 1)
        cps = control_points(height_ratio_from_design_y(design_y), is_inside)
        row = []
        for p in range(parametric_samples):
            t = p / (parametric_samples - 1)
            px, pz = cubic_bezier(*cps, t)
            row.append(design_to_model(px, design_y, pz))
        rows.append(row)
    return rows


def write_grid(positions, rows, reverse):
    for i in range(len(rows) - 1):
        for j in range(len(rows[i]) - 1):
            pA, pB = rows[i][j], rows[i + 1][j]
            pC, pD = rows[i][j + 1], rows[i + 1][j + 1]
            if reverse:
                tris = (pA, pB, pC, pC, pB, pD)
            else:
                tris = (pA, pC, pB, pC, pD, pB)
            for p in tris:
                positions.extend(p)


def write_flat(positions, front, back):
    for i in range(len(front) - 1):
        pA, pB = back[i], back[i + 1]
        pC, pD = front[i], front[i + 1]
        for p in (pA, pC, pB, pC, pD, pB):
            positions.extend(p)


def flip_row(row):
    return [(x, y, -z) for x, y, z in row]


boat_pos = []
ext = get_rows(False)
inn = get_rows(True)
write_grid(boat_pos, ext, True)
write_grid(boat_pos, inn, False)
write_grid(boat_pos, [flip_row(r) for r in ext], False)
write_grid(boat_pos, [flip_row(r) for r in inn], True)
write_flat(boat_pos, inn[-1], flip_row(inn[-1]))
write_flat(boat_pos, flip_row(ext[-1]), ext[-1])
write_flat(boat_pos, ext[0], inn[0])
write_flat(boat_pos, flip_row(inn[0]), flip_row(ext[0]))
boat_idx = list(range(len(boat_pos) // 3))
xs = boat_pos[0::3]
ys = boat_pos[1::3]
zs = boat_pos[2::3]
print('boat verts', len(boat_idx), 'bounds', min(xs), max(xs), min(ys), max(ys), min(zs), max(zs))

(out_mesh / 'boat_source_mesh.dart').write_text(
    f'''/// Boat visual from BoatDesign.getPrimaryGeometry (LOCAL 0c835c64).
/// One-liter hull; runtime scale = (V/0.001)^(1/3). Physics uses piecewise tables.
library;

class BoatSourceMesh {{
  BoatSourceMesh._();

  static const positions = <double>[
{fmt_nums(boat_pos)}
  ];

  static const indices = <int>[
{fmt_nums(boat_idx, per=18, ints=True)}
  ];

  static int get vertexCount => positions.length ~/ 3;
  static int get triangleCount => indices.length ~/ 3;
}}
''',
    encoding='utf-8',
)
print('wrote boat', (out_mesh / 'boat_source_mesh.dart').stat().st_size)

# --- Bottle visual: source-of-revolution from Bottle.ts constants (not a Cylinder widget) ---
FULL_R = 0.85
SCALE = 0.08495233866810234
CXB, CYB = 2.6705419248600877, -0.004634939286311409
# profile x,r in logical coords then scaled like Bottle.logicalToModel
profile = [
    (0.0, 0.18),
    (0.15, 0.18),
    (0.35, 0.22),
    (0.55, 0.28),
    (1.2, 0.85),
    (3.8, 0.85),
    (4.2, 0.78),
    (4.6, 0.55),
    (4.85, 0.25),
    (5.0, 0.0),
]
radial = 16
bpos = []
bidx = []


def bottle_model(lx, ly, lz):
    return (
        (lx - CXB) * SCALE,
        (ly - CYB) * SCALE,
        lz * SCALE,
    )


for i in range(len(profile) - 1):
    x0, r0 = profile[i]
    x1, r1 = profile[i + 1]
    for j in range(radial):
        t0 = 2 * math.pi * j / radial
        t1 = 2 * math.pi * ((j + 1) % radial) / radial
        p00 = bottle_model(x0, r0 * math.sin(t0), r0 * math.cos(t0))
        p01 = bottle_model(x0, r0 * math.sin(t1), r0 * math.cos(t1))
        p10 = bottle_model(x1, r1 * math.sin(t0), r1 * math.cos(t0))
        p11 = bottle_model(x1, r1 * math.sin(t1), r1 * math.cos(t1))
        base = len(bpos) // 3
        for p in (p00, p10, p01, p01, p10, p11):
            bpos.extend(p)
        bidx.extend([base, base + 1, base + 2, base + 3, base + 4, base + 5])

bxs, bys, bzs = bpos[0::3], bpos[1::3], bpos[2::3]
print('bottle verts', len(bidx), 'bounds', min(bxs), max(bxs), min(bys), max(bys), min(bzs), max(bzs))

(out_mesh / 'bottle_source_mesh.dart').write_text(
    f'''/// Bottle visual lathe from Bottle.ts FULL_RADIUS / TEN_LITER_SCALE (LOCAL 0c835c64).
/// Not a Flutter Cylinder; physics uses TEN_LITER displacement tables.
library;

class BottleSourceMesh {{
  BottleSourceMesh._();

  static const positions = <double>[
{fmt_nums(bpos)}
  ];

  static const indices = <int>[
{fmt_nums(bidx, per=18, ints=True)}
  ];

  static int get vertexCount => positions.length ~/ 3;
  static int get triangleCount => indices.length ~/ 3;
}}
''',
    encoding='utf-8',
)
print('wrote bottle', (out_mesh / 'bottle_source_mesh.dart').stat().st_size)

