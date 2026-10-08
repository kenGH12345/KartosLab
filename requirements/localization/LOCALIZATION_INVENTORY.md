# LOCALIZATION_INVENTORY

> PHASE 0 — Global Localization Audit · 2026-10-08
>
> **本阶段只扫描与盘点，未修改任何 Simulation Model / Physics / Renderer。**
> 扫描根目录：`lib/`。原始 PhET source（`phet/`、archaeology 树）**不翻译、不修改**。

## 0. Executive Summary

| Metric | Count |
|---|---:|
| Dart files scanned | 2221 |
| User-visible string hits | 2341 |
| English | 1337 |
| Chinese | 765 |
| Mixed-language | 70 |
| Accessibility-related | 55 |
| Scientific symbols / units | 34 |
| Technical identifiers | 39 |
| Other / unclassified | 96 |
| Existing `*strings*.dart` files | 32 |
| `lib/l10n/` present | **NO** |
| `.arb` / `flutter_localizations` | **NO** |

### Verdict (PHASE 0)

- 用户可见文本 **以英文为主**（约 57% English hits），中文约 33%，混合约 3%。
- **不存在** 统一 Localization 层；仅有分散 `*Strings` 袋。
- Home 分类中文，但 Simulation 显示名大量仍为英文 → **混合语言入口**。
- Accessibility 字符串稀少且多为英文（如 `gfl_a11y_strings.dart`）。
- 字体：`main.dart` 有中文 fallback；大量 sim 硬编码 `Arial` → 需 Font substitution 审计（PHASE 后续）。

## 1. Classification Totals

| Classification | Count | Notes |
|---|---:|---|
| english | 1337 | 需本地化 |
| chinese | 765 | 已中文（多为硬编码，未进统一 API） |
| other | 96 | 待人工复核 |
| mixed | 70 | 中英混排 — 需清理 |
| technical | 39 | identifier / path 类 |
| scientific_symbol | 34 | 可保留单位/符号 |

### Kind breakdown

| Kind | Count |
|---|---:|
| `strings_const` | 976 |
| `cjk_literal` | 343 |
| `label` | 293 |
| `Text` | 293 |
| `title` | 227 |
| `name` | 81 |
| `tooltip` | 59 |
| `TextSpan` | 32 |
| `semanticLabel` | 13 |
| `displayName` | 9 |
| `semanticsLabel` | 7 |
| `message` | 4 |
| `englishName` | 2 |
| `hintText` | 1 |
| `hint` | 1 |

## 2. Existing Localization Infrastructure

| Item | Status |
|---|---|
| `lib/l10n/` / `KartosLocalization` | **Absent** |
| `.arb` / `gen_l10n` | **Absent** |
| `flutter_localizations` | **Absent** |
| Per-sim `*Strings` classes | **32 files** — de-facto bags, mostly English |
| Chinese hardcoding precedent | `ForcesStrings`, some Home/chem titles, `EspStrings.title` |
| Home categories | Mostly Chinese |
| Home sim titles | **Mixed** CN / EN / bilingual |
| A11y string bags | Sparse; Gravity Force Lab a11y still English |
| PhET original source | Out of scope (archaeology evidence) |

### Existing `*strings*.dart` files

- `lib/astronomy/gravity_and_orbits/gao_strings.dart`
- `lib/astronomy/keplers_laws/keplers_laws_strings.dart`
- `lib/astronomy/my_solar_system/my_solar_system_strings.dart`
- `lib/balancing_act/ba_strings.dart`
- `lib/balancing_chemical_equations/bce_strings.dart`
- `lib/blackbody_spectrum/blackbody_spectrum_strings.dart`
- `lib/capacitor_lab_basics/clb_strings.dart`
- `lib/cck_ac_virtual_lab/cck_strings.dart`
- `lib/charges_and_fields/caf_strings.dart`
- `lib/chemistry/build_a_molecule/data/bam_strings.dart`
- `lib/chemistry/molecule_polarity/mp_strings.dart`
- `lib/chemistry/states_of_matter/som_strings.dart`
- `lib/collision_lab/collision_lab_strings.dart`
- `lib/curve_fitting/curve_fitting_strings.dart`
- `lib/density/density_strings.dart`
- `lib/energy_forms_and_changes/efac_strings.dart`
- `lib/energy_skate_park/esp_strings.dart`
- `lib/forces/config/forces_strings.dart`
- `lib/fourier_making_waves/fmw_strings.dart`
- `lib/friction/friction_strings.dart`
- `lib/gravity_force_lab/a11y/gfl_a11y_strings.dart`
- `lib/gravity_force_lab/gfl_strings.dart`
- `lib/gravity_force_lab_basics/gflb_strings.dart`
- `lib/molecule_shapes/molecule_shapes_strings.dart`
- `lib/normal_modes/normal_modes_strings.dart`
- `lib/pendulum_lab/pl_strings.dart`
- `lib/plinko_probability/plinko_strings.dart`
- `lib/projectile_motion/pm_strings.dart`
- `lib/quantum_coin_toss/common/quantum_measurement_strings.dart`
- `lib/reactants_products_and_leftovers/rpal_strings.dart`
- `lib/rutherford_scattering/rs_strings.dart`
- `lib/vector_addition/vector_addition_strings.dart`

## 3. Home vs Simulation

| Scope | Hits | English | Chinese | Mixed |
|---|---:|---:|---:|---:|
| Home (`lib/screens/home_screen.dart`) | 71 | 10 | 50 | 11 |
| All `lib/` | 2341 | 1337 | 765 | 70 |

**Home 观察：**

