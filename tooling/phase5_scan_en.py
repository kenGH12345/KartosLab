# -*- coding: utf-8 -*-
"""Scan Phase 5 libs for likely user-visible English string literals."""
from __future__ import annotations

import re
from pathlib import Path

ROOTS = [
    "lib/bending_light",
    "lib/wave_on_a_string",
    "lib/waves_intro",
    "lib/normal_modes",
    "lib/fourier_making_waves",
    "lib/sound",
    "lib/radio_waves",
    "lib/color_vision",
    "lib/quantum_measurement",
    "lib/physics/quantum_wave_interference",
    "lib/quantum_coin_toss",
]

# Explicit UI phrases / single words commonly left in EN
NEEDLES = [
    "Reset All",
    "Index of Refraction",
    "What is n",
    "More Tools",
    "Air",
    "Water",
    "Glass",
    "Diamond",
    "Mystery A",
    "Mystery B",
    "Custom",
    "Normal",
    "Angles",
    "Wavelength",
    "Frequency",
    "Amplitude",
    "Phase",
    "Period",
    "Intensity",
    "Probability",
    "Measurement",
    "Photons",
    "Electrons",
    "Neutrons",
    "Helium Atoms",
    "Classical",
    "Quantum",
    "Behavior",
    "Unpolarized",
    "Vertical (V)",
    "Horizontal (H)",
    "Slow",
    "Fast",
    "Play",
    "Pause",
    "Step",
    "Screen Brightness",
    "Both Slits Open",
    "Top Covered",
    "Bottom Covered",
    "Detector on Top",
    "Detector on Bottom",
    "Detectors Both",
    "No Barrier",
    "Configuration",
    "Slit Separation",
    "Electric Field",
    "Real Part",
    "Wave Display",
    "Measuring Tape",
    "Stopwatch",
    "Time Plot",
    "Position Plot",
    "Detector Probe",
    "Snapshots",
    "Close",
    "Speed",
    "Probe",
    "Graph",
    "Screen",
    "Snap",
    "View",
    "Coin Bias",
    "Number of",
    "Bloch",
    "Polarization",
    "Magnetic Field",
    "Continuous",
    "Pulse",
    "Mute",
    "Unmute",
    "Level",
    "Viewpoint",
]

pat = re.compile("|".join(re.escape(n) for n in NEEDLES))

hits = []
for root in ROOTS:
    p = Path(root)
    if not p.exists():
        continue
    for f in p.rglob("*.dart"):
        if f.name.endswith("_strings.dart"):
            continue
        if "debug_" in f.name:
            continue
        text = f.read_text(encoding="utf-8", errors="ignore")
        for i, line in enumerate(text.splitlines(), 1):
            s = line.strip()
            if s.startswith("//") or s.startswith("import ") or s.startswith("export "):
                continue
            if "fontFamily" in line:
                continue
            m = pat.search(line)
            if m:
                # skip pure symbol / formula lines without quotes around needle
                if ("'" + m.group(0) + "'") not in line and ('"' + m.group(0) + '"') not in line:
                    # allow Text('...') style already covered; also map literals
                    if f": '{m.group(0)}'" not in line and f': "{m.group(0)}"' not in line:
                        if f"'{m.group(0)}'" not in line and f'"{m.group(0)}"' not in line:
                            continue
                hits.append(f"{f.as_posix()}:{i}:{m.group(0)} :: {line.strip()[:120]}")

out = Path("tooling/phase5_en_hits.txt")
out.write_text("\n".join(hits), encoding="utf-8")
print(f"wrote {out} count={len(hits)}")
for h in hits[:80]:
    print(h)
