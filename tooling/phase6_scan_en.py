# -*- coding: utf-8 -*-
from __future__ import annotations

import re
from pathlib import Path

ROOTS = [
    "lib/chemistry",
    "lib/balancing_chemical_equations",
    "lib/molecule_shapes",
    "lib/molecules_and_light",
    "lib/reactants_products_and_leftovers",
    "lib/beers_law_lab",
    "lib/rutherford_scattering",
]

NEEDLES = [
    "Reset All",
    "Proton",
    "Neutron",
    "Electron",
    "Atom",
    "Element",
    "Molecule",
    "Acid",
    "Base",
    "Solution",
    "Concentration",
    "Molarity",
    "Reactants",
    "Products",
    "Leftovers",
    "Balanced",
    "Not balanced",
    "Check",
    "Try Again",
    "Show Answer",
    "Next",
    "Continue",
    "Intro",
    "Equations",
    "Game",
    "Solid",
    "Liquid",
    "Gas",
    "Heat",
    "Cool",
    "Pressure",
    "Temperature",
    "Electronegativity",
    "Bond Dipole",
    "Partial Charges",
    "Covalent",
    "Ionic",
    "Lone Pair",
    "Bonding",
    "Geometry",
    "Wavelength",
    "Photon",
    "Isotope",
    "Atomic Number",
    "Mass Number",
    "Nucleus",
    "Symbol",
    "Water",
    "Solute",
    "Solvent",
    "Neutral",
    "My Solution",
    "Macro",
    "Micro",
    "Two Atoms",
    "Three Atoms",
    "Real Molecules",
    "Sandwiches",
    "Molecules",
    "Score",
    "Level",
]

pat = re.compile("|".join(re.escape(n) for n in NEEDLES))
hits = []
for root in ROOTS:
    p = Path(root)
    if not p.exists():
        continue
    for f in p.rglob("*.dart"):
        if f.name.endswith("_strings.dart") and "bam_strings" not in f.name:
            continue
        if "debug_" in f.name:
            continue
        text = f.read_text(encoding="utf-8", errors="ignore")
        for i, line in enumerate(text.splitlines(), 1):
            s = line.strip()
            if s.startswith("//") or s.startswith("import ") or s.startswith("export "):
                continue
            if "fontFamily" in line or "assets/" in line:
                continue
            m = pat.search(line)
            if not m:
                continue
            needle = m.group(0)
            if f"'{needle}'" not in line and f'"{needle}"' not in line:
                continue
            hits.append(f"{f.as_posix()}:{i}:{needle}")

out = Path("tooling/phase6_en_hits.txt")
out.write_text("\n".join(hits), encoding="utf-8")
print(f"wrote {out} count={len(hits)}")
for h in hits[:120]:
    print(h)