- 学科/分组名基本中文；`englishName: Physics/Chemistry` 仍暴露英文。
- 卡片 title 大量引用各模块英文 `static const title`（`Bending Light`、`Pendulum Lab` 等）。
- 部分已中文（力与运动、密度、电路搭建、摩尔浓度、构建原子、浮力…）→ **入口混排**。
- 多处 subtitle 故意中英混排（`Single Bulb · RGB Bulbs`、`Model / To Scale`、`Intro / Laws`）。

## 4. Top 20 Highest-Impact Files

按 English + Mixed 命中数（优先迁移）：

| Rank | File | EN+Mixed |
|---:|---|---:|
| 1 | `lib/chemistry/states_of_matter/som_strings.dart` | 41 |
| 2 | `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | 40 |
| 3 | `lib/projectile_motion/pm_strings.dart` | 38 |
| 4 | `lib/gravity_force_lab/a11y/gfl_a11y_strings.dart` | 35 |
| 5 | `lib/pendulum_lab/pl_strings.dart` | 34 |
| 6 | `lib/astronomy/gravity_and_orbits/gao_strings.dart` | 33 |
| 7 | `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | 33 |
| 8 | `lib/cck_ac_virtual_lab/cck_strings.dart` | 33 |
| 9 | `lib/balancing_act/ba_strings.dart` | 28 |
| 10 | `lib/collision_lab/collision_lab_strings.dart` | 28 |
| 11 | `lib/quantum_coin_toss/common/quantum_measurement_strings.dart` | 28 |
| 12 | `lib/chemistry/molecule_polarity/mp_strings.dart` | 25 |
| 13 | `lib/density/density_strings.dart` | 23 |
| 14 | `lib/energy_forms_and_changes/efac_strings.dart` | 22 |
| 15 | `lib/rutherford_scattering/rs_strings.dart` | 21 |
| 16 | `lib/screens/home_screen.dart` | 21 |
| 17 | `lib/vector_addition/vector_addition_strings.dart` | 19 |
| 18 | `lib/blackbody_spectrum/blackbody_spectrum_strings.dart` | 16 |
| 19 | `lib/normal_modes/normal_modes_strings.dart` | 16 |
| 20 | `lib/capacitor_lab_basics/clb_strings.dart` | 15 |

## 5. Per-Module Breakdown

| Module | Total | English | Chinese | Mixed | A11y | Files |
|---|---:|---:|---:|---:|---:|---:|
| `physics/quantum_wave_interference` | 67 | 56 | 1 | 0 | 0 | 17 |
| `gravity_force_lab` | 56 | 52 | 0 | 0 | 35 | 4 |
| `astronomy/keplers_laws` | 59 | 51 | 0 | 0 | 0 | 4 |
| `bending_light` | 47 | 46 | 1 | 0 | 7 | 15 |
| `collision_lab` | 53 | 46 | 2 | 0 | 0 | 7 |
| `quantum_measurement` | 64 | 46 | 1 | 0 | 0 | 26 |
| `projectile_motion` | 47 | 44 | 1 | 0 | 0 | 5 |
| `chemistry/states_of_matter` | 46 | 42 | 0 | 0 | 0 | 3 |
| `astronomy/my_solar_system` | 41 | 36 | 0 | 1 | 0 | 4 |
| `chemistry/build_a_nucleus` | 53 | 35 | 12 | 1 | 0 | 15 |
| `pendulum_lab` | 39 | 36 | 0 | 0 | 0 | 3 |
| `buoyancy` | 37 | 35 | 2 | 0 | 0 | 14 |
| `cck_ac_virtual_lab` | 36 | 34 | 0 | 0 | 0 | 4 |
| `astronomy/gravity_and_orbits` | 35 | 33 | 0 | 0 | 0 | 3 |
| `balancing_act` | 36 | 33 | 0 | 0 | 0 | 3 |
| `quantum_coin_toss` | 38 | 31 | 1 | 0 | 0 | 5 |
| `vector_addition` | 33 | 31 | 0 | 0 | 0 | 5 |
| `color_vision` | 117 | 10 | 85 | 20 | 0 | 11 |
| `masses_and_springs_basics` | 30 | 30 | 0 | 0 | 0 | 8 |
| `chemistry/molecule_polarity` | 34 | 27 | 0 | 0 | 0 | 4 |
| `gas_properties` | 27 | 27 | 0 | 0 | 0 | 5 |
| `hookes_law` | 26 | 26 | 0 | 0 | 0 | 8 |
| `chemistry/ph_scale` | 37 | 24 | 0 | 0 | 0 | 11 |
| `density` | 26 | 24 | 0 | 0 | 0 | 2 |
| `energy_forms_and_changes` | 26 | 24 | 0 | 0 | 0 | 3 |
| `balancing_chemical_equations` | 24 | 23 | 1 | 0 | 0 | 5 |
| `waves_intro` | 23 | 23 | 0 | 0 | 0 | 4 |
| `rutherford_scattering` | 26 | 22 | 0 | 0 | 0 | 4 |
| `screens` | 78 | 10 | 56 | 12 | 0 | 2 |
| `beers_law_lab` | 22 | 21 | 1 | 0 | 0 | 9 |
| `capacitor_lab_basics` | 19 | 19 | 0 | 0 | 2 | 2 |
| `concentration` | 23 | 19 | 2 | 0 | 0 | 5 |
| `curve_fitting` | 29 | 18 | 0 | 0 | 0 | 2 |
| `chemistry/isotopes_and_atomic_mass` | 18 | 17 | 1 | 0 | 0 | 7 |
| `forces` | 138 | 15 | 118 | 2 | 0 | 9 |
| `plinko_probability` | 23 | 16 | 0 | 1 | 0 | 4 |
| `blackbody_spectrum` | 22 | 16 | 0 | 0 | 0 | 1 |
| `normal_modes` | 18 | 16 | 0 | 0 | 0 | 2 |
| `under_pressure` | 21 | 16 | 1 | 0 | 0 | 6 |
| `wave_on_a_string` | 17 | 16 | 1 | 0 | 2 | 5 |
| `common` | 116 | 4 | 101 | 11 | 0 | 24 |
| `chemistry/build_an_atom` | 20 | 14 | 5 | 0 | 0 | 7 |
| `john_travoltage` | 17 | 14 | 1 | 0 | 0 | 3 |
| `membrane_transport` | 17 | 14 | 0 | 0 | 0 | 5 |
| `balloons_and_static_electricity` | 13 | 12 | 1 | 0 | 2 | 5 |
| `charges_and_fields` | 18 | 12 | 1 | 0 | 0 | 2 |
| `chemistry/acid_base_solutions` | 13 | 11 | 1 | 1 | 0 | 4 |
| `gases_intro` | 12 | 12 | 0 | 0 | 0 | 5 |
| `ohms_law` | 13 | 12 | 1 | 0 | 2 | 6 |
| `resistance_in_a_wire` | 13 | 11 | 2 | 0 | 3 | 6 |
| `friction` | 13 | 10 | 1 | 0 | 0 | 2 |
| `diffusion` | 11 | 9 | 0 | 0 | 0 | 2 |
| `energy_skate_park` | 68 | 9 | 56 | 0 | 0 | 4 |
| `gravity_force_lab_basics` | 11 | 9 | 0 | 0 | 0 | 1 |
| `chemistry/build_a_molecule` | 12 | 5 | 4 | 3 | 0 | 6 |
| `molecules_and_light` | 8 | 7 | 1 | 0 | 0 | 2 |
| `circuit` | 74 | 0 | 68 | 6 | 0 | 5 |
| `faradays_law` | 9 | 6 | 1 | 0 | 0 | 5 |
| `fourier_making_waves` | 68 | 5 | 59 | 1 | 0 | 4 |
| `magnetism/magnet_and_compass` | 10 | 6 | 1 | 0 | 0 | 2 |
| `chemistry/molarity` | 30 | 1 | 25 | 4 | 2 | 10 |
| `reactants_products_and_leftovers` | 5 | 5 | 0 | 0 | 0 | 3 |
| `radio_waves` | 29 | 0 | 25 | 4 | 0 | 1 |
| `wave_interference` | 35 | 0 | 33 | 2 | 0 | 1 |
| `main.dart` | 1 | 1 | 0 | 0 | 0 | 1 |
| `molecule_shapes` | 1 | 1 | 0 | 0 | 0 | 1 |
| `optics` | 52 | 0 | 51 | 1 | 0 | 2 |
| `sound` | 41 | 1 | 40 | 0 | 0 | 3 |

