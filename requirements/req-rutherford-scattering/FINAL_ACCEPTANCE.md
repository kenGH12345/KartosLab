# FINAL_ACCEPTANCE — Rutherford Scattering

## Status

**READY** — P0 = 0，本轮 P1 Visual Convergence 已清零（余量仅 P2 chrome）。

```
RUTHERFORD SCATTERING — P1 VISUAL STATUS

P0:
0

P1:
0

Physics:
PASS

Interaction:
PASS

Visual:
PASS / P2 remaining

Tests:
PASS (22 = 15 model + 6 visual capture + 1 gun tap)

Analyze:
0 issues

APK:
PASS
```

**枪按钮修复（收尾）：** 全屏虚线层曾拦截点击 → `IgnorePointer` + 枪体 `InkWell`；`rs_gun_tap_test` 覆盖开关发射。

---

## Visual Convergence（本轮）

| 项 | 做法 | 结果 |
|---|---|---|
| 箔片 / 枪布局 | `RsLayout` 从 `RSBaseScreenView` 反推绝对坐标（gun left=75, top=359；foil 120×30；beam 40×110；space@209,5） | PASS |
| 场景按钮竖排 | `RsSceneRadio` 左侧竖排，`left=foil.left`，`top=space.top`，spacing=15，选中黄边 | PASS |
| Energy thumb | 自绘 `RsPhetSlider` 15×30，蓝 `#3291B8`，track h=1 | PASS |
| Protons thumb | 同几何，红 `#DC3A0A` + center line | PASS |
| Neutrons thumb | 灰 `#828282`（视觉 only） | PASS |
| 1024×618 | `FittedBox` + `RsLayout.layoutW/H`；截图矩阵 V1 | PASS |

**未改 Model / Physics / Interaction**（perpendicular、D 公式、scene clear、neutrons 不进散射等保持）。

---

## Visual QA Matrix

目录：`requirements/req-rutherford-scattering/visual-qa/`

| Frame | File |
|---|---|
| Rutherford initial | `V1/rutherford_initial.png` |
| Atomic scale | `V1/rutherford_atomic_scale.png` |
| Nuclear scale | `V1/rutherford_nuclear_scale.png` |
| Energy changed | `V1/rutherford_energy_changed.png` |
| Protons changed | `V1/rutherford_protons_changed.png` |
| Plum Pudding initial | `V1/plum_pudding_initial.png` |
| PhET reference | `reference/rutherford-scattering-screenshot-screen1.png` |
| PhET reference | `reference/rutherford-scattering-screenshot-screen2.png` |

判定：
- [原版资源一致] Substituted = 0（`ASSET_MAP.md`）
- [布局已对齐] gun/foil/space/panels 按 PhET 公式坐标
- [动态绘制已对齐] 观察窗 Bohr / nucleus / plum（运行时加载 PNG）

---

## Remaining P2

- LaserPointerNode 精确 bevel / 光照
- scenery-phet TimeControl 图标路径（现为 Material glyph + PhET 色）
- Projector color profile
- Nucleus nucleon packing vs shred ParticleAtom 动画
- 面板 title 字重 / 极细间距

---

## Regression Result

| Check | Result |
|---|---|
| `flutter test test/rutherford_scattering/` | 21 PASS |
| `flutter analyze lib/rutherford_scattering` | No issues |
| `flutter build apk --debug` | PASS |

---

## Entry

Home → 化学 → 原子核 → **Rutherford Scattering**
