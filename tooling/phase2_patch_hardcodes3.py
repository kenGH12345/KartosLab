#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def patch(rel, pairs):
    p = ROOT / rel
    t = p.read_text(encoding="utf-8")
    for a, b in pairs:
        c = t.count(a)
        t = t.replace(a, b)
        print(f"{rel}: {c}x {a[:50]!r}")
    p.write_text(t, encoding="utf-8")


# spring constant label
p = ROOT / "lib/masses_and_springs_basics/widgets/spring_constant_control.dart"
t = p.read_text(encoding="utf-8")
t = t.replace("                  'Spring Constant',", "                  '劲度系数',")
t = t.replace("'Spring Constant'", "'劲度系数'")
p.write_text(t, encoding="utf-8")
print("spring ok")

patch(
    "lib/forces/screens/net_force_screen.dart",
    [
        ("model.isRunning ? 'Pause' : 'Go!'", "model.isRunning ? ForcesStrings.netForcePause : ForcesStrings.netForceGo"),
        ("'Return'", "ForcesStrings.netForceReturn"),
    ],
)

# ensure import
p = ROOT / "lib/forces/screens/net_force_screen.dart"
t = p.read_text(encoding="utf-8")
if "forces_strings" not in t:
    t = "import 'package:kratos/forces/config/forces_strings.dart';\n" + t
    p.write_text(t, encoding="utf-8")

for rel in [
    "lib/masses_and_springs_basics/screens/lab_screen.dart",
    "lib/masses_and_springs_basics/screens/stretch_screen.dart",
    "lib/masses_and_springs_basics/screens/bounce_screen.dart",
]:
    patch(
        rel,
        [
            ("tooltip: m.playing ? 'Pause' : 'Play'", "tooltip: m.playing ? '暂停' : '播放'"),
        ],
    )

patch(
    "lib/vector_addition/widgets/va_control_icons.dart",
    [("message: 'Reset All'", "message: '全部重置'")],
)

# motion sum of forces leftovers
p = ROOT / "lib/forces/screens/motion_screen_v2.dart"
t = p.read_text(encoding="utf-8")
t = t.replace("Sum of Forces", "合力")
p.write_text(t, encoding="utf-8")
print("motion leftovers")

print("done")
