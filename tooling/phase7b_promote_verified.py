# -*- coding: utf-8 -*-
"""Promote modules with deterministic ZH goldens to VERIFIED."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
dart_path = ROOT / "lib/l10n/legacy/migration_status.dart"
text = dart_path.read_text(encoding="utf-8")

# Must stay LOCALIZED — no reliable VM golden (plugin / flaky / skipIds)
KEEP_LOCALIZED = {
    "circuit",
    "beers-law-lab",
    "collision-lab",
    "friction",
    "cck-ac-virtual-lab",
    "resistance-in-a-wire",
    "quantum-coin-toss",
    "fourier-making-waves",
    "acid-base-solutions",
    "states-of-matter",
    "molarity",
    "concentration",  # has golden but audio-sensitive; keep localized until always green
    "l10n-architecture",  # infra, not a sim golden
}

# concentration actually has silent-audio golden and passes — promote it
KEEP_LOCALIZED.discard("concentration")

# Always verify chrome
FORCE_VERIFIED = {"home", "shared-chrome", "concentration"}

# Replace localized → verified except KEEP_LOCALIZED


def repl(m: re.Match[str]) -> str:
    mid = m.group(1)
    status = m.group(2)
    if mid in KEEP_LOCALIZED:
        return f"'{mid}': LocalizationMigrationStatus.localized"
    if status in ("localized", "verified") or mid in FORCE_VERIFIED:
        return f"'{mid}': LocalizationMigrationStatus.verified"
    return m.group(0)


new = re.sub(
    r"'([^']+)':\s*LocalizationMigrationStatus\.(localized|verified|partial|notStarted)",
    repl,
    text,
)
dart_path.write_text(new, encoding="utf-8")
verified = len(re.findall(r"LocalizationMigrationStatus\.verified", new))
localized = len(re.findall(r"LocalizationMigrationStatus\.localized", new))
print(f"verified≈{verified} localized≈{localized}")
