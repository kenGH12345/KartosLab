# -*- coding: utf-8 -*-
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

PATCHES: dict[str, tuple[str, list[tuple[str, str]]]] = {
    "test/chemistry/build_an_atom/atom_screen_test.dart": (
        "import 'package:kratos/chemistry/build_an_atom/baa_strings.dart';",
        [("find.text('Atom')", "find.text(BaaStrings.atom)")],
    ),
    "test/chemistry/build_an_atom/phase7_lifecycle_regression_test.dart": (
        "import 'package:kratos/chemistry/build_an_atom/baa_strings.dart';",
        [("find.text('Atom')", "find.text(BaaStrings.atom)")],
    ),
    "test/chemistry/acid_base_solutions/home/abs_home_lifecycle_test.dart": (
        "import 'package:kratos/chemistry/acid_base_solutions/abs_strings.dart';",
        [("find.text('Acid')", "find.text(AbsStrings.acid)")],
    ),
    "test/chemistry/acid_base_solutions/my_solution_screen_test.dart": (
        "import 'package:kratos/chemistry/acid_base_solutions/abs_strings.dart';",
        [("find.text('Acid')", "find.text(AbsStrings.acid)")],
    ),
    "test/balancing_chemical_equations/visual/visual_qa_test.dart": (
        "import 'package:kratos/balancing_chemical_equations/bce_strings.dart';",
        [("find.text('Balanced')", "find.text(BceStrings.balanced)")],
    ),
    "test/balancing_chemical_equations/intro/intro_screen_test.dart": (
        "import 'package:kratos/balancing_chemical_equations/bce_strings.dart';",
        [
            ("find.text('Reactants')", "find.text(BceStrings.reactants)"),
            ("find.text('Products')", "find.text(BceStrings.products)"),
            ("find.text('Balanced')", "find.text(BceStrings.balanced)"),
        ],
    ),
    "test/balancing_chemical_equations/equations/equations_screen_test.dart": (
        "import 'package:kratos/balancing_chemical_equations/bce_strings.dart';",
        [
            ("find.text('Reactants')", "find.text(BceStrings.reactants)"),
            ("find.text('Products')", "find.text(BceStrings.products)"),
            ("find.text('Balanced')", "find.text(BceStrings.balanced)"),
        ],
    ),
    "test/beers_law_lab/beers_law_view_test.dart": (
        "import 'package:kratos/beers_law_lab/bll_strings.dart';",
        [("find.text('Concentration')", "find.text(BllStrings.concentration)")],
    ),
    "test/beers_law_lab/beers_law_lab_home_lifecycle_test.dart": (
        "import 'package:kratos/beers_law_lab/bll_strings.dart';",
        [("find.text('Concentration')", "find.text(BllStrings.concentration)")],
    ),
    "test/beers_law_lab/beers_law_visual_qa_golden_test.dart": (
        "import 'package:kratos/beers_law_lab/bll_strings.dart';",
        [("find.text('Concentration')", "find.text(BllStrings.concentration)")],
    ),
    "test/isotopes_and_atomic_mass/make_isotopes_view/make_isotopes_view_test.dart": (
        "import 'package:kratos/chemistry/isotopes_and_atomic_mass/iaam_strings.dart';",
        [("find.text('Atomic Mass')", "find.text(IaamStrings.atomicMass)")],
    ),
}


def ensure_import(text: str, import_line: str) -> str:
    if import_line in text:
        return text
    lines = text.splitlines(keepends=True)
    idx = 0
    for i, line in enumerate(lines):
        if line.startswith("import "):
            idx = i + 1
    lines.insert(idx, import_line + "\n")
    return "".join(lines)


def main() -> None:
    for rel, (imp, reps) in PATCHES.items():
        path = ROOT / rel
        if not path.exists():
            print(f"MISSING {rel}")
            continue
        text = path.read_text(encoding="utf-8")
        orig = text
        text = ensure_import(text, imp)
        for a, b in reps:
            text = text.replace(a, b)
        if text != orig:
            path.write_text(text, encoding="utf-8")
            print(f"updated {rel}")
        else:
            print(f"unchanged {rel}")
    print("DONE")


if __name__ == "__main__":
    main()