## 6. High-Frequency English Phrases

| English Text | Occurrences | Suggested Key | Chinese (draft) | Status |
|---|---:|---|---|---|
| Reset All | 25 | `resetAll` | 全部重置 | ENGLISH |
| Normal | 17 | `normal` | 正常 | ENGLISH |
| Slow | 13 | `slow` | 慢速 | ENGLISH |
| Intro | 13 | `intro` | 介绍 | ENGLISH |
| None | 10 | `none` | 无 | ENGLISH |
| Custom | 10 | `custom` | 自定义 | ENGLISH |
| Stopwatch | 9 | `stopwatch` | 秒表 | ENGLISH |
| Close | 9 | `close` | 关闭 | ENGLISH |
| Velocity | 8 | `velocity` | 速度 | ENGLISH |
| Speed | 8 | `speed` | 速率 | ENGLISH |
| Reset | 8 | `reset` | 重置 | ENGLISH |
| Earth | 7 | `earth` | 地球 | ENGLISH |
| Arial | 7 | `arial` | （待定 · 见 glossary 扩展） | ENGLISH |
| Values | 7 | `values` | 数值 | ENGLISH |
| Gravity | 6 | `gravity` | 重力 | ENGLISH |
| Mass | 6 | `mass` | 质量 | ENGLISH |
| Grid | 6 | `grid` | 网格 | ENGLISH |
| Step | 6 | `step` | 步进 | ENGLISH |
| Water | 6 | `water` | 水 | ENGLISH |
| Material | 6 | `material` | 材料 | ENGLISH |
| Jupiter | 5 | `jupiter` | 木星 | ENGLISH |
| Lab | 5 | `lab` | 实验室 | ENGLISH |
| % Submerged | 5 | `percentSubmerged` | 浸没百分比 | ENGLISH |
| Energy | 5 | `energy` | 能量 | ENGLISH |
| Path | 4 | `path` | 轨迹 | ENGLISH |
| Measuring Tape | 4 | `measuringTape` | 卷尺 | ENGLISH |
| Fast | 4 | `fast` | 快速 | ENGLISH |
| Center of Mass | 4 | `centerOfMass` | 质心 | ENGLISH |
| Light | 4 | `light` | 光 | ENGLISH |
| Intensity | 4 | `intensity` | 强度 | ENGLISH |
| Object Density | 4 | `objectDensity` | 物体密度 | ENGLISH |
| Protons | 4 | `protons` | （待定 · 见 glossary 扩展） | ENGLISH |
| Neutrons | 4 | `neutrons` | （待定 · 见 glossary 扩展） | ENGLISH |
| Symbol | 4 | `symbol` | 符号 | ENGLISH |
| Constant Size | 4 | `constantSize` | 恒定大小 | ENGLISH |
| OK | 4 | `ok` | 确定 | ENGLISH |
| Lots | 4 | `lots` | 很多 | ENGLISH |
| Cartesian | 4 | `cartesian` | 直角坐标 | ENGLISH |
| Gravity Force | 3 | `gravityForce` | 引力 | ENGLISH |
| Mars | 3 | `mars` | 火星 | ENGLISH |
| Game | 3 | `game` | 游戏 | ENGLISH |
| Next | 3 | `next` | 下一步 | ENGLISH |
| Try Again | 3 | `tryAgain` | 再试一次 | ENGLISH |
| Show Answer | 3 | `showAnswer` | 显示答案 | ENGLISH |
| Balanced | 3 | `balanced` | 已配平 | ENGLISH |
| Ruler | 3 | `ruler` | 尺子 | ENGLISH |
| Light Bulb | 3 | `lightBulb` | 灯泡 | ENGLISH |
| Electric Field | 3 | `electricField` | 电场 | ENGLISH |
| Voltage | 3 | `voltage` | 电压 | ENGLISH |
| Particles | 3 | `particles` | 粒子 | ENGLISH |

