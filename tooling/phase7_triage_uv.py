# -*- coding: utf-8 -*-
"""Triage USER_VISIBLE_ENGLISH hits into FP buckets vs residual."""
from __future__ import annotations

import json
import re
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
d = json.loads((ROOT / "tooling/phase7_scan_raw.json").read_text(encoding="utf-8"))
uv = [r for r in d["rows"] if r["classification"] == "USER_VISIBLE_ENGLISH"]

bucket = Counter()
residual = []

EN_CONST = re.compile(r"static\s+const\s+String\s+\w*En\s*=")
FONT = re.compile(r"Times New Roman|Arial|Roboto|Helvetica|sans-serif", re.I)
INTERP_ONLY = re.compile(r"^(\$\{?[A-Za-z0-9_.]+\}?\s*)+$")
UNITS_LIKE = re.compile(r"^[\d.\s\$\{\}a-zA-Z_./°µμ³¹⁺⁻±×]+(kg|g|m|cm|mm|nm|Hz|Pa|kPa|N|J|W|V|A|mol|atm|s|ms|m/s|m/s²|kg/m³)?$")

for r in uv:
    path = ROOT / r["file"]
    line = path.read_text(encoding="utf-8", errors="ignore").splitlines()[r["line"] - 1]
    s = r["string"]
    if EN_CONST.search(line) or re.search(r"\w+En\s*=", line):
        bucket["legacy_En_dual"] += 1
        continue
    if FONT.search(s) or "fontFamily" in line:
        bucket["font_family"] += 1
        continue
    if "$" in s and not re.search(r"[A-Za-z]{4,}", re.sub(r"\$\{?[\w.]+\}?", "", s)):
        bucket["interpolation"] += 1
        continue
    if INTERP_ONLY.match(s.strip()):
        bucket["interpolation"] += 1
        continue
    if re.fullmatch(r"[A-Za-z]{1,3}", s):
        bucket["short_symbol"] += 1
        continue
    if UNITS_LIKE.match(s) and not re.search(
        r"\b(Reset|Play|Pause|Intro|Mass|Force|Energy|Atom|Molecule)\b", s, re.I
    ):
        bucket["unit_or_symbol"] += 1
        continue
    if re.search(r"Key\(|ValueKey|SemanticsIdentifier|debugLabel", line):
        bucket["internal_key"] += 1
        continue
    bucket["residual_candidate"] += 1
    residual.append(f"{r['module']}|{r['file']}:{r['line']}|{s}|{line.strip()[:120]}")

out = ROOT / "tooling/phase7_uv_triage.txt"
out.write_text(
    "BUCKETS\n"
    + "\n".join(f"{k}: {v}" for k, v in bucket.most_common())
    + "\n\nRESIDUAL\n"
    + "\n".join(residual),
    encoding="utf-8",
)
print(dict(bucket))
print("residual", len(residual))
print("wrote", out)
