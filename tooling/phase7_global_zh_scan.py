# -*- coding: utf-8 -*-
"""PHASE 7 — tightened global ZH residue scan (migrated product UI paths)."""
from __future__ import annotations

import json
import re
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"

MODULE_MAP = [
    ("screens/home", "home"),
    ("common/widgets", "shared-chrome"),
    ("common/controls", "shared-chrome"),
    ("forces/", "forces"),
    ("collision_lab/", "collision-lab"),
    ("vector_addition/", "vector-addition"),
    ("projectile_motion/", "projectile-motion"),
    ("pendulum_lab/", "pendulum-lab"),
    ("balancing_act/", "balancing-act"),
    ("friction/", "friction"),
    ("hookes_law/", "hookes-law"),
    ("masses_and_springs_basics/", "masses-and-springs-basics"),
    ("energy_skate_park/", "energy-skate-park"),
    ("gravity_force_lab/", "gravity-force-lab"),
    ("gravity_force_lab_basics/", "gravity-force-lab-basics"),
    ("astronomy/gravity_and_orbits/", "gravity-and-orbits"),
    ("astronomy/keplers_laws/", "keplers-laws"),
    ("astronomy/my_solar_system/", "my-solar-system"),
    ("density/", "density"),
    ("buoyancy/", "buoyancy"),
    ("under_pressure/", "under-pressure"),
    ("gases_intro/", "gases-intro"),
    ("gas_properties/", "gas-properties"),
    ("diffusion/", "diffusion"),
    ("membrane_transport/", "membrane-transport"),
    ("ohms_law/", "ohms-law"),
    ("resistance_in_a_wire/", "resistance-in-a-wire"),
    ("cck_ac_virtual_lab/", "cck-ac-virtual-lab"),
    ("capacitor_lab_basics/", "capacitor-lab-basics"),
    ("charges_and_fields/", "charges-and-fields"),
    ("faradays_law/", "faradays-law"),
    ("john_travoltage/", "john-travoltage"),
    ("balloons_and_static_electricity/", "balloons-and-static-electricity"),
    ("magnetism/magnet_and_compass/", "magnet-and-compass"),
    ("bending_light/", "bending-light"),
    ("color_vision/", "color-vision"),
    ("wave_on_a_string/", "wave-on-a-string"),
    ("waves_intro/", "waves-intro"),
    ("normal_modes/", "normal-modes"),
    ("fourier_making_waves/", "fourier-making-waves"),
    ("sound/", "sound"),
    ("radio_waves/", "radio-waves"),
    ("quantum_measurement/", "quantum-measurement"),
    ("physics/quantum_wave_interference/", "quantum-wave-interference"),
    ("quantum_coin_toss/", "quantum-coin-toss"),
    ("chemistry/molarity/", "molarity"),
    ("beers_law_lab/", "beers-law-lab"),
    ("chemistry/ph_scale/", "ph-scale"),
    ("chemistry/acid_base_solutions/", "acid-base-solutions"),
    ("chemistry/build_a_nucleus/", "build-a-nucleus"),
    ("rutherford_scattering/", "rutherford-scattering"),
    ("chemistry/build_an_atom/", "build-an-atom"),
    ("chemistry/isotopes_and_atomic_mass/", "isotopes-and-atomic-mass"),
    ("chemistry/build_a_molecule/", "build-a-molecule"),
    ("chemistry/molecule_polarity/", "molecule-polarity"),
    ("molecule_shapes/", "molecule-shapes"),
    ("molecules_and_light/", "molecules-and-light"),
    ("reactants_products_and_leftovers/", "reactants-products-and-leftovers"),
    ("balancing_chemical_equations/", "balancing-chemical-equations"),
    ("chemistry/states_of_matter/", "states-of-matter"),
]

SKIP_PATH_SUBSTR = (
    "/l10n/",
    "debug_",
    "/debug/",
    "_demo_main",
    "/qa_",
    "qa_launch",
    "_qa_main",
    "_perf_harness",
    "android_gate",
    "/generated/",
    "phet_font",
    "_painter.dart",  # geometry labels often not UI
)

