#!/usr/bin/env python3
"""
Convert PhET shred AtomData.ts (+ AtomNameUtils symbol/english tables)
into a single authoritative Dart constants file for Isotopes and Atomic Mass.

Source lock: see requirements/req-isotopes-and-atomic-mass/SHRED_SOURCE.md
"""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ATOM_DATA = ROOT / "requirements/req-isotopes-and-atomic-mass/reference/AtomData.ts"
ATOM_NAMES = ROOT / "requirements/req-isotopes-and-atomic-mass/reference/AtomNameUtils.ts"
OUT = ROOT / "lib/chemistry/isotopes_and_atomic_mass/model/data/atom_data_tables.dart"

# IAAM only needs Z=1..18 for isotope mass/abundance; keep full stable/standard
# tables through the isotope-info range for consistency with shred.
MAX_ISOTOPE_Z = 18


def extract_array_block(text: str, name: str) -> str:
    m = re.search(rf"export const {name}\s*=\s*\[", text)
    if not m:
        raise SystemExit(f"Could not find {name}")
    i = m.end() - 1
    depth = 0
    start = i
    while i < len(text):
        c = text[i]
        if c == "[":
            depth += 1
        elif c == "]":
            depth -= 1
            if depth == 0:
                return text[start : i + 1]
        i += 1
    raise SystemExit(f"Unclosed array for {name}")


def parse_int_lists(array_src: str) -> list[list[int]]:
    """Parse nested int arrays like [[], [0,1], [1,2], ...]."""
    # Strip comments
    cleaned = re.sub(r"//.*?$", "", array_src, flags=re.M)
    rows: list[list[int]] = []
    for m in re.finditer(r"\[([^\]]*?)\]", cleaned):
        inner = m.group(1).strip()
        if not inner:
            rows.append([])
        else:
            nums = [int(x.strip()) for x in inner.split(",") if x.strip()]
            rows.append(nums)
    # First match is the outer wrapper's first inner... actually the regex
    # matches ALL brackets including nested incorrectly.
    # Better approach: find top-level list items.
    return parse_nested_int_array(cleaned)


def parse_nested_int_array(array_src: str) -> list[list[int]]:
    cleaned = re.sub(r"//.*?$", "", array_src, flags=re.M)
    # Remove outer [ ]
    body = cleaned.strip()
    assert body[0] == "[" and body[-1] == "]"
    body = body[1:-1]
    rows: list[list[int]] = []
    i = 0
    n = len(body)
    while i < n:
        while i < n and body[i] in " \t\r\n,":
            i += 1
        if i >= n:
            break
        if body[i] == "[":
            j = i + 1
            depth = 1
            while j < n and depth:
                if body[j] == "[":
                    depth += 1
                elif body[j] == "]":
                    depth -= 1
                j += 1
            inner = body[i + 1 : j - 1].strip()
            if inner:
                rows.append([int(x.strip()) for x in inner.split(",") if x.strip()])
            else:
                rows.append([])
            i = j
        else:
            # flat number in a flat array (numNeutrons / standardMass)
            m = re.match(r"-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?", body[i:])
            if not m:
                raise SystemExit(f"Unexpected token at {i}: {body[i:i+40]!r}")
            # This function is for nested lists only
            raise SystemExit("Expected nested list")
    return rows


def parse_number_list(array_src: str) -> list[float]:
    cleaned = re.sub(r"//.*?$", "", array_src, flags=re.M)
    body = cleaned.strip()
    assert body[0] == "[" and body[-1] == "]"
    body = body[1:-1]
    vals: list[float] = []
    for part in body.split(","):
        part = part.strip()
        if not part:
            continue
        vals.append(float(part))
    return vals


def parse_string_list(array_src: str) -> list[str]:
    cleaned = re.sub(r"//.*?$", "", array_src, flags=re.M)
    return re.findall(r"'([^']*)'", cleaned)


def parse_isotope_info(text: str) -> dict[int, dict[int, tuple[float, float | None]]]:
    m = re.search(r"export const ISOTOPE_INFO_TABLE[\s\S]*?=\s*new Map\(\s*\[", text)
    if not m:
        raise SystemExit("ISOTOPE_INFO_TABLE not found")
    # From start of Map content to matching close of outer array before `] );`
    start = m.end()
    # Find the closing `] );` of the Map constructor - use the known end pattern
    end_m = re.search(r"\]\s*\)\s*;\s*\n\s*// Table which maps atomic numbers to standard", text[start:])
    if not end_m:
        raise SystemExit("Could not find end of ISOTOPE_INFO_TABLE")
    block = text[start : start + end_m.start()]

    result: dict[int, dict[int, tuple[float, float]]] = {}
    # Split by atomic number entries: [ Z, new Map( [
    for zm in re.finditer(
        r"\[\s*(\d+)\s*,\s*new Map\(\s*\[([\s\S]*?)\]\s*\)\s*\]",
        block,
    ):
        z = int(zm.group(1))
        inner = zm.group(2)
        isotopes: dict[int, tuple[float, float]] = {}
        for im in re.finditer(
            r"\[\s*(\d+)\s*,\s*\{[\s\S]*?atomicMass:\s*([0-9.eE+-]+)[\s\S]*?"
            r"abundance:\s*(TRACE_ABUNDANCE|[0-9.eE+-]+)",
            inner,
        ):
            a = int(im.group(1))
            mass = float(im.group(2))
            abund_raw = im.group(3)
            abund: float | None = None if abund_raw == "TRACE_ABUNDANCE" else float(abund_raw)
            isotopes[a] = (mass, abund)
        if not isotopes:
            raise SystemExit(f"No isotopes parsed for Z={z}")
        result[z] = isotopes
    return result


