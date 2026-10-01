# SHRED Source Lock — Isotopes and Atomic Mass

## Source repository

https://github.com/phetsims/shred

## Lock decision

| Field | Value |
|---|---|
| **Locked commit** | `f1a7da74ae61ec0397dbeb0672fdb5ecfafa43a1` |
| **Commit date** | 2026-03-31 |
| **Message** | Adding .npmrc and package-lock.json |
| **Branch at lock** | `main` (as of that commit) |

## Why not `dependencies.json` SHA?

Local / published `isotopes-and-atomic-mass/dependencies.json` (sim version `1.2.0-dev.2`, stamped **2026-04-09**) lists:

```json
"shred": { "sha": "9f09238135fedee939cac520506b67d738f968f3", "branch": "main" }
```

That SHA is **identical for every dependency** in the file and **does not exist** on GitHub for `phetsims/shred` (404). It is treated as a **placeholder / broken chipper stamp**, not a resolvable git object.

### Resolution rule applied

```
valid resolvable shred commit nearest to sim dependency stamp
>
broken identical SHA in dependencies.json
>
floating latest main
```

Sim dependency update commit on isotopes-and-atomic-mass:

- `129d433ad370f6628a79d3b45bd07cd85063557b` — 2026-04-09 — `updated dependencies.json for 1.2.0-dev.2`

Latest **real** shred commit strictly before that stamp:

- `f1a7da74ae61ec0397dbeb0672fdb5ecfafa43a1` — 2026-03-31

No shred commits between 2026-03-31 and 2026-04-09 (API `until=2026-04-10`).

## Local reference path

```
requirements/req-isotopes-and-atomic-mass/reference/AtomData.ts
requirements/req-isotopes-and-atomic-mass/reference/AtomNameUtils.ts
```

Copied from the KartosLab BAN reference snapshot (same shred AtomData content for the tables used here). Content of `ISOTOPE_INFO_TABLE` / `stableElementTable` / `standardMassTable` / `numNeutronsInMostStableIsotope` verified against raw GitHub file at the locked commit.

## Files actually used (minimal subset)

| File | What we extract |
|---|---|
| `js/AtomData.ts` | `TRACE_ABUNDANCE`, `stableElementTable`, `numNeutronsInMostStableIsotope`, `ISOTOPE_INFO_TABLE`, `standardMassTable` |
| `js/AtomNameUtils.ts` | `symbolTable`, `englishNameTable` (Z ≤ 18) |
| `js/AtomInfoUtils.ts` | Method **semantics only** (ported in Dart; not vendored whole) |

**Not** migrated (unused by IAAM Phase 1 / not needed for Make+Mix data):

- `HalfLifeConstants`, `DECAYS_INFO_TABLE`, electron-cloud radius maps
- Particle / ParticleAtom / view code

## Flutter output

```
lib/chemistry/isotopes_and_atomic_mass/model/data/atom_data_tables.dart  (generated)
```

Converter: `tool/isotopes_and_atomic_mass/convert_atom_data.py`