ALLOWED = {
    "PhET", "KartosLab", "Kratos", "pH", "RGB", "VSEPR", "Planck", "Wien",
    "WebGL", "SG", "SGz", "SGx", "OK", "HA", "MOH", "PDF", "N", "S", "E", "W",
}
UNITS = {
    "kg", "g", "mg", "m", "cm", "mm", "nm", "μm", "km", "L", "mL", "Pa", "kPa",
    "N", "J", "W", "V", "A", "Hz", "kHz", "MHz", "K", "s", "ms", "atm", "mol",
    "M", "mM", "eV", "ohm", "cm3", "m3",
}

LATIN = re.compile(r"[A-Za-z][A-Za-z']*")
CJK = re.compile(r"[\u4e00-\u9fff]")
# UI-ish assignments
UI_CTX = re.compile(
    r"(Text\s*\(|TextSpan\s*\(|tooltip\s*:|semanticLabel\s*:|Semantics\s*\(|"
    r"label\s*:|title\s*:|subtitle\s*:|hintText\s*:|helperText\s*:|"
    r"message\s*:|content\s*:|child\s*:\s*const\s*Text|child\s*:\s*Text|"
    r"static\s+const\s+String\s+\w+\s*=)",
    re.I,
)
STR_LIT = re.compile(r"""(['"])([^'"\\]{1,120})\1""")

COMMON_UI_EN = re.compile(
    r"\b(Reset|All|Play|Pause|Step|Intro|Lab|Game|Check|Next|Continue|"
    r"Try|Again|Show|Answer|Mass|Force|Gravity|Density|Pressure|Volume|"
    r"Energy|Power|Current|Charge|Voltage|Resistance|Wavelength|Frequency|"
    r"Amplitude|Phase|Photon|Atom|Element|Molecule|Acid|Base|Solution|"
    r"Concentration|Water|Solid|Liquid|Gas|Heat|Cool|Reactants|Products|"
    r"Balanced|Normal|Slow|Fast|Custom|Options|Settings|Cancel|Close|"
    r"Delete|Save|Load|Start|Stop|Help|About|Back|Home|Level|Score|"
    r"Proton|Neutron|Electron|Symbol|Isotope|Bond|Graph|Screen|Probe|"
    r"Speed|Intensity|Configuration|Detector|Snapshots|Manual|Pulse|"
    r"Oscillate|Fixed|Loose|End|Rulers|Stopwatch|Mute|Unmute)\b",
    re.I,
)


def module_of(rel: str) -> str | None:
    rel = rel.replace("\\", "/")
    if rel.startswith("lib/"):
        rel = rel[4:]
    for prefix, mid in MODULE_MAP:
        if rel.startswith(prefix):
            return mid
    return None


def skip_file(rel: str) -> bool:
    r = rel.replace("\\", "/")
    return any(s in r for s in SKIP_PATH_SUBSTR)


EN_DUAL_CONST = re.compile(r"static\s+const\s+String\s+\w*En\s*=")
FONT_FAMILY = re.compile(
    r"Times New Roman|Arial|Roboto|YaHei|PingFang|Noto Sans|Helvetica|sans-serif",
    re.I,
)


def is_noise(s: str, line: str = "") -> bool:
    if not s or len(s) < 2:
        return True
    if s.startswith("package:") or s.startswith("assets/"):
        return True
    if "/" in s and " " not in s and not CJK.search(s):
        return True
    if re.fullmatch(r"[\d.\s+\-×*/=<>%°:，。、]+", s):
        return True
    if re.fullmatch(r"[A-Za-z0-9_\-]+", s) and "_" in s:
        return True  # identifiers
    if s in ALLOWED or s in UNITS:
        return True
    # font families (not user language)
    if FONT_FAMILY.search(s) or "fontFamily" in line:
        return True
    # Legacy archaeology duals: titleEn / introEn / … — not product UI
    if EN_DUAL_CONST.search(line) or re.search(r"\b\w+En\s*=", line):
        return True
    # Pure interpolations — language comes from substituted values / units
    if "$" in s or "{" in s:
        stripped = re.sub(r"\$\{[^}]+\}", "", s)
        stripped = re.sub(r"\$\w+", "", stripped)
        stripped = re.sub(r"\{[^}]+\}", "", stripped)
        # leftover unit / punctuation only → not natural-language English
        if not re.search(r"[A-Za-z]{4,}", stripped):
            return True
    # Nested-quote truncation artifacts from STR_LIT (ternary inside string)
    if s.rstrip().endswith(("== ", "? ", "?? ", ": ")) or s.count("{") != s.count("}"):
        return True
    return False


