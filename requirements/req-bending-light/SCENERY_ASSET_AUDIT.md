# Scenery Asset Audit — FINAL QA-6

Flutter copies live in `assets/simulations/bending_light/`.

| Asset | Source file | Size | Scale / crop | Flutter usage |
| --- | --- | --- | --- | --- |
| `knob.png` | `bending-light-main/images/knob.png` | 34×31 | Laser pointer scale 0.58. Prism knob height 15 → scale `15/31`. | `LaserPointerWidget` and the Prisms rotation knob. **Not** the index `HSlider` thumb. The slider thumb is a 10×20 vector from the `HSlider` call site. |
| `laser.png` | `bending-light-main/images/laser.png` | 144×57 | Prisms radio icon clips a 44×57 region and scales `0.6 * 0.875`. | `_LaserTypeIcon` only. The laser body is `LaserPointerNode` vector, not this image. |
| `protractor.png` | `scenery-phet/mipmaps/protractor.png` | 302×302 | Placed: Intro 0.8, Prisms 0.46. Toolbox icon 0.24 → 72.5×72.5. | `ProtractorWidget` and `ProtractorToolboxIcon` (`width: 72`). |
| Probe | `scenery-phet/js/ProbeNode.ts` | vector | Intensity radius 50, inner 35, handle 50×30, scale 0.6, color `#008541`. Wave probes: radius 43, inner 32, handle 40×30, corner 9, scale 0.35, crosshairs. | `ProbeGlyph`. No PNG. Bevel/gradient is still the secondary pass. |
| Graph highlight | `ShadedRectangle.ts` | vector | white base, `lightSource: rightBottom`, corner 5 | `paintShadedRectangle`. No image. |
| Spectrum track | `SpectrumSlider` / `VisibleColor` | vector | track 20, thumb 20, white stroke | `PhetSpectrumSlider` samples `visibleColorArgb`. No image. |

There is no case in this pass where a real source PNG is still replaced by a Material icon. `knob.png` is used where the source uses it. The index slider does not use it, and Flutter does not pretend that it does.

Probe, velocity, wave, and prism **toolbox** icons are painted nodes. They are not Material icons. They are also not yet the full source node tree (see `SCENERY_COMPONENT_MAPPING.md`).
