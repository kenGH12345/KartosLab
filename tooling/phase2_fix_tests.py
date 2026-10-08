#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# forces home lifecycle
p = ROOT / "test/forces/home_lifecycle_test.dart"
t = p.read_text(encoding="utf-8")
if "forces_strings" not in t:
    t = t.replace(
        "import 'package:kratos/forces/screens/forces_home.dart';",
        "import 'package:kratos/forces/config/forces_strings.dart';\n"
        "import 'package:kratos/forces/screens/forces_home.dart';",
    )
repls = [
    ("find.text('Forces and Motion: Basics')", "find.text(ForcesStrings.forcesHomeTitle)"),
    ("find.text('Net Force')", "find.text(ForcesStrings.screenNetForce)"),
    ("find.text('Motion')", "find.text(ForcesStrings.screenMotion)"),
    ("find.text('Friction')", "find.text(ForcesStrings.screenFriction)"),
    ("find.text('Acceleration')", "find.text(ForcesStrings.screenAcceleration)"),
    ("find.text('Go!')", "find.text(ForcesStrings.netForceGo)"),
    ("find.text('Applied Force')", "find.text('外力')"),
    ("find.text('Forces')", "find.text('力')"),
]
for a, b in repls:
    t = t.replace(a, b)
p.write_text(t, encoding="utf-8")
print("home_lifecycle")

p = ROOT / "test/forces/screens_smoke_test.dart"
t = p.read_text(encoding="utf-8")
if "forces_strings" not in t:
    t = t.replace(
        "import 'package:kratos/forces/screens/forces_home.dart';",
        "import 'package:kratos/forces/config/forces_strings.dart';\n"
        "import 'package:kratos/forces/screens/forces_home.dart';",
    )
for a, b in [
    ("find.text('Net Force')", "find.text(ForcesStrings.screenNetForce)"),
    ("find.text('Motion')", "find.text(ForcesStrings.screenMotion)"),
    ("find.text('Friction')", "find.text(ForcesStrings.screenFriction)"),
    ("find.text('Acceleration')", "find.text(ForcesStrings.screenAcceleration)"),
    ("find.text('Go!')", "find.text(ForcesStrings.netForceGo)"),
    ("find.text('Return')", "find.text(ForcesStrings.netForceReturn)"),
    ("find.text('Sum of Forces')", "find.text('合力')"),
    ("find.text('Applied Force')", "find.text('外力')"),
    ("find.text('Force')", "find.text(ForcesStrings.motionForce)"),
]:
    t = t.replace(a, b)
p.write_text(t, encoding="utf-8")
print("screens_smoke")

p = ROOT / "test/gravity_force_lab/accessibility_test.dart"
t = p.read_text(encoding="utf-8")
if "gfl_strings" not in t:
    t = t.replace(
        "import 'package:kratos/gravity_force_lab/a11y/gfl_a11y_strings.dart';",
        "import 'package:kratos/gravity_force_lab/a11y/gfl_a11y_strings.dart';\n"
        "import 'package:kratos/gravity_force_lab/gfl_strings.dart';",
    )
for a, b in [
    ("find.text('Scientific Notation')", "find.text(GflStrings.scientificNotation)"),
    ("find.text('Hidden')", "find.text(GflStrings.hidden)"),
    ("find.text('Decimal Notation')", "find.text(GflStrings.decimalNotation)"),
    ("find.text('Constant Size')", "find.text(GflStrings.constantSize)"),
    ("find.text('Close')", "find.text('关闭')"),
]:
    t = t.replace(a, b)
p.write_text(t, encoding="utf-8")
print("gfl a11y")

print("done")
