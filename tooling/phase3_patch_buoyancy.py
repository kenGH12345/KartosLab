# -*- coding: utf-8 -*-
from pathlib import Path

root = Path(__file__).resolve().parents[1]
buoy = root / 'lib' / 'buoyancy'

reps = {
    "title: 'Object Density'": 'title: BuoyancyStrings.objectDensity',
    "title: '% Submerged'": 'title: BuoyancyStrings.percentSubmerged',
    "title: 'Density Comparison'": 'title: BuoyancyStrings.densityComparison',
    "tag: 'Brick'": 'tag: BuoyancyStrings.brick',
    "Text('Block A:": "Text(BuoyancyStrings.blockDensity('A',",
    "Text('Block B:": "Text(BuoyancyStrings.blockDensity('B',",
    "Text('Fluid:": "Text(BuoyancyStrings.fluidDensityValue(",
}

# Special compare screen patterns need careful handling — skip complex ones here.

for f in buoy.rglob('*.dart'):
    t = f.read_text(encoding='utf-8')
    orig = t
    for a, b in reps.items():
        if a in t and a.startswith("Text("):
            continue  # handle separately
        t = t.replace(a, b)
    if t != orig and 'BuoyancyStrings' in t and 'buoyancy_strings.dart' not in t:
        rel = f.relative_to(buoy)
        depth = len(rel.parts) - 1
        prefix = '../' * depth if depth else ''
        imp = f"import '{prefix}buoyancy_strings.dart';\n" if prefix else "import 'buoyancy_strings.dart';\n"
        lines = t.splitlines(True)
        insert_at = 0
        for i, l in enumerate(lines):
            if l.startswith('import '):
                insert_at = i + 1
        lines.insert(insert_at, imp)
        t = ''.join(lines)
    if t != orig:
        f.write_text(t, encoding='utf-8')
        print('updated', f.relative_to(root))

# fluid displaced import
fd = buoy / 'shared' / 'widgets' / 'buoyancy_fluid_displaced_panel.dart'
t = fd.read_text(encoding='utf-8')
if 'buoyancy_strings.dart' not in t and 'BuoyancyStrings' in t:
    t = t.replace(
        "import 'buoyancy_accordion_stub.dart';\n",
        "import '../../buoyancy_strings.dart';\nimport 'buoyancy_accordion_stub.dart';\n",
    )
    fd.write_text(t, encoding='utf-8')
    print('fixed import fluid_displaced')
