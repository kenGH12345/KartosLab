#!/usr/bin/env python3
import json
from pathlib import Path

s = json.loads(Path("requirements/localization/_phase0_summary.json").read_text(encoding="utf-8"))
m = json.loads(Path("requirements/localization/_phase0_modules.json").read_text(encoding="utf-8"))
raw = json.loads(Path("requirements/localization/_phase0_raw.json").read_text(encoding="utf-8"))

print("=== SUMMARY ===")
print(json.dumps(s["by_classification"], ensure_ascii=False, indent=2))
print("home", json.dumps(s["home"], ensure_ascii=False, indent=2))
print("arb", s["has_arb"], "l10n", s["has_lib_l10n"], "flutter_loc", s["has_flutter_localizations_in_pubspec"])
print("strings files", len(s["existing_strings_files"]))
print("=== TOP EN PHRASES ===")
for p, c in s["top_english_phrases"][:60]:
    print(f"{c:4d} | {p}")
print("=== TOP MIXED ===")
for p, c in s["top_mixed_phrases"][:40]:
    print(f"{c:4d} | {p}")
print("=== MODULES ===")
mods = sorted(m, key=lambda x: -(x["english"] + x["mixed"]))
for x in mods:
    print(
        f"{x['module']:45s} tot={x['total']:4d} en={x['english']:4d} "
        f"zh={x['chinese']:4d} mix={x['mixed']:3d} a11y={x['a11y']:3d} files={x['files']:3d}"
    )

# Home title language audit from static titles across sims
findings = raw["findings"]
home_titles = [
    f
    for f in findings
    if f.get("key") in {"title", "subtitle"} or f["kind"] in {"static_title"}
]
print("=== STATIC TITLES SAMPLE ===")
for f in home_titles[:80]:
    print(f"{f['classification']:10s} | {f['file']}:{f['line']} | {f['english_or_text'][:80]}")

# Count unique files with english
en_files = sorted({f["file"] for f in findings if f["classification"] in {"english", "mixed"}})
print("UNIQUE_FILES_WITH_EN_OR_MIXED", len(en_files))

# Accessibility english
a11y_en = [f for f in findings if f["is_a11y"] and f["classification"] in {"english", "mixed"}]
print("A11Y_EN_OR_MIXED", len(a11y_en))
for f in a11y_en[:30]:
    print(f"  {f['file']}:{f['line']} | {f['english_or_text'][:70]}")
