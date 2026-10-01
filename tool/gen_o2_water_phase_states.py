#!/usr/bin/env python3
"""Extract/generate Dart const maps for O2 liquid + water solid/liquid snapshots."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "lib/chemistry/states_of_matter/model/engine/data"


def emit_state(name: str, s: dict, indent: str = "  ") -> str:
    n = s["numberOfMolecules"]
    lines: list[str] = [
        f"{indent}static const Map<String, dynamic> {name} = {{",
        f"{indent}  'numberOfMolecules': {s['numberOfMolecules']},",
        f"{indent}  'atomsPerMolecule': {s['atomsPerMolecule']},",
        f"{indent}  'moleculeCenterOfMassPositions': [",
    ]
    for it in s["moleculeCenterOfMassPositions"][:n]:
        lines.append(f"{indent}    {{'x': {it['x']}, 'y': {it['y']}}},")
    lines.append(f"{indent}  ],")
    lines.append(f"{indent}  'moleculeVelocities': [")
    for it in s["moleculeVelocities"][:n]:
        lines.append(f"{indent}    {{'x': {it['x']}, 'y': {it['y']}}},")
    lines.append(f"{indent}  ],")
    if "moleculeRotationAngles" in s:
        angs = s["moleculeRotationAngles"][:n]
        rates = s.get("moleculeRotationRates", [])[:n]
        lines.append(f"{indent}  'moleculeRotationAngles': [")
        for a in angs:
            lines.append(f"{indent}    {a},")
        lines.append(f"{indent}  ],")
        if rates:
            lines.append(f"{indent}  'moleculeRotationRates': [")
            for r in rates:
                lines.append(f"{indent}    {r},")
            lines.append(f"{indent}  ],")
    lines.append(f"{indent}}};")
    return "\n".join(lines)


def main() -> None:
    o2 = json.loads((DATA / "diatomic_liquid_states.json").read_text(encoding="utf-8"))
    (DATA / "diatomic_liquid_states.dart").write_text(
        "\n".join(
            [
                "// Generated from diatomic_liquid_states.json — do not edit by hand.",
                "// Liquid phase snapshot for diatomic oxygen.",
                "",
                "/// Saved liquid initial states for [DiatomicPhaseStateChanger].",
                "class DiatomicLiquidStates {",
                "  DiatomicLiquidStates._();",
                "",
                emit_state("oxygen", o2["oxygen"]),
                "",
                "}",
                "",
            ]
        ),
        encoding="utf-8",
    )
    print("wrote diatomic_liquid_states.dart")

    w = json.loads((DATA / "water_phase_states.json").read_text(encoding="utf-8"))
    (DATA / "water_phase_states.dart").write_text(
        "\n".join(
            [
                "// Generated from water_phase_states.json — do not edit by hand.",
                "// Solid/liquid phase snapshots for water.",
                "",
                "/// Saved solid/liquid initial states for [WaterPhaseStateChanger].",
                "class WaterPhaseStates {",
                "  WaterPhaseStates._();",
                "",
                emit_state("liquid", w["liquid"]["water"]),
                "",
                emit_state("solid", w["solid"]["water"]),
                "",
                "}",
                "",
            ]
        ),
        encoding="utf-8",
    )
    print("wrote water_phase_states.dart")


if __name__ == "__main__":
    main()
