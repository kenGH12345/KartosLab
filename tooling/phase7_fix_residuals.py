# -*- coding: utf-8 -*-
"""PHASE 7 residual UV English fixes (migrated sims only)."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def ensure_import(text: str, imp: str) -> str:
    if imp in text:
        return text
    lines = text.splitlines(keepends=True)
    idx = 0
    for i, line in enumerate(lines):
        if line.startswith("import "):
            idx = i + 1
    lines.insert(idx, imp + "\n")
    return "".join(lines)


def patch(rel: str, reps: list[tuple[str, str]], imp: str | None = None) -> None:
    p = ROOT / rel
    if not p.exists():
        print("MISSING", rel)
        return
    t = p.read_text(encoding="utf-8")
    orig = t
    if imp:
        t = ensure_import(t, imp)
    for a, b in reps:
        if a not in t:
            print("MISS", rel, repr(a[:60]))
            continue
        t = t.replace(a, b)
    if t != orig:
        p.write_text(t, encoding="utf-8")
        print("updated", rel)
    else:
        print("unchanged", rel)


def main() -> None:
    # Hooke's Law tabs + visibility
    patch(
        "lib/hookes_law/screens/hookes_law_home.dart",
        [
            ("label: 'Intro',", "label: '介绍',"),
            ("label: 'Systems',", "label: '系统',"),
            ("label: 'Energy',", "label: '能量',"),
        ],
    )
    for rel in [
        "lib/hookes_law/view/energy/energy_visibility_panel.dart",
        "lib/hookes_law/view/intro/intro_visibility_panel.dart",
        "lib/hookes_law/view/systems/systems_visibility_panel.dart",
    ]:
        patch(
            rel,
            [
                ("'Energy'", "'能量'"),
                ("'Displacement'", "'位移'"),
                ("'Values'", "'数值'"),
                ("'Equilibrium Position'", "'平衡位置'"),
                ("'Applied Force'", "'外力'"),
                ("'Spring Force'", "'弹力'"),
            ],
        )

    # Membrane transport
    patch(
        "lib/membrane_transport/screens/membrane_transport_home.dart",
        [
            ("'Simple · Facilitated · Active · Playground'", "'简单扩散 · 协助扩散 · 主动运输 · 练习场'"),
            ("label: 'Simple Diffusion',", "label: '简单扩散',"),
            ("label: 'Facilitated Diffusion',", "label: '协助扩散',"),
            ("label: 'Active Transport',", "label: '主动运输',"),
            ("label: 'Playground',", "label: '练习场',"),
        ],
    )

    # Molecules and light
    patch(
        "lib/molecules_and_light/view/molecules_and_light_screen.dart",
        [
            ("const Text('Light Sources', style: TextStyle(fontWeight: FontWeight.bold))",
             "const Text('光源', style: TextStyle(fontWeight: FontWeight.bold))"),
            ("const Text('Higher Energy →', style: TextStyle(fontSize: 11))",
             "const Text('更高能量 →', style: TextStyle(fontSize: 11))"),
            ("child: const Text('Close'),", "child: const Text('关闭'),"),
        ],
    )

    # Waves intro
    patch(
        "lib/waves_intro/model/scene_kind.dart",
        [
            ("graphVerticalAxisLabel: 'Water Level',", "graphVerticalAxisLabel: '水位',"),
            ("graphVerticalAxisLabel: 'Pressure',", "graphVerticalAxisLabel: '压强',"),
        ],
    )
    patch(
        "lib/waves_intro/widgets/waves_intro_toolbox.dart",
        [
            ("label: 'Timer',", "label: '计时器',"),
            ("label: 'Meter',", "label: '测量计',"),
        ],
    )

    # MASB
    patch(
        "lib/masses_and_springs_basics/widgets/spring_system_controls.dart",
        [
            ("title: 'Spring Strength',", "title: '弹簧强度',"),
            ("title: 'Spring Strength 1',", "title: '弹簧强度 1',"),
            ("title: 'Spring Strength 2',", "title: '弹簧强度 2',"),
            ("message: 'Stop oscillation',", "message: '停止振荡',"),
            ("Text('Small',", "Text('小',"),
            ("Text('Large',", "Text('大',"),
        ],
    )
    for rel in [
        "lib/masses_and_springs_basics/screens/bounce_screen.dart",
        "lib/masses_and_springs_basics/screens/lab_screen.dart",
        "lib/masses_and_springs_basics/screens/stretch_screen.dart",
    ]:
        patch(rel, [("tooltip: 'Reset',", "tooltip: '重置',")])

    # Pendulum close
    patch(
        "lib/pendulum_lab/widgets/control_panels.dart",
        [("'Close'", "'关闭'")],
    )

    # Quantum coin toss subtitle
    patch(
        "lib/quantum_coin_toss/screens/quantum_coin_toss_home.dart",
        [
            ("Classical · Quantum Coin", "经典 · 量子硬币"),
            ("Classical · Quantum Coin", "经典 · 量子硬币"),
        ],
    )

    # Under pressure planet names if still EN
    patch(
        "lib/under_pressure/view/under_pressure_screen.dart",
        [
            ("'Jupiter'", "'木星'"),
            ("'Earth'", "'地球'"),
            ("'Moon'", "'月球'"),
            ("'water'", "'水'"),
        ],
    )

    # QWI snapshot remaining
    patch(
        "lib/physics/quantum_wave_interference/view/layout/single_particles_layout_composer.dart",
        [
            ("title: Text('Snapshot ${scene.snapshots.snapshots[i].snapshotNumber}')",
             "title: Text(QwiStrings.snapshotN(scene.snapshots.snapshots[i].snapshotNumber))"),
        ],
        "import 'package:kratos/physics/quantum_wave_interference/qwi_strings.dart';",
    )

    print("DONE residual fix")


if __name__ == "__main__":
    main()
