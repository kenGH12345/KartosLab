# -*- coding: utf-8 -*-
"""Retarget Phase 5 widget tests from English find.text to Chinese bag constants."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# file -> list of (old, new) and optional import
PATCHES: dict[str, tuple[str | None, list[tuple[str, str]]]] = {
    "test/wave_on_a_string/controls/controls_interaction_test.dart": (
        "import 'package:kratos/wave_on_a_string/woas_strings.dart';",
        [
            ("find.text('Damping')", "find.text(WoasStrings.damping)"),
            ("find.text('Frequency')", "find.text(WoasStrings.frequency)"),
            ("find.text('Oscillate')", "find.text(WoasStrings.oscillate)"),
            ("find.text('Amplitude')", "find.text(WoasStrings.amplitude)"),
            ("find.text('Pulse Width')", "find.text(WoasStrings.pulseWidth)"),
            ("find.text('Pulse')", "find.text(WoasStrings.pulse)"),
            ("find.text('Manual')", "find.text(WoasStrings.manual)"),
            ("find.text('Loose End')", "find.text(WoasStrings.looseEnd)"),
            ("find.text('No End')", "find.text(WoasStrings.noEnd)"),
            ("find.text('Fixed End')", "find.text(WoasStrings.fixedEnd)"),
        ],
    ),
    "test/wave_on_a_string/visual/phase5_structural_visual_test.dart": (
        "import 'package:kratos/wave_on_a_string/woas_strings.dart';",
        [
            ("find.text('Amplitude')", "find.text(WoasStrings.amplitude)"),
            ("find.text('Frequency')", "find.text(WoasStrings.frequency)"),
        ],
    ),
    "test/bending_light/view/scenery_controls_test.dart": (
        "import 'package:kratos/bending_light/bl_strings.dart';",
        [
            ("find.text('Water')", "find.text(BlStrings.water)"),
            ("find.text('Glass')", "find.text(BlStrings.glass)"),
            ("find.text('Air')", "find.text(BlStrings.air)"),
            ("find.text('Intensity')", "find.text(BlStrings.intensity)"),
        ],
    ),
    "test/bending_light/view/scenery_nodes_test.dart": (
        "import 'package:kratos/bending_light/bl_strings.dart';",
        [
            ("find.text('Ray')", "find.text(BlStrings.ray)"),
            ("find.text('Wave')", "find.text(BlStrings.wave)"),
        ],
    ),
    "test/home/bending_light_integration_test.dart": (
        "import 'package:kratos/bending_light/bl_strings.dart';",
        [
            ("find.text('Bending Light — Intro')", "find.text(BlStrings.titleIntro)"),
            ("find.text('Intro')", "find.text(BlStrings.intro)"),
        ],
    ),
    "test/color_vision/behavioral/acceptance_matrix_test.dart": (
        "import 'package:kratos/color_vision/color_vision_strings.dart';",
        [
            ("find.text('RGB Bulbs')", "find.text(ColorVisionStrings.rgbBulbs)"),
            ("find.text('Single Bulb')", "find.text(ColorVisionStrings.singleBulb)"),
        ],
    ),
    "test/quantum_measurement/phase10_platform_test.dart": (
        "import 'package:kratos/quantum_measurement/qm_strings.dart';",
        [
            ("find.text('Photons')", "find.text(QmStrings.photons)"),
            ("find.text('Coins')", "find.text(QmStrings.coins)"),
            ("find.text('Spin')", "find.text(QmStrings.spin)"),
            ("find.text('Bloch Sphere')", "find.text(QmStrings.blochSphere)"),
        ],
    ),
    "test/quantum_measurement/phase8_behavior_test.dart": (
        "import 'package:kratos/quantum_measurement/qm_strings.dart';",
        [
            ("find.text('Flip')", "find.text(QmStrings.flip)"),
            ("find.text('Block ↓')", "find.text(QmStrings.blockDown)"),
            ("find.text('Block ↑')", "find.text(QmStrings.blockUp)"),
            ("find.text('Reveal')", "find.text(QmStrings.reveal)"),
            ("find.text('Observe')", "find.text(QmStrings.observe)"),
            ("find.text('Hide')", "find.text(QmStrings.hide)"),
            ("find.text('Reprepare')", "find.text(QmStrings.reprepare)"),
        ],
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
        if imp:
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
