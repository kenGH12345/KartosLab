# PHASE 0 — Source Recon · Molecule Polarity

> 源码根：`phet sourses/molecule-polarity-main/molecule-polarity-main`  
> 版本：**molecule-polarity 2.1.0-dev.0**（`package.json:3`）  
> 侦察日期：2026-09-15 · 结论以本地源码为准（网页仅作交叉验证）

---

## 1. SOURCE MAP

```
molecule-polarity-main/
├── js/
│   ├── molecule-polarity-main.ts          # 入口 Sim(title, [TwoAtoms, ThreeAtoms, RealMolecules])
│   ├── moleculePolarity.ts                # namespace
│   ├── MoleculePolarityStrings.ts / Fluent
│   ├── common/
│   │   ├── MPConstants.ts                 # LAYOUT 1100×700 · EN 2–4 · ATOM 100 · BOND 150
│   │   ├── MPColors.ts / MPQueryParameters.ts
│   │   ├── model/
│   │   │   ├── Atom.ts / Bond.ts / Molecule.ts / MPModel.ts
│   │   │   ├── MPPreferences.ts           # 全局 dipoleDirection + surfaceColor
│   │   │   ├── DipoleDirection.ts / SurfaceType.ts / SurfaceColor.ts
│   │   │   ├── Polarity.ts / normalizeAngle.ts
│   │   └── view/                          # 共用 UI（EN slider、偶极、E 场极板、面板…）
│   ├── twoatoms/                          # Screen 1
│   ├── threeatoms/                        # Screen 2
│   └── realmolecules/                     # Screen 3（Three.js + RealMoleculeData）
├── images/                                # 仅 realMoleculesScreenIcon.png
├── assets/generated-data/                 # all-molecules.json（生成 RealMoleculeData）
└── doc/
```

无独立 `sounds/` 业务资源。

## 2. ENTRY MAP

- 入口：`js/molecule-polarity-main.ts` → `webgl: true`
- 屏幕顺序（默认首屏 = Two Atoms）：
  1. `TwoAtomsScreen`
  2. `ThreeAtomsScreen`
  3. `RealMoleculesScreen`
- 标题：Molecule Polarity

## 3. SCREEN MAP

| # | Screen | Model | View | 默认关键 |
|---|---|---|---|---|
| 1 | Two Atoms | `TwoAtomsModel` + `DiatomicMolecule` | `TwoAtomsScreenView` | bond dipole on；EN A=2 B=3；surface none；E-field off |
| 2 | Three Atoms | `ThreeAtomsModel` + `TriatomicMolecule` | `ThreeAtomsScreenView` | molecular dipole on；bond angles 5π/6 & π/6；**无 Surface** |
| 3 | Real Molecules | `RealMoleculesModel` | `RealMoleculesScreenView` (Mobius/WebGL) | 默认分子 **HF**；Basic；atom labels on；**无 E-field** |

### 跨屏状态

| 状态 | 共享？ |
|---|---|
| `MPPreferences.dipoleDirectionProperty` | **是** |
| `MPPreferences.surfaceColorProperty` | **是**（主要影响 Real Molecules ESP） |
| 各屏 Model / ViewProperties | **否** |
| Reset All | **仅当前屏** |

## 4. ASSETS

| 资源 | 路径 | 用途 |
|---|---|---|
| `realMoleculesScreenIcon.png` | `images/` | Screen 3 主页图标 |
| Screen 1/2 图标 | 程序化 `ShadedSphereNode` + `Rectangle` | 非图片 |
| 其余视觉 | Scenery Path / Three.js mesh | 禁止用 Material Icon / emoji 替代 |

**Substituted Assets 目标：0**（本 sim 几乎全程序绘制；唯一 PNG 必须复用）。

## 5. ANIMATION / CLOCK

- Joist `model.step(dt)` / `view.step(dt)`
- **唯一持续动画（Screen 1/2）**：E 场开启且非拖拽时，`MPModel.updateMoleculeOrientation` 逐步对齐偶极（`MAX_RADIANS_PER_STEP = 0.17`）
- Real Molecules：无 E 场自动旋转；3D 每帧渲染
- Flutter：Screen 1/2 用 `SimulationClock`（或等效 ticker）仅驱动 E 场对齐；无场时可按需 tick

## 6. REUSE vs CREATE（KartosLab）

| 项 | 决策 |
|---|---|
| `KratosTabbedScreen` | REUSE |
| `KratosSlider` / Radio / ComboBox | REUSE（外观不足则 sim 内 PhET 样式包装） |
| `SimulationClock` | REUSE（E 场对齐） |
| PhET Checkbox / ResetAll | EXTEND（参考 pendulum/projectile） |
| `BamElement` 电负性 | 不直接耦合；Real Molecules 用源码硬编码 display EN |
| 2D Atom/Bond/Dipole/Surface | CREATE `lib/chemistry/molecule_polarity/` |
| Real Molecules 3D + mesh 数据 | CREATE（端口/投影策略见 PHASE_1） |

## 7. MIGRATION SCOPE

**全量三屏**（与默认入口一致）。  
实现优先级：Two Atoms → Three Atoms → Real Molecules（3D 最复杂）。  
**Home 接入推迟到 Final Gate 之后（M10）。**