UNIT_TAIL = re.compile(
    r"(?:^|[\s=:])[\d.\-+]*\s*(?:kg|g|mg|m|cm|mm|nm|μm|km|L|mL|Pa|kPa|N|J|W|V|A|Hz|"
    r"kHz|MHz|K|s|ms|atm|mol|M|mM|eV|%|m/s|m/s²|kg/m³|mol/L)\b",
    re.I,
)


def classify(s: str) -> str:
    if re.search(r"[₂₃⁺⁻→⇌]|H₂O|CO₂|Na\+|mol/L|kg/m", s) and not COMMON_UI_EN.search(s):
        return "FORMULA"
    words = LATIN.findall(s)
    if not words:
        return "SCIENTIFIC_SYMBOL"
    # Numeric/unit readouts (e.g. "12 N", "3.5 mm", "80%") — not natural language
    if UNIT_TAIL.search(s) and not re.search(
        r"\b(Reset|Play|Pause|Intro|Energy|Graph|Solution|Concentration|Wavelength|"
        r"Volume|Mass|Force|Atom|Molecule|Average|Atomic|Protons|Neutrons|Electrons|"
        r"Chart|Build|Ball|Failed|Eccentricity|Equilibrium)\b",
        s,
        re.I,
    ):
        # only short tokens besides units
        non_unit = [w for w in words if w not in UNITS and w not in ALLOWED and len(w) > 3]
        if not non_unit:
            return "UNIT"
    bad = []
    for w in words:
        if w in ALLOWED:
            continue
        if w in UNITS or (len(w) <= 2 and w.isalpha()):
            continue
        if w.isupper() and 2 <= len(w) <= 4:
            continue  # HA, MOH, RGB already allowed etc.
        bad.append(w)
    if not bad:
        if any(w in UNITS for w in words):
            return "UNIT"
        return "APPROVED_EXCEPTION"
    if CJK.search(s) and not COMMON_UI_EN.search(s):
        # Chinese primary with leftover Latin tokens that aren't UI words
        remaining = [w for w in bad if len(w) > 3]
        if not remaining:
            return "APPROVED_EXCEPTION"
    if COMMON_UI_EN.search(s) or (" " in s and any(len(w) >= 4 for w in bad)):
        return "USER_VISIBLE_ENGLISH"
    if any(len(w) >= 5 and w[0].isupper() for w in bad):
        return "USER_VISIBLE_ENGLISH"
    return "SCIENTIFIC_SYMBOL"


