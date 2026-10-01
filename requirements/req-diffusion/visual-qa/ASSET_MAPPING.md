# ASSET_MAPPING — Diffusion

| PhET Asset | Source Path | Flutter | Consumer | 标记 |
|---|---|---|---|---|
| diffusion-screenshot*.png | diffusion-main/assets/ | `assets/phet/diffusion/` + visual-qa reference | docs / marketing | [已确认] |
| Particle fills | GasPropertiesColors (cyan/red) | `DiffusionConstants.particle*Color` + Painter | particles | [源码一致] 几何着色 |
| Container | DiffusionContainerNode（几何） | `DiffusionPlayAreaPainter` | play area | [行为一致] |
| Divider | 几何矩形 | Painter | play area | [源码一致] |
| Flow-rate arrows | ArrowNode scenery-phet | `ParticleFlowRatePainter` | under container | [源码一致] 几何 |
| Flow-rate checkbox icon | GasPropertiesIconFactory.createParticleFlowRateIcon | `_FlowRateIcon` dual arrows | control panel | [行为一致] |
| Screen icon | GasPropertiesIconFactory | Material `Icons.blur_on` Home 入口 | Home | [有意差异] Home 级 |
| Sound assets | — | — | — | **[源码一致：原版无音效]**（无 `sounds/`、无 SoundClip） |

无 PNG 粒子精灵强制要求 — PhET Diffusion 使用 Canvas/`ParticlesNode` 几何绘制。
无 scenery-phet 位图资源必须复制；箭头为矢量几何。
