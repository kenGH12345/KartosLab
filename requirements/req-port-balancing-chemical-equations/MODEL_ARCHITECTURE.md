# MODEL_ARCHITECTURE — Balancing Chemical Equations

> **req-id**: `req-port-balancing-chemical-equations`  
> **性质**: Phase 0 **提案 only** — 不在本阶段创建 Flutter 业务代码  
> **日期**: 2026-09-23

---

## 1. 设计原则

1. **Source-truth**：`Equation.isBalanced` / `isSimplified` 算法一字不差迁移（见 `doc/model.md`）。  
2. **禁止假配平**：禁止「对比预设答案数组」；Game Check 必须走 `isSimplified`。  
3. **L0 复用**：Reset All → `KratosResetAllButton`；通用控件优先 `lib/common/`。  
4. **三屏共享**：Chemistry + Visualizations 在 `common`；Game 独有状态机。  
5. **Molecule 非 String**：`Molecule` + `Atom[]` + nitroglycerin 几何。

---

## 2. 建议目录

```text
lib/balancing_chemical_equations/
  balancing_chemical_equations.dart          # barrel / route entry
  bce_constants.dart                         # LAYOUT 768x504, scales, colors
  bce_colors.dart
  model/
    atom_count.dart
    equation.dart
    equation_term.dart
    molecule.dart                            # static catalogue
    view_mode.dart
    bce_preferences.dart                     # initialCoefficient 0|1
  data/
    intro_equations.dart
    equations_datasets.dart                  # synthesis / decomposition / combustion
  game/
    game_state.dart
    game_model.dart
    game_level.dart
    game_level_1.dart / _2.dart / _3.dart
    equation_pool.dart
    equation_pool_1.dart / _2.dart / _3.dart
  views/
    equation_node.dart
    equation_term_node.dart
    coefficient_picker.dart
    particles_node.dart
    particles_accordion_box.dart
    balance_scales_node.dart
    balance_scale_node.dart
    bar_charts_node.dart
    bar_node.dart
    right_arrow_node.dart
    view_combo_box.dart
    horizontal_aligner.dart
    horizontal_bar_node.dart
  screens/
    intro/
      intro_model.dart
      intro_screen.dart
      intro_view_properties.dart
      intro_feedback_node.dart
      equation_radio_button_group.dart
    equations/
      equations_model.dart
      equations_screen.dart
      equations_view_properties.dart
      equations_feedback_node.dart
      reaction_type_radio_button_group.dart
      equations_combo_box.dart
    game/
      game_screen.dart
      game_screen_view.dart
      level_selection_node.dart
      level_node.dart
      game_feedback_node.dart
      not_balanced_panel.dart
      balanced_and_simplified_panel.dart
      balanced_not_simplified_panel.dart
      bce_finite_status_bar.dart
      bce_reward_node.dart
      bce_level_completed_node.dart
  widgets/
    # thin shared chrome if needed
```

可选：`nitroglycerin` 等价层放在 `lib/common/nitroglycerin/`（若多 sim 复用）或本模块 `chemistry/`。

---

## 3. 核心模型映射

| PhET | Flutter | Notes |
|------|---------|-------|
| `Equation` | `Equation` + `ValueNotifier`/`Listenable` | `isBalanced` / `isSimplified` Derived |
| `EquationTerm.coefficientProperty` | `ValueNotifier<int>` + Range | Integer clamp |
| `Molecule.*` | `Molecule` enum/catalog | `createPainter()` |
| `AtomCount.countAtoms` | `AtomCount.countAtoms` | Visualization only |
| `ViewMode` | `enum ViewMode` | Mutual exclusive |
| `GameState` | `enum GameState` | Valid transition assert |
| `GameTimer` (vegas) | Timer service | start/stop/reset/elapsed |
| `IntroModel.choices` | Fixed list of 3 | Default index 0 |
| `EquationsModel.reactionType` | enum + 3 equation lists | Per-type selection Property |
| `EquationPool.getEquations(n)` | Pool with exclusions | Use seeded Random for tests |

---

## 4. Balance 算法（必须原样）

```dart
// Pseudocode — mirror Equation.ts
bool get isBalanced {
  final m = reactants.first.coefficient / reactants.first.balancedCoefficient;
  return terms.every((t) =>
      t.coefficient != 0 && t.coefficient == m * t.balancedCoefficient);
}

bool get isSimplified =>
    terms.every((t) => t.coefficient == t.balancedCoefficient);
```

`balance()`：把每个 term 的 user coeff 设为 `balancedCoefficient`（Show Answer / Next 路径）。

---

## 5. 系数范围

| Screen | Range |
|--------|-------|
| Intro | 0…3 |
| Equations | 0…6 |
| Game | 0…7 |

Initial：Preferences / query `initialCoefficient` ∈ {0, 1}，默认 **1**。

---

## 6. 可视化绑定

```text
coefficientProperty.change
    → ParticlesAccordionBox.update visibility/count
    → BalanceElementsNode.updateCounts → Scales / Bars
    → RightArrowNode highlight (if isBalanced && enabled)
```

Game 在 Check 前 `setBalancedHighlightEnabled(false)`；进入 `next` 后 true。

---

## 7. Screen 职责

### Intro

- 3 固定方程 radio  
- View combo + Particles accordions  
- Feedback：仅 `isBalanced` → face + “Balanced”  
- Reset All

### Equations

- ReactionType radio + per-type ComboBox  
- Feedback：`isBalanced` 时显示 Simplified / Not Simplified  
- Reset All

### Game

- Level selection（Timer toggle、Stars、Reset All）  
- Challenge play（Particles only；无 View combo）  
- Status bar（score、challenge #、timer、Start Over）  
- Feedback 三态 + Show Why  
- Level complete + optional Reward

---

## 8. 测试切分建议

| Layer | Tests |
|-------|-------|
| Unit | Balance / Simplified / AtomCount / Pool exclusions / Scoring |
| Widget | CoefficientPicker bounds / ViewMode exclusivity |
| Golden | Particles / Scales / Bars / Equation layout @ 768×504 |
| Integration | Game state machine + Start Over vs Reset All |

---

## 9. 非目标（Phase 0）

- 不创建上述 Flutter 文件  
- 不改 Home  
- 不实现简化版 Game  
- 不宣布 READY
