#!/usr/bin/env python3
"""PHASE 0 — Global Localization Audit for KartosLab.

Scans lib/ for user-visible string candidates. Does NOT modify simulation code.
"""
from __future__ import annotations

import json
import os
import re
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
OUT_DIR = ROOT / "requirements" / "localization"

# Patterns that commonly introduce user-visible text
UI_PATTERNS = [
    (r"""Text\s*\(\s*(?:const\s+)?(['"])(?P<s>(?:\\.|(?!\1).)*)\1""", "Text"),
    (r"""TextSpan\s*\([^)]*text:\s*(['"])(?P<s>(?:\\.|(?!\1).)*)\1""", "TextSpan"),
    (r"""tooltip:\s*(['"])(?P<s>(?:\\.|(?!\1).)*)\1""", "tooltip"),
    (r"""semanticLabel:\s*(['"])(?P<s>(?:\\.|(?!\1).)*)\1""", "semanticLabel"),
    (r"""semanticsLabel:\s*(['"])(?P<s>(?:\\.|(?!\1).)*)\1""", "semanticsLabel"),
    (r"""accessibilityLabel:\s*(['"])(?P<s>(?:\\.|(?!\1).)*)\1""", "accessibilityLabel"),
    (r"""hintText:\s*(['"])(?P<s>(?:\\.|(?!\1).)*)\1""", "hintText"),
    (r"""hint:\s*(['"])(?P<s>(?:\\.|(?!\1).)*)\1""", "hint"),
    (r"""labelText:\s*(['"])(?P<s>(?:\\.|(?!\1).)*)\1""", "labelText"),
    (r"""helperText:\s*(['"])(?P<s>(?:\\.|(?!\1).)*)\1""", "helperText"),
    (r"""errorText:\s*(['"])(?P<s>(?:\\.|(?!\1).)*)\1""", "errorText"),
    (r"""placeholder:\s*(['"])(?P<s>(?:\\.|(?!\1).)*)\1""", "placeholder"),
    (r"""title:\s*(?:const\s+)?(?:Text\s*\(\s*)?(['"])(?P<s>(?:\\.|(?!\1).)*)\1""", "title"),
    (r"""subtitle:\s*(?:const\s+)?(?:Text\s*\(\s*)?(['"])(?P<s>(?:\\.|(?!\1).)*)\1""", "subtitle"),
    (r"""label:\s*(['"])(?P<s>(?:\\.|(?!\1).)*)\1""", "label"),
    (r"""message:\s*(['"])(?P<s>(?:\\.|(?!\1).)*)\1""", "message"),
    (r"""content:\s*(?:const\s+)?(?:Text\s*\(\s*)?(['"])(?P<s>(?:\\.|(?!\1).)*)\1""", "content"),
    (r"""SnackBar\s*\([^)]*content:\s*(?:const\s+)?Text\s*\(\s*(['"])(?P<s>(?:\\.|(?!\1).)*)\1""", "SnackBar"),
    (r"""AlertDialog\s*\([^)]*title:\s*(?:const\s+)?Text\s*\(\s*(['"])(?P<s>(?:\\.|(?!\1).)*)\1""", "AlertDialog"),
    (r"""name:\s*(['"])(?P<s>(?:\\.|(?!\1).)*)\1""", "name"),
    (r"""englishName:\s*(['"])(?P<s>(?:\\.|(?!\1).)*)\1""", "englishName"),
    (r"""displayName:\s*(['"])(?P<s>(?:\\.|(?!\1).)*)\1""", "displayName"),
]

# Catch remaining quoted string literals that contain CJK (Chinese hardcodes
# not covered by named UI kwargs).
CJK_STRING_LIT = re.compile(r"""(['"])(?P<s>[^'"]*[\u4e00-\u9fff][^'"]*)\1""")

# Strings class static const / static final string assignments
STRINGS_ASSIGN = re.compile(
    r"""static\s+const\s+String\s+(?P<key>\w+)\s*=\s*(['"])(?P<s>(?:\\.|(?!\2).)*)\2"""
)
STRINGS_ASSIGN2 = re.compile(
    r"""static\s+final\s+String\s+(?P<key>\w+)\s*=\s*(['"])(?P<s>(?:\\.|(?!\2).)*)\2"""
)

# Home / module titles
STATIC_TITLE = re.compile(
    r"""static\s+const\s+String\s+(?P<key>title|subtitle|homeTitle|screenTitle|tab\w*|name)\s*=\s*(['"])(?P<s>(?:\\.|(?!\2).)*)\2"""
)

