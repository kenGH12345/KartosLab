# -*- coding: utf-8 -*-
"""PHASE 6: patch Chemistry hard-coded English → *Strings bags."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def ensure_import(text: str, import_line: str) -> str:
    if import_line in text:
        return text
    lines = text.splitlines(keepends=True)
    idx = 0
    for i, line in enumerate(lines):
        if line.startswith("import ") or line.startswith("export "):
            idx = i + 1
    lines.insert(idx, import_line + "\n")
    return "".join(lines)


def patch_file(rel: str, replacements: list[tuple[str, str]], import_line: str | None = None) -> None:
    path = ROOT / rel
    if not path.exists():
        print(f"MISSING {rel}")
        return
    text = path.read_text(encoding="utf-8")
    orig = text
    if import_line:
        text = ensure_import(text, import_line)
    for a, b in replacements:
        if a not in text:
            print(f"MISS {rel}: {a[:80]!r}")
            continue
        text = text.replace(a, b)
    if text != orig:
        path.write_text(text, encoding="utf-8")
        print(f"updated {rel}")
    else:
        print(f"unchanged {rel}")


def main() -> None:
    bce = "import 'package:kratos/balancing_chemical_equations/bce_strings.dart';"
    baa = "import 'package:kratos/chemistry/build_an_atom/baa_strings.dart';"
    phs = "import 'package:kratos/chemistry/ph_scale/phs_strings.dart';"
    abs_ = "import 'package:kratos/chemistry/acid_base_solutions/abs_strings.dart';"
    iaam = "import 'package:kratos/chemistry/isotopes_and_atomic_mass/iaam_strings.dart';"
    ban = "import 'package:kratos/chemistry/build_a_nucleus/ban_strings.dart';"
    bll = "import 'package:kratos/beers_law_lab/bll_strings.dart';"
    mal = "import 'package:kratos/molecules_and_light/mal_strings.dart';"
    bam = "import 'package:kratos/chemistry/build_a_molecule/data/bam_strings.dart';"

    # BCE
    patch_file(
        "lib/balancing_chemical_equations/views/particles_node.dart",
        [("title: 'Reactants',", "title: BceStrings.reactants,"), ("title: 'Products',", "title: BceStrings.products,")],
        bce,
    )
    patch_file(
        "lib/balancing_chemical_equations/equations/equations_feedback_node.dart",
        [
            ("label: 'Balanced',", "label: BceStrings.balanced,"),
            ("label: 'Simplified',", "label: BceStrings.simplified,"),
            ("label: 'Not simplified',", "label: BceStrings.notSimplified,"),
        ],
        bce,
    )
    patch_file(
        "lib/balancing_chemical_equations/intro/intro_feedback_node.dart",
        [("'Balanced',", "BceStrings.balanced,")],
        bce,
    )
    patch_file(
        "lib/balancing_chemical_equations/game/game_feedback_node.dart",
        [
            ("label: 'Balanced'", "label: BceStrings.balanced"),
            ("label: 'Simplified'", "label: BceStrings.simplified"),
            ("label: 'Not simplified'", "label: BceStrings.notSimplified"),
            ("label: 'Not balanced'", "label: BceStrings.notBalanced"),
            ("label: 'Try Again'", "label: BceStrings.tryAgain"),
            ("label: 'Show Answer'", "label: BceStrings.showAnswer"),
            ("label: 'Next'", "label: BceStrings.next"),
        ],
        bce,
    )
    patch_file(
        "lib/balancing_chemical_equations/game/game_screen.dart",
        [
            ("label: 'Check',", "label: BceStrings.check,"),
            ("label: 'Next',", "label: BceStrings.next,"),
            ("label: 'Continue',", "label: BceStrings.continueLabel,"),
        ],
        bce,
    )
    # BCE home titles if still EN
    patch_file(
        "lib/balancing_chemical_equations/screens/balancing_chemical_equations_home.dart",
        [
            ("static const String title = 'Balancing Chemical Equations';", "static const String title = BceStrings.title;"),
            ("static const String subtitle = 'Intro · Equations · Game';", "static const String subtitle = BceStrings.subtitle;"),
            ("label: 'Intro'", "label: BceStrings.screenIntro"),
            ("label: 'Equations'", "label: BceStrings.screenEquations"),
            ("label: 'Game'", "label: BceStrings.screenGame"),
            ("'Intro'", "BceStrings.screenIntro"),
            ("'Equations'", "BceStrings.screenEquations"),
            ("'Game'", "BceStrings.screenGame"),
        ],
        bce,
    )

    # BAA
    patch_file(
        "lib/chemistry/build_an_atom/screens/atom_screen.dart",
        [
            ("title: 'Mass Number',", "title: BaaStrings.massNumber,"),
            ("title: const Text('Atom'),", "title: const Text(BaaStrings.atom),"),
        ],
        baa,
    )
    patch_file(
        "lib/chemistry/build_an_atom/screens/symbol_screen.dart",
        [
            ("title: 'Symbol',", "title: BaaStrings.symbol,"),
            ("title: const Text('Symbol'),", "title: const Text(BaaStrings.symbol),"),
        ],
        baa,
    )
    patch_file(
        "lib/chemistry/build_an_atom/screens/game_screen.dart",
        [("title: const Text('Game'),", "title: const Text(BaaStrings.game),")],
        baa,
    )
    patch_file(
        "lib/chemistry/build_an_atom/widgets/game/game_challenge_view.dart",
        [
            ("'Check'", "BaaStrings.check"),
            ("'Next'", "BaaStrings.next"),
            ("'Try Again'", "BaaStrings.tryAgain"),
            ("'Show Answer'", "BaaStrings.showAnswer"),
        ],
        baa,
    )

    # pH Scale
    patch_file(
        "lib/chemistry/ph_scale/view/screens/ph_scale_screen.dart",
        [
            ("text: 'Macro',", "text: PhsStrings.macro,"),
            ("text: 'Micro',", "text: PhsStrings.micro,"),
            ("text: 'My Solution',", "text: PhsStrings.mySolution,"),
            ("'Water'", "PhsStrings.water"),
        ],
        phs,
    )
    patch_file(
        "lib/chemistry/ph_scale/view/widgets/common_controls.dart",
        [("'Neutral'", "PhsStrings.neutral")],
        phs,
    )
    patch_file(
        "lib/chemistry/ph_scale/model/water.dart",
        [("static const String name = 'Water';", "static const String name = PhsStrings.water;")],
        phs,
    )
    patch_file(
        "lib/chemistry/ph_scale/view/screens/macro_screen_view.dart",
        [("'Water'", "PhsStrings.water")],
        phs,
    )

    # ABS
    patch_file(
        "lib/chemistry/acid_base_solutions/screens/acid_base_solutions_home.dart",
        [
            ("'Intro'", "AbsStrings.intro"),
            ("'My Solution'", "AbsStrings.mySolution"),
        ],
        abs_,
    )
    patch_file(
        "lib/chemistry/acid_base_solutions/view/intro_solution_panel.dart",
        [("'Solution',", "AbsStrings.solution,")],
        abs_,
    )
    patch_file(
        "lib/chemistry/acid_base_solutions/view/my_solution_panel.dart",
        [
            ("'Solution',", "AbsStrings.solution,"),
            ("leftLabel: 'Acid',", "leftLabel: AbsStrings.acid,"),
            ("rightLabel: 'Base',", "rightLabel: AbsStrings.base,"),
        ],
        abs_,
    )

    # IAAM
    patch_file(
        "lib/chemistry/isotopes_and_atomic_mass/screens/isotopes_and_atomic_mass_home.dart",
        [("static const String subtitle = 'Isotopes · Atomic Mass';", "static const String subtitle = IaamStrings.subtitle;")],
        iaam,
    )
    patch_file(
        "lib/chemistry/isotopes_and_atomic_mass/widgets/atom_scale_widget.dart",
        [("'Mass Number'", "IaamStrings.massNumber")],
        iaam,
    )
    patch_file(
        "lib/chemistry/isotopes_and_atomic_mass/widgets/symbol_abundance_panels.dart",
        [("'Symbol'", "IaamStrings.symbol")],
        iaam,
    )

    # BAN
    patch_file(
        "lib/chemistry/build_a_nucleus/widgets/available_decays_panel.dart",
        [
            ("'Proton'", "BanStrings.proton"),
            ("'Neutron'", "BanStrings.neutron"),
            ("'Electron'", "BanStrings.electron"),
        ],
        ban,
    )
    patch_file(
        "lib/chemistry/build_a_nucleus/widgets/nuclide_status.dart",
        [("'Symbol'", "BanStrings.symbol")],
        ban,
    )
    patch_file(
        "lib/chemistry/build_a_nucleus/widgets/half_life_info_dialog.dart",
        [("static const String title = 'Half-Life Timescale';", "static const String title = BanStrings.halfLifeTimescale;")],
        ban,
    )

    # Beer's Law
    patch_file(
        "lib/beers_law_lab/screens/beers_law_lab_home.dart",
        [
            ('static const String title = "Beer\'s Law Lab";', "static const String title = BllStrings.title;"),
            ("static const String subtitle = 'Concentration · Beer\\'s Law';", "static const String subtitle = BllStrings.subtitle;"),
            ("label: 'Concentration',", "label: BllStrings.concentration,"),
        ],
        bll,
    )
    patch_file(
        "lib/beers_law_lab/view/beers_law_screen.dart",
        [('static const String title = "Beer\'s Law";', "static const String title = BllStrings.beersLaw;")],
        bll,
    )

    # Molecules and Light
    patch_file(
        "lib/molecules_and_light/view/molecules_and_light_screen.dart",
        [("static const String title = 'Molecules and Light';", "static const String title = MalStrings.title;")],
        mal,
    )

    # BAM reset
    patch_file(
        "lib/chemistry/build_a_molecule/screens/bam_screen_body.dart",
        [("'Reset All'", "'全部重置'")],
        None,
    )

    # Molecule polarity / shapes / RPAL / RS homes if still EN titles
    for rel, old, new, imp in [
        (
            "lib/chemistry/molecule_polarity/screens/molecule_polarity_home.dart",
            "static const String title = 'Molecule Polarity';",
            "static const String title = MpStrings.title;",
            "import 'package:kratos/chemistry/molecule_polarity/mp_strings.dart';",
        ),
        (
            "lib/molecule_shapes/screens/molecule_shapes_home.dart",
            "static const String title = 'Molecule Shapes';",
            "static const String title = MoleculeShapesStrings.title;",
            "import 'package:kratos/molecule_shapes/molecule_shapes_strings.dart';",
        ),
        (
            "lib/reactants_products_and_leftovers/screens/reactants_products_and_leftovers_home.dart",
            "static const String title = 'Reactants, Products and Leftovers';",
            "static const String title = RpalStrings.title;",
            "import 'package:kratos/reactants_products_and_leftovers/rpal_strings.dart';",
        ),
        (
            "lib/rutherford_scattering/screens/rutherford_scattering_home.dart",
            "static const String title = 'Rutherford Scattering';",
            "static const String title = RsStrings.title;",
            "import 'package:kratos/rutherford_scattering/rs_strings.dart';",
        ),
    ]:
        p = ROOT / rel
        if p.exists():
            t = p.read_text(encoding="utf-8")
            if old in t:
                t = ensure_import(t, imp)
                t = t.replace(old, new)
                p.write_text(t, encoding="utf-8")
                print(f"updated {rel}")
            else:
                print(f"skip title {rel}")

    print("DONE phase6 patch")


if __name__ == "__main__":
    main()
