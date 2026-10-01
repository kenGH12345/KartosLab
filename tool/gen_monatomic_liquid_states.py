#!/usr/bin/env python3
"""Convert monatomic_liquid_states.json to a Dart const map file."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "lib/chemistry/states_of_matter/model/engine/data/monatomic_liquid_states.json"
OUT = ROOT / "lib/chemistry/states_of_matter/model/engine/data/monatomic_liquid_states.dart"


def main() -> None:
    data = json.loads(SRC.read_text(encoding="utf-8"))
    parts: list[str] = [
        "// Generated from monatomic_liquid_states.json — do not edit by hand.",
        "// Liquid phase snapshot positions/velocities for monatomic substances.",
        "",
        "/// Saved liquid initial states for [MonatomicPhaseStateChanger].",
        "class MonatomicLiquidStates {",
        "  MonatomicLiquidStates._();",
        "",
    ]

    for key, dart_name in [
        ("neon", "neon"),
        ("argon", "argon"),
        ("adjustableAttraction", "adjustableAttraction"),
    ]:
        s = data[key]
        parts.append(f"  static const Map<String, dynamic> {dart_name} = {{")
        parts.append(f"    'numberOfMolecules': {s['numberOfMolecules']},")
        parts.append(f"    'atomsPerMolecule': {s['atomsPerMolecule']},")
        parts.append("    'moleculeCenterOfMassPositions': [")
        for it in s["moleculeCenterOfMassPositions"]:
            parts.append(f"      {{'x': {it['x']}, 'y': {it['y']}}},")
        parts.append("    ],")
        parts.append("    'moleculeVelocities': [")
        for it in s["moleculeVelocities"]:
            parts.append(f"      {{'x': {it['x']}, 'y': {it['y']}}},")
        parts.append("    ],")
        parts.append("  };")
        parts.append("")

    parts.append("}")
    parts.append("")
    OUT.write_text("\n".join(parts), encoding="utf-8")
    print(f"Wrote {OUT} ({OUT.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
