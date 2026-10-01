# DATA_MIGRATION — Isotopes and Atomic Mass Phase 1

## Source

| Item | Path / ref |
|---|---|
| Locked shred | `f1a7da74ae61ec0397dbeb0672fdb5ecfafa43a1` (see `SHRED_SOURCE.md`) |
| AtomData | `requirements/req-isotopes-and-atomic-mass/reference/AtomData.ts` |
| AtomNameUtils | `requirements/req-isotopes-and-atomic-mass/reference/AtomNameUtils.ts` |

## Converter

```
tool/isotopes_and_atomic_mass/convert_atom_data.py
```

Run:

```bash
python tool/isotopes_and_atomic_mass/convert_atom_data.py
```

## Output (single authoritative dataset)

```
lib/chemistry/isotopes_and_atomic_mass/model/data/atom_data_tables.dart
```

Contains:

- `kTraceAbundance`
- `kSymbolTable` / `kEnglishNameTable` (Z=0..18)
- `kStableNeutronsByZ`
- `kNumNeutronsInMostCommonIsotope`
- `kStandardAtomicMassByZ`
- `kIsotopeInfoTable` (`RawIsotopeInfo` rows for all ISOTOPE_INFO_TABLE entries)

**No** second JSON / manual table. Make and Mix both read repositories built on this file.

## Access layer (hand-written, pure Dart)

| File | Role |
|---|---|
| `element_data.dart` / `isotope_data.dart` / `isotope_id.dart` | Immutable records |
| `atom_info_utils.dart` | PhET AtomInfoUtils subset |
| `element_repository.dart` / `isotope_repository.dart` | Unified lookup |
| `phet_number_utils.dart` | `toFixedNumber` / `roundSymmetric` |
| `data.dart` | Barrel export |

## Verification

```bash
# Windows cmd (ProgramFiles(x86) may need setting in some shells)
flutter test test/isotopes_and_atomic_mass/data/
dart analyze lib/chemistry/isotopes_and_atomic_mass
```

Anchors checked against source literals:

| Anchor | Expected (from AtomData.ts) |
|---|---|
| H-1 mass / abundance | `1.00782503207` / `0.999885` |
| H-2 | `2.0141017778` / `0.000115` |
| H-3 | trace abundance |
| C-12 / C-13 / C-14 | table values; C-14 unstable + trace |
| Default H neutrons | `0` → H-1 |
| Standard mass H/C/O/Cl/Ar | `1.00794` / `12.0107` / `15.9994` / `35.453` / `39.948` |

## Scope notes

- ISOTOPE_INFO_TABLE in shred only covers **Z ≤ 18** — matches Mix max Z.
- Screen limits (Make Z≤10, Mix Z≤18) are **not** encoded in the data layer; they belong in screen models (Phase 2+).
- Half-life / decay tables intentionally omitted (IAAM does not use them).
