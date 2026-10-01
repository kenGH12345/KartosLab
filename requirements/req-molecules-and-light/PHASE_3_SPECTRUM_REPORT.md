# PHASE_3_SPECTRUM_REPORT — Molecules and Light

## Source audit

| File | Role |
|------|------|
| `greenhouse-effect/.../SpectrumDiagram.js` | Full Light Spectrum Diagram (title, arrows, strip, chirp) |
| `scenery-phet/WavelengthSpectrumNode.ts` | Visible strip via `VisibleColor.wavelengthToColor` |
| `scenery-phet/VisibleColor.ts` | MIN=380 nm, MAX=780 nm |
| `MicroScreenView.js` | Button caption **Light Spectrum Diagram**; dialog via `LightSpectrumDialog` capsule (content built once) |

## Geometry (source constants)

| Constant | Value |
|----------|-------|
| `SUBSECTION_WIDTH` | 657 |
| `STRIP_HEIGHT` | 87 |
| `MIN_FREQUENCY` | 1e3 Hz |
| `MAX_FREQUENCY` | 1e21 Hz |
| Frequency ticks | 10⁴ … 10²⁰ (labels on even exponents) |
| Wavelength ticks | 10⁻¹² … 10⁴ m (via `c / λ`) |
| Visible band | 400e12 … 790e12 Hz; node rotated π so red is low-f |
| Band dividers | 1e9, 3e11, 1e16, 1e19 (dotted) |
| Band labels | Radio, Microwave, Infrared, Visible, Ultra-violet, X-ray, Gamma ray |
| Arrows | Frequency → cyan; Wavelength ← magenta |
| Units | Hz (top-right), m (bottom-right) |
| Speed of light | 299792458 m/s |

## Flutter implementation

- `lib/molecules_and_light/view/spectrum_diagram_painter.dart` — `CustomPaint` port of `SpectrumDiagram` / `LabeledSpectrumNode` / `ChirpNode` / `LabeledArrow`
- Dialog in `molecules_and_light_screen.dart` toggles `_spectrumOpen` only; **does not** recreate model
- Button label: **Light Spectrum Diagram** (source string)
- No third-party / Material spectrum artwork → **Substituted = 0**

## Interaction tests

| Case | Result |
|------|--------|
| Open / close / reopen | PASS — state unchanged |
| While paused | PASS |
| While playing | PASS |
| After light selection | PASS |
| Log span endpoints | PASS (0 … 657) |

## Notes

- Visible colors use a continuous rainbow approximating `WavelengthSpectrumNode` (full `VisibleColor` LUT is P2 polish).
- Tick exponents rendered as `10^n` text (source uses RichText superscript) — P2.
