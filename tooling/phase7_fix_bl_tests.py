# -*- coding: utf-8 -*-
"""Update bending_light tests to expect Chinese BlStrings / chrome."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BL = ROOT / "test/bending_light"

REPLACEMENTS = [
    ("'Bending Light — Intro'", "BlStrings.titleIntro"),
    ("'Bending Light — Prisms'", "BlStrings.titlePrisms"),
    ("find.textContaining('More Tools')", "find.textContaining(BlStrings.moreTools)"),
    ("find.text('Normal')", "find.text(BlStrings.normalSpeed)"),
    ("find.text('Wave')", "find.text(BlStrings.wave)"),
    ("find.bySemanticsLabel('Protractor')", "find.bySemanticsLabel(BlStrings.protractor)"),
    ("find.bySemanticsLabel('Velocity')", "find.bySemanticsLabel(BlStrings.velocity)"),
    ("find.byTooltip('Reset All')", "find.byTooltip(BlStrings.resetAll)"),
    ("'Air'", "BlStrings.air"),
    ("'Water'", "BlStrings.water"),
    ("'Glass'", "BlStrings.glass"),
    ("const ['Air', 'Water', 'Glass']", "const [BlStrings.air, BlStrings.water, BlStrings.glass]"),
    # after BlStrings.air substitution the list may already be fixed; handle leftover:
    ("['Air', 'Water', 'Glass']", "[BlStrings.air, BlStrings.water, BlStrings.glass]"),
]

IMPORT = "import 'package:kratos/bending_light/bl_strings.dart';\n"


def ensure_import(text: str) -> str:
    if "bl_strings.dart" in text:
        return text
    lines = text.splitlines(keepends=True)
    idx = 0
    for i, ln in enumerate(lines):
        if ln.startswith("import "):
            idx = i + 1
    lines.insert(idx, IMPORT)
    return "".join(lines)


def main() -> None:
    for path in BL.rglob("*.dart"):
        text = path.read_text(encoding="utf-8")
        orig = text
        for old, new in REPLACEMENTS:
            text = text.replace(old, new)
        if text != orig:
            text = ensure_import(text)
            path.write_text(text, encoding="utf-8")
            print("updated", path.relative_to(ROOT))


if __name__ == "__main__":
    main()