def dart_double(v: float | None, is_trace: bool = False) -> str:
    if is_trace or v is None:
        return "kTraceAbundance"
    # Preserve reasonable precision
    s = repr(float(v))
    if s.endswith(".0"):
        return s  # keep .0 for ints-as-float like 1.0
    return s


def main() -> None:
    atom = ATOM_DATA.read_text(encoding="utf-8")
    names = ATOM_NAMES.read_text(encoding="utf-8")

    stable = parse_nested_int_array(extract_array_block(atom, "stableElementTable"))
    most_common = [int(x) for x in parse_number_list(extract_array_block(atom, "numNeutronsInMostStableIsotope"))]
    standard = parse_number_list(extract_array_block(atom, "standardMassTable"))
    isotopes = parse_isotope_info(atom)

    symbols = parse_string_list(extract_array_block(names, "symbolTable"))
    english = parse_string_list(extract_array_block(names, "englishNameTable"))

    # Cap isotope map verification
    assert max(isotopes.keys()) == MAX_ISOTOPE_Z
    assert 1 in isotopes and 1 in isotopes[1]

    lines: list[str] = []
    lines.append("// GENERATED FILE — do not edit by hand.")
    lines.append("// Source: shred AtomData.ts / AtomNameUtils.ts (locked commit — see SHRED_SOURCE.md)")
    lines.append("// Converter: tool/isotopes_and_atomic_mass/convert_atom_data.py")
    lines.append("//")
    lines.append("// ignore_for_file: prefer_single_quotes")
    lines.append("")
    lines.append("/// Sentinel abundance used by PhET when NIST lists an isotope as \"trace\".")
    lines.append("const double kTraceAbundance = 0.000000000001;")
    lines.append("")
    lines.append("/// Highest Z present in [kIsotopeInfoTable] (PhET: first 18 elements only).")
    lines.append(f"const int kIsotopeInfoMaxAtomicNumber = {MAX_ISOTOPE_Z};")
    lines.append("")

    # Symbols / names through Z=18 (plus 0)
    lines.append("/// Chemical symbols indexed by atomic number (shred symbolTable).")
    lines.append("const List<String> kSymbolTable = [")
    for z in range(0, MAX_ISOTOPE_Z + 1):
        lines.append(f"  '{symbols[z]}', // {z}")
    lines.append("];")
    lines.append("")

    lines.append("/// English element names (lowercase) indexed by Z (shred englishNameTable).")
    lines.append("const List<String> kEnglishNameTable = [")
    for z in range(0, MAX_ISOTOPE_Z + 1):
        lines.append(f"  '{english[z]}', // {z}")
    lines.append("];")
    lines.append("")

    # Stable neutrons through Z=18
    lines.append("/// Stable neutron counts per Z (shred stableElementTable), Z=0..18.")
    lines.append("const List<List<int>> kStableNeutronsByZ = [")
    for z in range(0, MAX_ISOTOPE_Z + 1):
        nums = ", ".join(str(n) for n in stable[z])
        lines.append(f"  [{nums}], // {z}")
    lines.append("];")
    lines.append("")

    lines.append("/// Neutrons in most common (most stable) isotope per Z (shred).")
    lines.append("const List<int> kNumNeutronsInMostCommonIsotope = [")
    for z in range(0, MAX_ISOTOPE_Z + 1):
        lines.append(f"  {most_common[z]}, // {z}")
    lines.append("];")
    lines.append("")

    lines.append("/// Standard atomic mass / weight per Z (shred standardMassTable), amu.")
    lines.append("const List<double> kStandardAtomicMassByZ = [")
    for z in range(0, MAX_ISOTOPE_Z + 1):
        lines.append(f"  {standard[z]}, // {z}")
    lines.append("];")
    lines.append("")

    # Isotope info as nested maps encoded as records list for clarity
    lines.append("/// One isotope entry from shred ISOTOPE_INFO_TABLE.")
    lines.append("class RawIsotopeInfo {")
    lines.append("  const RawIsotopeInfo({")
    lines.append("    required this.atomicNumber,")
    lines.append("    required this.massNumber,")
    lines.append("    required this.atomicMass,")
    lines.append("    required this.abundance,")
    lines.append("  });")
    lines.append("")
    lines.append("  final int atomicNumber;")
    lines.append("  final int massNumber;")
    lines.append("  final double atomicMass;")
    lines.append("  /// Natural abundance as a proportion (not percent). May be [kTraceAbundance].")
    lines.append("  final double abundance;")
    lines.append("}")
    lines.append("")

    lines.append("/// Flat list of all ISOTOPE_INFO_TABLE entries (Z=1..18).")
    lines.append("const List<RawIsotopeInfo> kIsotopeInfoTable = [")
    for z in sorted(isotopes.keys()):
        for a in sorted(isotopes[z].keys()):
            mass, abund = isotopes[z][a]
            if abund is None:
                abund_s = "kTraceAbundance"
            else:
                abund_s = repr(float(abund))
            lines.append(
                "  RawIsotopeInfo("
                f"atomicNumber: {z}, massNumber: {a}, "
                f"atomicMass: {repr(float(mass))}, abundance: {abund_s}),"
            )
    lines.append("];")
    lines.append("")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {OUT}")
    print(f"  isotopes: {len([1 for z in isotopes for _ in isotopes[z]])}")
    print(f"  elements: 0..{MAX_ISOTOPE_Z}")


if __name__ == "__main__":
    main()