CJK_RE = re.compile(r"[\u4e00-\u9fff]")
LATIN_WORD_RE = re.compile(r"[A-Za-z]{2,}")
UNIT_ONLY_RE = re.compile(
    r"""^(?:
        kg|g|mg|μg|ug|m|cm|mm|nm|μm|um|km|
        m³|m\^3|m3|L|mL|ml|
        Pa|kPa|atm|bar|
        N|kN|
        J|kJ|eV|
        W|kW|
        V|mV|kV|
        A|mA|μA|uA|
        Ω|ohm|Ohms?|
        Hz|kHz|MHz|GHz|
        °C|°F|K|
        s|ms|μs|us|
        rad|deg|°|
        %[sm]?|
        ρ|λ|ω|α|β|γ|θ|φ|μ|σ|Δ|π|
        F\s*=\s*ma|E\s*=\s*mc\^?2|
        \d+(?:\.\d+)?\s*(?:kg|m|m³|Pa|N|V|A|Hz|°C|s)?
    )$""",
    re.VERBOSE | re.IGNORECASE,
)

# Pure identifiers / debug / non-UI
TECHNICAL_HINTS = re.compile(
    r"""(?ix)^(
        debug|assert|print|log|TODO|FIXME|http|https|package:|
        assets?/|\.png|\.svg|\.jpg|\.json|\.yaml|
        [a-z]+_[a-z0-9_]+|          # snake_case id
        [A-Z][a-zA-Z0-9]+Model|     # Model class-ish
        [A-Z][a-zA-Z0-9]+Screen|
        [A-Z][a-zA-Z0-9]+Controller|
        [a-z]+-[a-z0-9-]+           # kebab id
    )"""
)

ALLOWED_ENGLISH_BRAND = {
    "PhET",
    "KartosLab",
    "Kratos",
    "Flutter",
    "Android",
}

COMMON_PHYSICS_EN = {
    "Gravity",
    "Mass",
    "Weight",
    "Density",
    "Pressure",
    "Volume",
    "Force",
    "Buoyancy",
    "Displacement",
    "Wavelength",
    "Frequency",
    "Amplitude",
    "Particle",
    "Molecule",
    "Atom",
    "Voltage",
    "Current",
    "Resistance",
    "Energy",
    "Reset All",
    "Reset",
    "Play",
    "Pause",
    "Speed",
    "Normal",
    "Slow",
    "Fast",
    "Values",
    "Vectors",
    "Components",
    "Angle",
    "Angles",
    "Grid",
    "Lab",
    "Intro",
    "Explore",
    "Compare",
    "Mystery",
    "Shapes",
    "Applications",
    "Systems",
    "Options",
    "None",
    "Lots",
    "min",
    "max",
    "Go!",
    "Return",
}


def unescape(s: str) -> str:
    # Only unescape common Dart string escapes; do NOT unicode_escape
    # (that corrupts UTF-8 CJK already present in source).
    return (
        s.replace(r"\n", "\n")
        .replace(r"\t", "\t")
        .replace(r"\'", "'")
        .replace(r'\"', '"')
        .replace(r"\\", "\\")
    )


def classify(text: str) -> str:
    t = text.strip()
    if not t:
        return "empty"
    if UNIT_ONLY_RE.match(t) or t in {"E", "F", "g", "m", "V", "I", "R", "ρ", "λ"}:
        return "scientific_symbol"
    if t in ALLOWED_ENGLISH_BRAND:
        return "brand"
    has_cjk = bool(CJK_RE.search(t))
    has_latin = bool(LATIN_WORD_RE.search(t))
    if has_cjk and has_latin:
        # Chinese + units like "质量 kg" still mixed-language for natural English words
        latin_words = LATIN_WORD_RE.findall(t)
        # Filter unit-like tokens
        natural = [
            w
            for w in latin_words
            if not UNIT_ONLY_RE.match(w)
            and w.lower() not in {
                "kg", "m", "pa", "n", "v", "a", "hz", "s", "cm", "mm", "ml", "l",
                "go", "ok", "phet", "id", "url", "api", "rgb", "hsv", "svg", "png",
            }
        ]
        if natural:
            return "mixed"
        return "chinese"  # Chinese + units/symbols only
    if has_cjk:
        return "chinese"
    if has_latin:
        # Single letter or formula-like
        if len(t) <= 2 and not t.isalpha():
            return "scientific_symbol"
        if TECHNICAL_HINTS.match(t):
            return "technical"
        return "english"
    return "other"