## 7. Mixed-Language Samples

| Text | Occurrences | Status |
|---|---:|---|
| 加载失败: $_error | 3 | MIXED — needs cleanup |
| N-body 引力 · 轨道系统 | 2 | MIXED — needs cleanup |
| 加色法 vs 减色法 · 生活对照 | 2 | MIXED — needs cleanup |
| Intro · My Solution · 酸碱电离 | 1 | MIXED — needs cleanup |
| 构建原子核 · Chart Intro | 1 | MIXED — needs cleanup |
| 溶质量(${range.unit ??  | 1 | MIXED — needs cleanup |
| 烧杯。溶质 ${solution.solute.name}。体积 ${solution.volume.toStringAsFixed(3)} 升。浓度 ${solution.concentration.toStringAsFixed(3)} 摩尔每升。${solution.isSaturated ?  | 1 | MIXED — needs cleanup |
| 溶液浓度 ${solution.concentration.toStringAsFixed(3)} 摩尔每升 | 1 | MIXED — needs cleanup |
| 体积(${range.unit ??  | 1 | MIXED — needs cleanup |
| 显式设为 null | 1 | MIXED — needs cleanup |
| 电路搭建 - ${sel.type.label} | 1 | MIXED — needs cleanup |
| 电流的本质 · 电子流 vs 常规电流 | 1 | MIXED — needs cleanup |
| KCL(电流定律): 流入节点的电流=流出节点的电流。KVL(电压定律): 闭合回路总电压降=0。 | 1 | MIXED — needs cleanup |
| 灯泡: 亮度 ${(b * 100).toInt()}% | 1 | MIXED — needs cleanup |
| ${sel.type.label} (不可调) | 1 | MIXED — needs cleanup |
| 匹配度 ${accuracy.round()}% | 1 | MIXED — needs cleanup |
| 颜色名称：$cname | 1 | MIXED — needs cleanup |
| RGB 值：rgb($rv, $gv, $bv) | 1 | MIXED — needs cleanup |
| 十六进制：$hex | 1 | MIXED — needs cleanup |
| Color Vision / 色觉 | 1 | MIXED — needs cleanup |
| 🎯 探究目标全部达成 · +$earnedScore 分 | 1 | MIXED — needs cleanup |
| 完美匹配 · +$earnedScore 分 | 1 | MIXED — needs cleanup |
| 亮度 Brightness | 1 | MIXED — needs cleanup |
| 标签 Labels | 1 | MIXED — needs cleanup |
| 红光 (Red) | 1 | MIXED — needs cleanup |
| 绿光 (Green) | 1 | MIXED — needs cleanup |
| 蓝光 (Blue) | 1 | MIXED — needs cleanup |
| 加色法原理 (Additive Mixing) | 1 | MIXED — needs cleanup |
| 加色法(光源RGB): 越混越亮,三原色全开=白光。减色法(颜料CMYK): 越混越暗,三原色全混=黑色。 | 1 | MIXED — needs cleanup |
| 屏幕显示用RGB加色,打印用CMYK减色——两种体系互补,覆盖了从发光到反射的全部色彩场景。 | 1 | MIXED — needs cleanup |

## 8. Inventory Sample Rows (EN/MIXED, first 200)

| File | Location | English Text | User Visible | Context | Localization Key | Chinese | Status |
|---|---|---|---|---|---|---|---|
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L7 | Gravity and Orbits | YES | strings | `gravityAndOrbits` | （待定） | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L8 | Model | YES | strings | `model` | （待定） | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L9 | To Scale | YES | strings | `toScale` | （待定） | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L11 | Gravity | YES | strings | `gravity` | 重力 | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L12 | on | YES | strings | `on` | （待定） | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L13 | off | YES | strings | `off` | （待定） | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L15 | Gravity Force | YES | strings | `gravityForce` | 引力 | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L16 | Velocity | YES | strings | `velocity` | 速度 | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L17 | Mass | YES | strings | `mass` | 质量 | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L18 | Path | YES | strings | `path` | 轨迹 | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L19 | Grid | YES | strings | `grid` | 网格 | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L20 | Measuring Tape | YES | strings | `measuringTape` | 卷尺 | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L22 | Clear | YES | strings | `clear` | （待定） | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L23 | Return Objects | YES | strings | `returnObjects` | （待定） | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L25 | Fast | YES | strings | `fast` | 快速 | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L26 | Normal | YES | strings | `normal` | 正常 | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L27 | Slow | YES | strings | `slow` | 慢速 | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L29 | Play | YES | strings | `play` | 播放 | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L30 | Pause | YES | strings | `pause` | 暂停 | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L31 | Step | YES | strings | `step` | 步进 | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L32 | Rewind | YES | strings | `rewind` | （待定） | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L33 | Reset All | YES | strings | `resetAll` | 全部重置 | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L34 | Reset Scene | YES | strings | `resetScene` | （待定） | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L36 | Earth Days | YES | strings | `earthDays` | （待定） | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L37 | Earth Minutes | YES | strings | `earthMinutes` | （待定） | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L39 | Star Mass | YES | strings | `starMass` | （待定） | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L40 | Planet Mass | YES | strings | `planetMass` | （待定） | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L41 | Moon Mass | YES | strings | `moonMass` | （待定） | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L42 | Satellite Mass | YES | strings | `satelliteMass` | （待定） | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L44 | Our Sun | YES | strings | `ourSun` | （待定） | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L45 | Earth | YES | strings | `earth` | 地球 | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L46 | Our Moon | YES | strings | `ourMoon` | （待定） | ENGLISH |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | L47 | Space Station | YES | strings | `spaceStation` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L7 | Kepler's Laws | YES | strings | `keplerSLaws` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L8 | First Law | YES | strings | `firstLaw` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L9 | Second Law | YES | strings | `secondLaw` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L10 | Third Law | YES | strings | `thirdLaw` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L11 | All Laws | YES | strings | `allLaws` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L13 | Always Circular | YES | strings | `alwaysCircular` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L14 | Target Orbit: | YES | strings | `targetOrbit` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L15 | Stopwatch | YES | strings | `stopwatch` | 秒表 | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L16 | Axes | YES | strings | `axes` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L17 | Foci | YES | strings | `foci` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L18 | String | YES | strings | `string` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L19 | Semiaxes | YES | strings | `semiaxes` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L20 | Eccentricity | YES | strings | `eccentricity` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L21 | Apoapsis | YES | strings | `apoapsis` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L22 | Periapsis | YES | strings | `periapsis` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L23 | Star Mass | YES | strings | `starMass` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L24 | Our Sun | YES | strings | `ourSun` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L25 | Period | YES | strings | `period` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L26 | Period Divisions | YES | strings | `periodDivisions` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L27 | Area Values | YES | strings | `areaValues` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L28 | Time Values | YES | strings | `timeValues` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L29 | Area (AU 2) | YES | strings | `areaAu2` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L30 | Swept Area | YES | strings | `sweptArea` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L31 | None | YES | strings | `none` | 无 | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L32 | Speed (km/s) | YES | strings | `speedKmS` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L33 | Velocity | YES | strings | `velocity` | 速度 | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L34 | Gravity Force | YES | strings | `gravityForce` | 引力 | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L35 | Grid | YES | strings | `grid` | 网格 | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L36 | Measuring Tape | YES | strings | `measuringTape` | 卷尺 | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L39 | AU | YES | strings | `au` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L40 | years | YES | strings | `years` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L41 | km/s | YES | strings | `kmS` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L55 | Mercury | YES | strings | `mercury` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L56 | Venus | YES | strings | `venus` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L57 | Earth | YES | strings | `earth` | 地球 | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L58 | Mars | YES | strings | `mars` | 火星 | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L59 | Jupiter | YES | strings | `jupiter` | 木星 | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L61 | Fast | YES | strings | `fast` | 快速 | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L62 | Normal | YES | strings | `normal` | 正常 | ENGLISH |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | L63 | Slow | YES | strings | `slow` | 慢速 | ENGLISH |
| `lib/astronomy/keplers_laws/model/target_orbit.dart` | L19 | None | YES | name | `none` | 无 | ENGLISH |
| `lib/astronomy/keplers_laws/model/target_orbit.dart` | L26 | Mercury | YES | name | `mercury` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/model/target_orbit.dart` | L32 | Venus | YES | name | `venus` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/model/target_orbit.dart` | L38 | Earth | YES | name | `earth` | 地球 | ENGLISH |
| `lib/astronomy/keplers_laws/model/target_orbit.dart` | L44 | Mars | YES | name | `mars` | 火星 | ENGLISH |
| `lib/astronomy/keplers_laws/model/target_orbit.dart` | L50 | Jupiter | YES | name | `jupiter` | 木星 | ENGLISH |
| `lib/astronomy/keplers_laws/model/target_orbit.dart` | L58 | Eris | YES | name | `eris` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/model/target_orbit.dart` | L64 | Nereid | YES | name | `nereid` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/model/target_orbit.dart` | L70 | Halley | YES | name | `halley` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/screens/keplers_laws_screen.dart` | L336 | ${KeplersLawsStrings.title} · ${_lawLabel()} | YES | Text | `todo` | （待定） | ENGLISH |
| `lib/astronomy/keplers_laws/widgets/keplers_panels.dart` | L280 | Eccentricity =  | YES | TextSpan | `eccentricity` | （待定） | ENGLISH |
| `lib/astronomy/my_solar_system/config/mss_scenario_manager.dart` | L34 | Sun, Planet | YES | name | `sunPlanet` | （待定） | ENGLISH |
| `lib/astronomy/my_solar_system/controller/my_solar_system_controller.dart` | L183 | Custom | YES | name | `custom` | 自定义 | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L7 | My Solar System | YES | strings | `mySolarSystem` | （待定） | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L8 | Intro | YES | strings | `intro` | 介绍 | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L9 | Lab | YES | strings | `lab` | 实验室 | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L10 | N-body 引力 · 轨道系统 | YES | strings | `nBody` | （待定） | MIXED |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L11 | Sun, Planet | YES | strings | `sunPlanet` | （待定） | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L12 | Custom | YES | strings | `custom` | 自定义 | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L13 | Play | YES | strings | `play` | 播放 | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L14 | Pause | YES | strings | `pause` | 暂停 | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L15 | Step | YES | strings | `step` | 步进 | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L16 | Restart | YES | strings | `restart` | （待定） | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L17 | Reset All | YES | strings | `resetAll` | 全部重置 | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L18 | years | YES | strings | `years` | （待定） | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L19 | Clear | YES | strings | `clear` | （待定） | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L20 | Fast | YES | strings | `fast` | 快速 | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L21 | Normal | YES | strings | `normal` | 正常 | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L22 | Slow | YES | strings | `slow` | 慢速 | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L23 | More Data | YES | strings | `moreData` | （待定） | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L24 | Mass | YES | strings | `mass` | 质量 | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L25 | Position | YES | strings | `position` | （待定） | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L26 | Velocity | YES | strings | `velocity` | 速度 | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L28 | AU | YES | strings | `au` | （待定） | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L29 | km/s | YES | strings | `kmS` | （待定） | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L32 | Vx | YES | strings | `vx` | （待定） | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L33 | Vy | YES | strings | `vy` | （待定） | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L34 | Center of Mass | YES | strings | `centerOfMass` | 质心 | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L35 | Gravity Force | YES | strings | `gravityForce` | 引力 | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L36 | Path | YES | strings | `path` | 轨迹 | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L37 | Grid | YES | strings | `grid` | 网格 | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L38 | Measuring Tape | YES | strings | `measuringTape` | 卷尺 | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L39 | Follow Center of Mass | YES | strings | `followCenterOfMass` | （待定） | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L40 | Velocity | YES | strings | `velocity` | 速度 | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L41 | Bodies | YES | strings | `bodies` | （待定） | ENGLISH |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | L42 | Return Bodies | YES | strings | `returnBodies` | （待定） | ENGLISH |
| `lib/astronomy/my_solar_system/screens/my_solar_system_screen.dart` | L375 | Custom | YES | name | `custom` | 自定义 | ENGLISH |
| `lib/astronomy/my_solar_system/screens/my_solar_system_screen.dart` | L393 | Orbital System | YES | label | `orbitalSystem` | （待定） | ENGLISH |
| `lib/balancing_act/ba_assets.dart` | L4 | $_root/objects | YES | strings_const | `rootObjects` | （待定） | ENGLISH |
| `lib/balancing_act/ba_assets.dart` | L5 | $_root/usa | YES | strings_const | `rootUsa` | （待定） | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L3 | Balancing Act | YES | strings | `balancingAct` | （待定） | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L4 | Intro · Balance Lab · Game | YES | strings | `introBalanceLabGame` | （待定） | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L5 | Intro | YES | strings | `intro` | 介绍 | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L6 | Balance Lab | YES | strings | `balanceLab` | （待定） | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L7 | Game | YES | strings | `game` | 游戏 | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L9 | Show | YES | strings | `show` | （待定） | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L10 | Mass Labels | YES | strings | `massLabels` | （待定） | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L11 | Forces from Objects | YES | strings | `forcesFromObjects` | （待定） | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L12 | Level | YES | strings | `level` | （待定） | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L13 | Position | YES | strings | `position` | （待定） | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L14 | None | YES | strings | `none` | 无 | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L15 | Rulers | YES | strings | `rulers` | （待定） | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L16 | Marks | YES | strings | `marks` | （待定） | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L18 | meters | YES | strings | `meters` | （待定） | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L19 | Bricks | YES | strings | `bricks` | （待定） | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L20 | People | YES | strings | `people` | （待定） | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L21 | Mystery Objects | YES | strings | `mysteryObjects` | （待定） | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L24 | Select Level | YES | strings | `selectLevel` | （待定） | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L25 | Start Over | YES | strings | `startOver` | （待定） | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L26 | Check | YES | strings | `check` | （待定） | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L27 | Next | YES | strings | `next` | 下一步 | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L28 | Try Again | YES | strings | `tryAgain` | 再试一次 | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L29 | Show Answer | YES | strings | `showAnswer` | 显示答案 | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L30 | Balance Me! | YES | strings | `balanceMe` | （待定） | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L31 | What is the mass? | YES | strings | `whatIsTheMass` | （待定） | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L32 | What will happen? | YES | strings | `whatWillHappen` | （待定） | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L33 | Continue | YES | strings | `continue` | （待定） | ENGLISH |
| `lib/balancing_act/ba_strings.dart` | L34 | Score | YES | strings | `score` | （待定） | ENGLISH |
| `lib/balancing_act/view/ba_game_screen.dart` | L612 | Timer | YES | Text | `timer` | （待定） | ENGLISH |
| `lib/balancing_act/view/ba_game_screen.dart` | L665 | ${BaStrings.level} ${level + 1} | YES | Text | `bastringsLevelLevel1` | （待定） | ENGLISH |
| `lib/balancing_act/view/ba_game_screen.dart` | L715 | Time: ${m.elapsedTime.toStringAsFixed(0)} s | YES | Text | `todo` | （待定） | ENGLISH |
| `lib/balancing_chemical_equations/bce_strings.dart` | L3 | Balancing Chemical Equations | YES | strings | `balancingChemicalEquations` | （待定） | ENGLISH |
| `lib/balancing_chemical_equations/bce_strings.dart` | L4 | Intro · Equations · Game | YES | strings | `introEquationsGame` | （待定） | ENGLISH |
| `lib/balancing_chemical_equations/bce_strings.dart` | L9 | Intro | YES | strings | `intro` | 介绍 | ENGLISH |
| `lib/balancing_chemical_equations/bce_strings.dart` | L10 | Equations | YES | strings | `equations` | （待定） | ENGLISH |
| `lib/balancing_chemical_equations/bce_strings.dart` | L11 | Game | YES | strings | `game` | 游戏 | ENGLISH |
| `lib/balancing_chemical_equations/equations/equations_feedback_node.dart` | L35 | Balanced | YES | label | `balanced` | 已配平 | ENGLISH |
| `lib/balancing_chemical_equations/equations/equations_feedback_node.dart` | L39 | Simplified | YES | label | `simplified` | （待定） | ENGLISH |
| `lib/balancing_chemical_equations/equations/equations_feedback_node.dart` | L41 | Not simplified | YES | label | `notSimplified` | （待定） | ENGLISH |
| `lib/balancing_chemical_equations/game/game_feedback_node.dart` | L229 | Balanced | YES | label | `balanced` | 已配平 | ENGLISH |
| `lib/balancing_chemical_equations/game/game_feedback_node.dart` | L231 | Simplified | YES | label | `simplified` | （待定） | ENGLISH |
| `lib/balancing_chemical_equations/game/game_feedback_node.dart` | L247 | Next | YES | label | `next` | 下一步 | ENGLISH |
| `lib/balancing_chemical_equations/game/game_feedback_node.dart` | L278 | Balanced | YES | label | `balanced` | 已配平 | ENGLISH |
| `lib/balancing_chemical_equations/game/game_feedback_node.dart` | L280 | Not simplified | YES | label | `notSimplified` | （待定） | ENGLISH |
| `lib/balancing_chemical_equations/game/game_feedback_node.dart` | L290 | Try Again | YES | label | `tryAgain` | 再试一次 | ENGLISH |
| `lib/balancing_chemical_equations/game/game_feedback_node.dart` | L292 | Show Answer | YES | label | `showAnswer` | 显示答案 | ENGLISH |
| `lib/balancing_chemical_equations/game/game_feedback_node.dart` | L318 | Not balanced | YES | label | `notBalanced` | （待定） | ENGLISH |
| `lib/balancing_chemical_equations/game/game_feedback_node.dart` | L326 | Try Again | YES | label | `tryAgain` | 再试一次 | ENGLISH |
| `lib/balancing_chemical_equations/game/game_feedback_node.dart` | L328 | Show Answer | YES | label | `showAnswer` | 显示答案 | ENGLISH |
| `lib/balancing_chemical_equations/game/game_screen.dart` | L509 | Check | YES | label | `check` | （待定） | ENGLISH |
| `lib/balancing_chemical_equations/game/game_screen.dart` | L515 | Next | YES | label | `next` | 下一步 | ENGLISH |
| `lib/balancing_chemical_equations/game/game_screen.dart` | L647 | Continue | YES | label | `continue` | （待定） | ENGLISH |
| `lib/balancing_chemical_equations/views/particles_node.dart` | L54 | Reactants | YES | title | `reactants` | （待定） | ENGLISH |
| `lib/balancing_chemical_equations/views/particles_node.dart` | L81 | Products | YES | title | `products` | （待定） | ENGLISH |
| `lib/balloons_and_static_electricity/view/balloons_static_electricity_screen.dart` | L22 | Balloons and Static Electricity | YES | strings_const | `balloonsAndStaticElectricity` | （待定） | ENGLISH |
| `lib/balloons_and_static_electricity/view/balloons_static_electricity_view.dart` | L132 | Yellow Balloon | YES | a11y | `yellowBalloon` | （待定） | ENGLISH |
| `lib/balloons_and_static_electricity/view/balloons_static_electricity_view.dart` | L146 | Green Balloon | YES | a11y | `greenBalloon` | （待定） | ENGLISH |
| `lib/balloons_and_static_electricity/view/base_view_layout.dart` | L49 | $_soundRoot/balloonGrab006.mp3 | YES | strings_const | `soundrootBalloongrab006Mp3` | （待定） | ENGLISH |
| `lib/balloons_and_static_electricity/view/base_view_layout.dart` | L50 | $_soundRoot/balloonRelease006.mp3 | YES | strings_const | `soundrootBalloonrelease006Mp3` | （待定） | ENGLISH |
| `lib/balloons_and_static_electricity/view/base_view_layout.dart` | L51 | $_soundRoot/balloonHitSweater.mp3 | YES | strings_const | `soundrootBalloonhitsweaterMp3` | （待定） | ENGLISH |
| `lib/balloons_and_static_electricity/view/base_view_layout.dart` | L52 | $_soundRoot/wallContact.mp3 | YES | strings_const | `soundrootWallcontactMp3` | （待定） | ENGLISH |
| `lib/balloons_and_static_electricity/view/base_view_layout.dart` | L53 | $_soundRoot/chargeDeflection.mp3 | YES | strings_const | `soundrootChargedeflectionMp3` | （待定） | ENGLISH |
| `lib/balloons_and_static_electricity/view/base_view_layout.dart` | L54 | $_soundRoot/carrier000.wav | YES | strings_const | `soundrootCarrier000Wav` | （待定） | ENGLISH |
| `lib/balloons_and_static_electricity/view/base_view_layout.dart` | L55 | $_soundRoot/carrier002.wav | YES | strings_const | `soundrootCarrier002Wav` | （待定） | ENGLISH |
| `lib/balloons_and_static_electricity/view/sweater_node.dart` | L47 | Sweater | YES | label | `sweater` | （待定） | ENGLISH |
| `lib/balloons_and_static_electricity/view/wall_node.dart` | L37 | Wall | YES | label | `wall` | （待定） | ENGLISH |
| `lib/beers_law_lab/model/beers_law_solution.dart` | L87 | Drink mix | YES | name | `drinkMix` | （待定） | ENGLISH |
| `lib/beers_law_lab/model/beers_law_solution.dart` | L101 | Cobalt(II) nitrate | YES | name | `cobaltIiNitrate` | （待定） | ENGLISH |
| `lib/beers_law_lab/model/beers_law_solution.dart` | L115 | Cobalt(II) chloride | YES | name | `cobaltIiChloride` | （待定） | ENGLISH |
| `lib/beers_law_lab/model/beers_law_solution.dart` | L129 | Potassium dichromate | YES | name | `potassiumDichromate` | （待定） | ENGLISH |
| `lib/beers_law_lab/model/beers_law_solution.dart` | L143 | Potassium chromate | YES | name | `potassiumChromate` | （待定） | ENGLISH |
| `lib/beers_law_lab/model/beers_law_solution.dart` | L157 | Nickel(II) chloride | YES | name | `nickelIiChloride` | （待定） | ENGLISH |
| `lib/beers_law_lab/model/beers_law_solution.dart` | L171 | Copper(II) sulfate | YES | name | `copperIiSulfate` | （待定） | ENGLISH |
| `lib/beers_law_lab/model/beers_law_solution.dart` | L185 | Potassium permanganate | YES | name | `potassiumPermanganate` | （待定） | ENGLISH |
| `lib/beers_law_lab/screens/beers_law_lab_home.dart` | L22 | Beer's Law Lab | YES | strings_const | `beerSLawLab` | （待定） | ENGLISH |
| `lib/beers_law_lab/screens/beers_law_lab_home.dart` | L23 | Concentration · Beer's Law | YES | strings_const | `concentrationBeerSLaw` | （待定） | ENGLISH |
| `lib/beers_law_lab/screens/beers_law_lab_home.dart` | L63 | Concentration | YES | label | `concentration` | （待定） | ENGLISH |

完整机器可读清单：`requirements/localization/_phase0_raw.json`

## 9. Recommended Implementation Batches

见本文件末尾与 PHASE 0 总结。原则：**基础设施 → Home → Simulation 批次**，禁止一轮爆改 200+ 文件。

### Batch 0 — Global infrastructure（不改 physics）

1. 新建 `lib/l10n/` + `KartosLocalization` 接口（或等价）
2. 落地 glossary keys → zh_CN（后续可加 en）
3. 建立 `allowedEnglishTerms` whitelist + `test/localization/` 扫描规则（EN 未豁免 = FAIL）
4. 文档：`LOCALIZATION_ARCHITECTURE.md`（PHASE 1）

### Batch 1 — Home + shared chrome

- `lib/screens/home_screen.dart` 全中文 displayName
- 统一 sim `title`/`subtitle` 显示层（保留 registry id 英文）
- L0：`KratosResetAllButton` tooltip、`time_control_bar`、公共 dialog
- Golden：Home 中文真值目录 `goldens_zh/`；英文基线归档 `golden_baseline_english/`

### Batch 2 — High-impact string bags（Top files）

- `som_strings`, `keplers_laws_strings`, `pm_strings`, `gfl_a11y_strings`, `pl_strings`
- `gao_strings`, `cck_strings`, `my_solar_system_strings`, `ba_strings`, `collision_lab_strings`
- `quantum_measurement_strings`, `mp_strings`, `density_strings`, `efac_strings`, `rs_strings`

### Batch 3 — Mechanics / Gravity / Vectors

- forces（补齐残留英文 Go!/Return）、collision-lab、vector-addition、projectile、pendulum
- gravity-force-lab / basics、hookes-law、masses-and-springs、balancing-act、friction

### Batch 4 — Fluids / Density / Buoyancy / Gas

- density、buoyancy、under-pressure、gases-intro、gas-properties、diffusion、membrane-transport

### Batch 5 — Circuits / EM / Electrostatics

- ohms-law、resistance-in-a-wire、cck-ac、capacitor、charges-and-fields、faradays-law
- john-travoltage、balloons、magnet-and-compass

### Batch 6 — Waves / Optics / Quantum

- bending-light、wave-on-a-string、waves-intro、normal-modes、fourier、color-vision
- quantum-measurement、quantum-wave-interference、quantum-coin-toss、sound、radio-waves

### Batch 7 — Chemistry

- molarity、ph-scale、acid-base、build-an-atom/nucleus/molecule、isotopes
- molecule-polarity/shapes、molecules-and-light、states-of-matter、BCE、RPAL、beers/concentration

### Batch 8 — Layout / Golden / Regression / Android

- 中文诱发 overflow / clipping / tab 碰撞修复（LayoutSpec，禁止 page magic Positioned）
- `goldens_zh/` + 行为回归全跑；READY 状态按 sim 重验

## 10. Hard-coded vs Strings-bag

- Hits inside `*strings*.dart`: **810**
- Hits outside strings bags (hard-coded UI / titles / tooltips…): **1531**
- 迁移时应：Widget 改消费 `loc.*`；禁止继续扩散「Widget 内直接中文硬编码」。

## 11. Font Audit (preview)

| Finding | Detail |
|---|---|
| App fallback | `main.dart` → Microsoft YaHei / PingFang SC / Noto Sans CJK SC / Arial |
| Bundled fonts in pubspec | **None**（fonts 段注释掉） |
| Sim hardcode | 大量 `fontFamily: 'Arial'`（QWI、Ohm、Molecule Polarity、Quantum Measurement…） |
| Risk | Arial 无中文 glyph → 依赖系统 fallback；baseline/字重可能偏移 → Layout Review 必需 |
| PHASE 0 action | 仅记录；不改字体实现 |

---

**PHASE 0 Status: AUDIT COMPLETE — NOT READY for user-facing Chinese release**