def main() -> None:
    rows = []
    counts = Counter()
    by_module = defaultdict(Counter)
    files_scanned = 0

    for f in LIB.rglob("*.dart"):
        rel = f.relative_to(ROOT).as_posix()
        if skip_file(rel):
            continue
        mid = module_of(rel)
        if mid is None:
            continue  # only migrated product paths
        files_scanned += 1
        text = f.read_text(encoding="utf-8", errors="ignore")
        for i, line in enumerate(text.splitlines(), 1):
            sline = line.strip()
            if sline.startswith("//") or sline.startswith("///") or sline.startswith("import ") or sline.startswith("export "):
                continue
            if not UI_CTX.search(line):
                continue
            for m in STR_LIT.finditer(line):
                s = m.group(2)
                # Skip ValueKey / map keys / ColumnDef keys (not UI copy)
                before = line[: m.start()]
                if re.search(
                    r"(?:^|[,(\s])(?:key|Key|ValueKey|semanticsIdentifier)\s*[:(]\s*$",
                    before,
                ):
                    continue
                if is_noise(s, line):
                    continue
                if not LATIN.search(s):
                    continue
                # Chinese-primary labels with only short Latin/units
                if CJK.search(s):
                    words = LATIN.findall(s)
                    if not COMMON_UI_EN.search(s) or all(
                        w in UNITS or w in ALLOWED or len(w) <= 3 for w in words
                    ):
                        kind = (
                            "UNIT"
                            if any(w in UNITS for w in words)
                            else "APPROVED_EXCEPTION"
                        )
                        a11y = (
                            "semantic" in line.lower()
                            or "tooltip" in line.lower()
                            or "Semantics" in line
                        )
                        rows.append(
                            {
                                "file": rel,
                                "line": i,
                                "module": mid,
                                "string": s.replace("\n", "\\n")[:100],
                                "visible": False,
                                "a11y": a11y,
                                "classification": kind,
                                "status": "OK",
                            }
                        )
                        counts[kind] += 1
                        by_module[mid][kind] += 1
                        continue
                kind = classify(s)
                a11y = "semantic" in line.lower() or "tooltip" in line.lower() or "Semantics" in line
                visible = kind == "USER_VISIBLE_ENGLISH"
                rows.append(
                    {
                        "file": rel,
                        "line": i,
                        "module": mid,
                        "string": s.replace("\n", "\\n")[:100],
                        "visible": visible,
                        "a11y": a11y,
                        "classification": kind,
                        "status": "FAIL" if visible else "OK",
                    }
                )
                counts[kind] += 1
                by_module[mid][kind] += 1

    uv = [r for r in rows if r["classification"] == "USER_VISIBLE_ENGLISH"]
    out_json = ROOT / "tooling/phase7_scan_raw.json"
    out_json.write_text(
        json.dumps({"files": files_scanned, "counts": dict(counts), "uv": len(uv), "rows": rows}, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    md = []
    md.append("# GLOBAL_ZH_STRING_AUDIT\n\n")
    md.append("> PHASE 7 · Migrated product UI paths only (excludes `lib/l10n` EN tables, debug/demo, unmigrated sims).\n\n")
    md.append(f"- Files scanned: **{files_scanned}**\n")
    md.append(f"- USER_VISIBLE_ENGLISH hits: **{len(uv)}**\n\n")
    md.append("## Classification counts\n\n| Classification | Count |\n|---|---:|\n")
    for k, v in counts.most_common():
        md.append(f"| {k} | {v} |\n")
    md.append("\n## USER_VISIBLE_ENGLISH by module\n\n| Module | Count |\n|---|---:|\n")
    for mid, c in sorted(((m, by_module[m].get("USER_VISIBLE_ENGLISH", 0)) for m in by_module), key=lambda x: -x[1]):
        if c:
            md.append(f"| {mid} | {c} |\n")
    md.append("\n## Detail (first 300)\n\n")
    md.append("| File | Simulation/Area | String | User Visible | A11y | Classification | Localization Key | Status |\n")
    md.append("|---|---|---|---|---|---|---|---|\n")
    for r in uv[:300]:
        md.append(
            f"| `{r['file']}:{r['line']}` | {r['module']} | `{r['string']}` | Y | {'Y' if r['a11y'] else 'N'} | USER_VISIBLE_ENGLISH | — | FAIL |\n"
        )
    if len(uv) > 300:
        md.append(f"\n_… {len(uv) - 300} more in `tooling/phase7_scan_raw.json`_\n")
    md.append("\n## Gate note\n\n")
    md.append("Hits require triage: many may be false positives (asset keys, enum labels used only as IDs, ")
    md.append("English archaeology comments inside string bags). Triaged FAIL residual after Phase 2–6 bags ")
    md.append("is tracked in `GLOBAL_ZH_VERIFICATION_REPORT.md`.\n")
    (ROOT / "requirements/localization/GLOBAL_ZH_STRING_AUDIT.md").write_text("".join(md), encoding="utf-8")
    print(f"files={files_scanned} uv={len(uv)} counts={dict(counts)}")


if __name__ == "__main__":
    main()
