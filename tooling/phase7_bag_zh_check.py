# -*- coding: utf-8 -*-
"""Check migrated *Strings bags for remaining English natural-language constants."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BAGS = list((ROOT / "lib").rglob("*_strings.dart")) + list((ROOT / "lib").rglob("*strings.dart"))
# dedupe
BAGS = sorted({p.resolve() for p in BAGS})

CJK = re.compile(r"[\u4e00-\u9fff]")
LATIN = re.compile(r"[A-Za-z]{3,}")
CONST = re.compile(
    r"static\s+const\s+String\s+(\w+)\s*=\s*'([^']*)'|static\s+const\s+(\w+)\s*=\s*'([^']*)'"
)

ALLOWED = {"PhET", "KartosLab", "Kratos", "pH", "RGB", "VSEPR", "WebGL", "OK", "HA", "MOH"}

# only bags under migrated domains
MIG_PREFIX = (
    "lib/forces", "lib/collision_lab", "lib/vector_addition", "lib/projectile_motion",
    "lib/pendulum_lab", "lib/balancing_act", "lib/friction", "lib/hookes_law",
    "lib/masses_and_springs_basics", "lib/energy_skate_park", "lib/gravity_force_lab",
    "lib/gravity_force_lab_basics", "lib/astronomy", "lib/density", "lib/buoyancy",
    "lib/under_pressure", "lib/gases_intro", "lib/gas_properties", "lib/diffusion",
    "lib/membrane_transport", "lib/ohms_law", "lib/resistance_in_a_wire",
    "lib/cck_ac_virtual_lab", "lib/capacitor_lab_basics", "lib/charges_and_fields",
    "lib/faradays_law", "lib/john_travoltage", "lib/balloons_and_static_electricity",
    "lib/magnetism", "lib/bending_light", "lib/color_vision", "lib/wave_on_a_string",
    "lib/waves_intro", "lib/normal_modes", "lib/fourier_making_waves", "lib/sound",
    "lib/radio_waves", "lib/quantum_measurement", "lib/physics/quantum_wave_interference",
    "lib/quantum_coin_toss", "lib/chemistry", "lib/beers_law_lab", "lib/rutherford_scattering",
    "lib/molecule_shapes", "lib/molecules_and_light", "lib/reactants_products_and_leftovers",
    "lib/balancing_chemical_equations",
)

hits = []
ok_bags = 0
checked = 0
for p in BAGS:
    rel = p.relative_to(ROOT).as_posix()
    if not any(rel.startswith(pref) for pref in MIG_PREFIX):
        continue
    if "a11y" in rel and "gfl_a11y" in rel:
        pass
    checked += 1
    text = p.read_text(encoding="utf-8", errors="ignore")
    bag_en = []
    for m in CONST.finditer(text):
        name = m.group(1) or m.group(3)
        val = m.group(2) if m.group(1) else m.group(4)
        if not val or CJK.search(val):
            continue
        if val in ALLOWED:
            continue
        if not LATIN.search(val):
            continue
        # skip pure symbols / units
        if re.fullmatch(r"[A-Za-z0-9₂₃⁺⁻°%/\s·.]+", val) and len(val) <= 6:
            continue
        bag_en.append((name, val))
    if bag_en:
        hits.append((rel, bag_en))
    else:
        ok_bags += 1

out = ROOT / "tooling/phase7_bag_en_hits.txt"
lines = [f"checked={checked} clean={ok_bags} dirty={len(hits)}"]
for rel, items in hits:
    lines.append(f"\n## {rel}")
    for n, v in items[:40]:
        lines.append(f"  {n} = {v}")
out.write_text("\n".join(lines), encoding="utf-8")
print("\n".join(lines[:80]))
print("wrote", out)
