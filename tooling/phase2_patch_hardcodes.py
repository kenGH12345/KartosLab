#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def patch_bounce():
    p = ROOT / "lib/masses_and_springs_basics/widgets/bounce_right_panel.dart"
    t = p.read_text(encoding="utf-8")
    if "masb_strings" not in t:
        t = t.replace(
            "import '../model/masb_model.dart';",
            "import '../model/masb_model.dart';\nimport '../masb_strings.dart';",
        )
    repls = [
        ("const Text('Gravity'", "Text(MasbStrings.gravity"),
        ("child: Text('Earth')", "child: Text(MasbStrings.earth)"),
        ("child: Text('Moon')", "child: Text(MasbStrings.moon)"),
        ("child: Text('Jupiter')", "child: Text(MasbStrings.jupiter)"),
        ("child: Text('Planet X')", "child: Text(MasbStrings.planetX)"),
        ("child: Text('Custom')", "child: Text(MasbStrings.custom)"),
        ("Text('None', style:", "Text(MasbStrings.none, style:"),
        ("Text('Lots', style:", "Text(MasbStrings.lots, style:"),
        (
            "title: const Text('Unstretched Length', style: TextStyle(fontSize: 12))",
            "title: Text(MasbStrings.unstretchedLength, style: const TextStyle(fontSize: 12))",
        ),
        (
            "title: const Text('Resting Position', style: TextStyle(fontSize: 12))",
            "title: Text(MasbStrings.restingPosition, style: const TextStyle(fontSize: 12))",
        ),
        (
            "title: const Text('Movable Line', style: TextStyle(fontSize: 12))",
            "title: Text(MasbStrings.movableLine, style: const TextStyle(fontSize: 12))",
        ),
        (
            "title: const Text('Period Trace', style: TextStyle(fontSize: 12))",
            "title: Text(MasbStrings.periodTrace, style: const TextStyle(fontSize: 12))",
        ),
        (
            "title: const Text('Velocity', style: TextStyle(fontSize: 12))",
            "title: Text(MasbStrings.velocity, style: const TextStyle(fontSize: 12))",
        ),
        (
            "title: const Text('Acceleration', style: TextStyle(fontSize: 12))",
            "title: Text(MasbStrings.acceleration, style: const TextStyle(fontSize: 12))",
        ),
    ]
    for a, b in repls:
        t = t.replace(a, b)
    p.write_text(t, encoding="utf-8")
    print("patched", p)


def patch_spring_constant():
    p = ROOT / "lib/masses_and_springs_basics/widgets/spring_constant_control.dart"
    t = p.read_text(encoding="utf-8")
    if "masb_strings" not in t:
        # add import after first import
        lines = t.splitlines()
        for i, line in enumerate(lines):
            if line.startswith("import "):
                continue
            lines.insert(i, "import '../masb_strings.dart';")
            break
        t = "\n".join(lines) + ("\n" if t.endswith("\n") else "")
    t = t.replace("Text('Small'", "Text(MasbStrings.small")
    t = t.replace("Text('Large'", "Text(MasbStrings.large")
    p.write_text(t, encoding="utf-8")
    print("patched", p)


def patch_hookes():
    files = {
        "lib/hookes_law/view/energy/energy_system_view.dart": [
            ("title: 'Spring Constant:'", "title: '${HookesLawStrings.springConstant}:'"),
            ("title: 'Displacement:'", "title: '${HookesLawStrings.displacement}:'"),
        ],
        "lib/hookes_law/view/systems/systems_system_view.dart": [
            ("title: 'Top Spring:'", "title: '${HookesLawStrings.topSpring}:'"),
            ("title: 'Bottom Spring:'", "title: '${HookesLawStrings.bottomSpring}:'"),
            ("title: 'Left Spring:'", "title: '${HookesLawStrings.leftSpring}:'"),
            ("title: 'Right Spring:'", "title: '${HookesLawStrings.rightSpring}:'"),
        ],
        "lib/hookes_law/view/systems/systems_controls.dart": [
            ("title: 'Applied Force:'", "title: '${HookesLawStrings.appliedForce}:'"),
        ],
        "lib/hookes_law/view/intro/intro_system_view.dart": [
            ("title: 'Spring Constant $n:'", "title: '${HookesLawStrings.springConstant} $n:'"),
            ("title: 'Applied Force $n:'", "title: '${HookesLawStrings.appliedForce} $n:'"),
        ],
    }
    for rel, repls in files.items():
        p = ROOT / rel
        t = p.read_text(encoding="utf-8")
        if "hookes_law_strings" not in t:
            t = "import 'package:kratos/hookes_law/hookes_law_strings.dart';\n" + t
        for a, b in repls:
            t = t.replace(a, b)
        p.write_text(t, encoding="utf-8")
        print("patched", p)


def patch_misc():
    # collision reset tooltip
    p = ROOT / "lib/collision_lab/widgets/time_control.dart"
    t = p.read_text(encoding="utf-8")
    t = t.replace("tooltip: 'Reset All'", "tooltip: CollisionLabStrings.resetAll if False else '全部重置'")
    # simpler:
    t = p.read_text(encoding="utf-8")
    t = t.replace("tooltip: 'Reset All'", "tooltip: '全部重置'")
    if "collision_lab_strings" not in t and "CollisionLabStrings" in t:
        pass
    p.write_text(t, encoding="utf-8")
    print("patched", p)

    p = ROOT / "lib/forces/screens/motion_screen_v2.dart"
    t = p.read_text(encoding="utf-8")
    t = t.replace("child: const Text('Reset')", "child: const Text(ForcesStrings.netForceReset)")
    if "forces_strings" not in t:
        t = "import 'package:kratos/forces/config/forces_strings.dart';\n" + t
    p.write_text(t, encoding="utf-8")
    print("patched", p)

    p = ROOT / "lib/projectile_motion/widgets/pm_panels.dart"
    t = p.read_text(encoding="utf-8")
    t = t.replace(
        "Text('Mass: ${_trim(model.projectileMass)} kg'",
        "Text('${PmStrings.mass}: ${_trim(model.projectileMass)} kg'",
    )
    p.write_text(t, encoding="utf-8")
    print("patched", p)


if __name__ == "__main__":
    patch_bounce()
    patch_spring_constant()
    patch_hookes()
    patch_misc()
