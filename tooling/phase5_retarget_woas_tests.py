# -*- coding: utf-8 -*-
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
IMP = "import 'package:kratos/wave_on_a_string/woas_strings.dart';"
REPS = [
    ("find.text('Manual')", "find.text(WoasStrings.manual)"),
    ("find.text('Fixed End')", "find.text(WoasStrings.fixedEnd)"),
    ("find.text('Loose End')", "find.text(WoasStrings.looseEnd)"),
    ("find.text('No End')", "find.text(WoasStrings.noEnd)"),
    ("find.text('Oscillate')", "find.text(WoasStrings.oscillate)"),
    ("find.text('Pulse')", "find.text(WoasStrings.pulse)"),
    ("find.text('Pulse Width')", "find.text(WoasStrings.pulseWidth)"),
    ("find.text('Amplitude')", "find.text(WoasStrings.amplitude)"),
    ("find.text('Frequency')", "find.text(WoasStrings.frequency)"),
]

for f in (ROOT / "test/wave_on_a_string").rglob("*.dart"):
    t = f.read_text(encoding="utf-8")
    orig = t
    for a, b in REPS:
        t = t.replace(a, b)
    if t != orig:
        if IMP not in t:
            lines = t.splitlines(keepends=True)
            idx = 0
            for i, line in enumerate(lines):
                if line.startswith("import "):
                    idx = i + 1
            lines.insert(idx, IMP + "\n")
            t = "".join(lines)
        f.write_text(t, encoding="utf-8")
        print("updated", f.relative_to(ROOT))
print("DONE")