def is_likely_user_visible(text: str, kind: str, filepath: str) -> bool:
    t = text.strip()
    if not t:
        return False
    # Skip asset paths / package URIs
    if t.startswith("assets/") or t.startswith("package:") or "/" in t and "." in t.split("/")[-1]:
        if any(t.endswith(ext) for ext in (".png", ".svg", ".jpg", ".jpeg", ".json", ".yaml", ".webp", ".gif")):
            return False
    if t.startswith("http://") or t.startswith("https://"):
        return False
    # Debug / test only paths
    name = filepath.replace("\\", "/").lower()
    if "/debug_" in name or name.endswith("_debug.dart"):
        # still count but mark later
        pass
    # Pure numeric
    if re.fullmatch(r"[\d.\s+\-*/^=()]+", t):
        return False
    # Very short punctuation
    if len(t) == 1 and t in "{}[]().,;:!?":
        return False
    return True


def module_of(rel: str) -> str:
    parts = rel.replace("\\", "/").split("/")
    if len(parts) < 2:
        return "root"
    # lib/<module>/...
    if parts[0] == "lib":
        if parts[1] in {"chemistry", "astronomy", "physics", "magnetism", "common", "screens"}:
            if len(parts) > 2 and parts[1] in {"chemistry", "astronomy", "physics", "magnetism"}:
                return f"{parts[1]}/{parts[2]}"
            return parts[1]
        return parts[1]
    return parts[0]


