# -*- coding: utf-8 -*-
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
files = [
    ROOT / "test/chemistry/acid_base_solutions/home/abs_home_lifecycle_test.dart",
    ROOT / "test/chemistry/acid_base_solutions/my_solution_screen_test.dart",
]
imp = "import 'package:kratos/chemistry/acid_base_solutions/abs_strings.dart';"
reps = [
    ("find.text('Intro')", "find.text(AbsStrings.intro)"),
    ("find.text('My Solution')", "find.text(AbsStrings.mySolution)"),
    ("find.text('Base')", "find.text(AbsStrings.base)"),
    ("find.text('weak')", "find.text(AbsStrings.weak)"),
    ("find.text('strong')", "find.text(AbsStrings.strong)"),
    ("find.text('Initial Concentration (mol/L):')", "find.text(AbsStrings.initialConcentration)"),
    ("find.text('Water (H\u2082O)')", "find.text(AbsStrings.waterH2O)"),
    ("find.text('Strong Acid (HA)')", "find.text(AbsStrings.strongAcidHA)"),
    ("find.text('Weak Acid (HA)')", "find.text(AbsStrings.weakAcidHA)"),
    ("find.text('Strong Base (MOH)')", "find.text(AbsStrings.strongBaseMOH)"),
    ("find.text('Weak Base (B)')", "find.text(AbsStrings.weakBaseB)"),
    ("contains('Intro')", "contains(AbsStrings.intro)"),
    ("contains('My Solution')", "contains(AbsStrings.mySolution)"),
]

for p in files:
    if not p.exists():
        print("MISSING", p)
        continue
    t = p.read_text(encoding="utf-8")
    orig = t
    for a, b in reps:
        t = t.replace(a, b)
    if imp not in t:
        lines = t.splitlines(keepends=True)
        idx = 0
        for i, line in enumerate(lines):
            if line.startswith("import "):
                idx = i + 1
        lines.insert(idx, imp + "\n")
        t = "".join(lines)
    if t != orig:
        p.write_text(t, encoding="utf-8")
        print("updated", p.relative_to(ROOT))
    else:
        print("unchanged", p.relative_to(ROOT))
print("DONE")
