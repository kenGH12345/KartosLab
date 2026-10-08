# FONT_LOCALIZATION_AUDIT

> PHASE 1 · Investigation only — **no global font replacement**.

## Current stack

| Layer | Finding |
|---|---|
| `pubspec.yaml` fonts | No bundled custom fonts (section commented) |
| `lib/main.dart` Theme | `fontFamilyFallback`: Microsoft YaHei → PingFang SC → Noto Sans CJK SC → Arial |
| Sim hardcodes | Many `fontFamily: 'Arial'` (QWI, Ohm, Molecule Polarity, QM typography…) |
| PhET source semantics | Typically Arial / Helvetica / sans-serif via `PhetFont` |

## Chinese glyph availability

- Arial **lacks** CJK glyphs → Flutter/OS falls back through `fontFamilyFallback` / platform fonts.
- Windows: Microsoft YaHei typically available.
- Android: Noto Sans CJK / system CJK; **must verify on device** in PHASE 5.
- iOS: PingFang SC expected.

## Risks

1. Baseline / line-height mismatch when CJK fallback kicks in vs Arial Latin metrics.
2. Button vertical centering may shift slightly for Chinese labels.
3. Weight: YaHei “Regular” vs Arial Bold hierarchy may look softer.
4. Monospace (`RobotoMono` / Courier) for numbers — keep for numeric; do not force CJK into mono plots.

## PHASE 1 decisions

- **Keep** existing Theme fallbacks (already CJK-capable).
- **Do not** mass-replace Arial in sims this phase.
- Record Font substitution: `Arial → system CJK fallback` for Home + shared chrome text.
- Golden / Android verification deferred to later phases (`goldens_zh/`).

## Follow-ups (not PHASE 1)

- Optional: bundle `NotoSansSC` for deterministic Android CI.
- Per-sim typography tokens that request `fontFamily` + explicit `fontFamilyFallback`.