def scan_file(path: Path) -> list[dict]:
    rel = str(path.relative_to(ROOT)).replace("\\", "/")
    try:
        content = path.read_text(encoding="utf-8")
    except Exception:
        return []
    lines = content.splitlines()
    findings: list[dict] = []
    seen_spans: set[tuple[int, str]] = set()

    def add(line_no: int, kind: str, text: str, key: str | None = None):
        text = unescape(text)
        if not is_likely_user_visible(text, kind, rel):
            return
        span = (line_no, text)
        if span in seen_spans:
            return
        seen_spans.add(span)
        cat = classify(text)
        findings.append(
            {
                "file": rel,
                "line": line_no,
                "kind": kind,
                "key": key,
                "english_or_text": text,
                "classification": cat,
                "module": module_of(rel),
                "is_strings_file": "strings" in path.name.lower(),
                "is_a11y": "a11y" in kind.lower()
                or "semantic" in kind.lower()
                or "accessibility" in kind.lower()
                or "/a11y/" in rel.lower()
                or "a11y" in path.name.lower(),
            }
        )

    # Line-based UI patterns
    for i, line in enumerate(lines, 1):
        # Skip import / comments-only for some noise
        stripped = line.strip()
        if stripped.startswith("import ") or stripped.startswith("//"):
            # still allow // for nothing
            if stripped.startswith("import "):
                continue
        for pat, kind in UI_PATTERNS:
            for m in re.finditer(pat, line):
                add(i, kind, m.group("s"))

        for rx, kind in ((STRINGS_ASSIGN, "strings_const"), (STRINGS_ASSIGN2, "strings_final"), (STATIC_TITLE, "static_title")):
            for m in rx.finditer(line):
                add(i, kind, m.group("s"), key=m.groupdict().get("key"))

        # CJK string literals anywhere (hardcoded Chinese UI)
        if CJK_RE.search(line) and not stripped.startswith("import "):
            for m in CJK_STRING_LIT.finditer(line):
                add(i, "cjk_literal", m.group("s"))

    return findings


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    dart_files = sorted(LIB.rglob("*.dart"))
    # Exclude generated if any
    dart_files = [p for p in dart_files if ".dart_tool" not in str(p) and "/generated/" not in str(p).replace("\\", "/")]

    all_findings: list[dict] = []
    for p in dart_files:
        all_findings.extend(scan_file(p))

    # Extra: scan home_screen titles more carefully via _SimEntry and _Discipline
    home = LIB / "screens" / "home_screen.dart"
    home_findings = [f for f in all_findings if f["file"].endswith("screens/home_screen.dart")]

    # Aggregate
    by_class = Counter(f["classification"] for f in all_findings)
    by_module = Counter(f["module"] for f in all_findings)
    by_kind = Counter(f["kind"] for f in all_findings)

    english = [f for f in all_findings if f["classification"] == "english"]
    chinese = [f for f in all_findings if f["classification"] == "chinese"]
    mixed = [f for f in all_findings if f["classification"] == "mixed"]
    a11y = [f for f in all_findings if f["is_a11y"]]
    strings_files = [f for f in all_findings if f["is_strings_file"]]

    # Per-file impact: count english+mixed
    impact = Counter()
    for f in all_findings:
        if f["classification"] in {"english", "mixed"}:
            impact[f["file"]] += 1

    top20 = impact.most_common(20)

    # Module english counts for batching
    module_en = Counter()
    for f in all_findings:
        if f["classification"] in {"english", "mixed"}:
            module_en[f["module"]] += 1

    # Unique English phrases (top)
    en_phrases = Counter(f["english_or_text"] for f in english)
    mixed_phrases = Counter(f["english_or_text"] for f in mixed)

    # Existing strings infrastructure
    strings_dart = sorted(LIB.rglob("*strings*.dart"))
    strings_dart_rel = [str(p.relative_to(ROOT)).replace("\\", "/") for p in strings_dart]

    # Home sim entries: extract title/subtitle literals and const refs roughly
    home_text = home.read_text(encoding="utf-8") if home.exists() else ""
    home_title_lits = re.findall(r"""title:\s*['"]([^'"]+)['"]""", home_text)
    home_subtitle_lits = re.findall(r"""subtitle:\s*['"]([^'"]+)['"]""", home_text)
    home_group_names = re.findall(r"""name:\s*['"]([^'"]+)['"]""", home_text)
    home_english_names = re.findall(r"""englishName:\s*['"]([^'"]+)['"]""", home_text)

    summary = {
        "files_scanned": len(dart_files),
        "total_string_hits": len(all_findings),
        "by_classification": dict(by_class),
        "by_kind": dict(by_kind),
        "english_count": len(english),
        "chinese_count": len(chinese),
        "mixed_count": len(mixed),
        "a11y_count": len(a11y),
        "strings_file_hits": len(strings_files),
        "existing_strings_files": strings_dart_rel,
        "top20_impact_files": top20,
        "module_english_mixed": module_en.most_common(),
        "home": {
            "title_literals": home_title_lits,
            "subtitle_literals": home_subtitle_lits,
            "group_names": home_group_names,
            "english_names": home_english_names,
            "home_hits": len(home_findings),
            "home_english": sum(1 for f in home_findings if f["classification"] == "english"),
            "home_chinese": sum(1 for f in home_findings if f["classification"] == "chinese"),
            "home_mixed": sum(1 for f in home_findings if f["classification"] == "mixed"),
        },
        "top_english_phrases": en_phrases.most_common(80),
        "top_mixed_phrases": mixed_phrases.most_common(40),
        "has_arb": False,
        "has_lib_l10n": (ROOT / "lib" / "l10n").exists(),
        "has_flutter_localizations_in_pubspec": False,
    }

    pubspec = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")
    summary["has_flutter_localizations_in_pubspec"] = "flutter_localizations" in pubspec or "gen_l10n" in pubspec

    # Write JSON dump for further processing
    (OUT_DIR / "_phase0_raw.json").write_text(
        json.dumps({"summary": summary, "findings": all_findings}, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    (OUT_DIR / "_phase0_summary.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8"
    )

    # Per-module breakdown CSV-like
    module_stats = []
    modules = sorted(set(f["module"] for f in all_findings))
    for m in modules:
        mf = [f for f in all_findings if f["module"] == m]
        module_stats.append(
            {
                "module": m,
                "total": len(mf),
                "english": sum(1 for f in mf if f["classification"] == "english"),
                "chinese": sum(1 for f in mf if f["classification"] == "chinese"),
                "mixed": sum(1 for f in mf if f["classification"] == "mixed"),
                "a11y": sum(1 for f in mf if f["is_a11y"]),
                "scientific": sum(1 for f in mf if f["classification"] == "scientific_symbol"),
                "files": len(set(f["file"] for f in mf)),
            }
        )
    (OUT_DIR / "_phase0_modules.json").write_text(
        json.dumps(module_stats, ensure_ascii=False, indent=2), encoding="utf-8"
    )

    print("FILES_SCANNED", len(dart_files))
    print("TOTAL_HITS", len(all_findings))
    print("ENGLISH", len(english))
    print("CHINESE", len(chinese))
    print("MIXED", len(mixed))
    print("A11Y", len(a11y))
    print("STRINGS_FILES", len(strings_dart_rel))
    print("TOP20:")
    for f, c in top20:
        print(f"  {c:4d}  {f}")
    print("MODULES_EN:")
    for m, c in module_en.most_common(30):
        print(f"  {c:4d}  {m}")


if __name__ == "__main__":
    main()
