# PHASE_6 — Home Source Map

日期：2026-09-22

## Current Home implementation

| 项目 | 当前 Home 实现 |
|---|---|
| Home root | `lib/screens/home_screen.dart` → `HomeScreen`；`main.dart` 的 `MaterialApp(home:)` |
| Chemical category | `_Discipline(name: '化学', englishName: 'Chemistry')` |
| Simulation registration | 硬编码 `_SubjectGroup` → `_SimEntry(title, subtitle, icon, color, builder)` |
| Entry widget | `Navigator.push(MaterialPageRoute(builder: sim.builder))` → `*Home` |
| Navigation | 单层 push；`KratosTabbedScreen` AppBar Back → pop |
| Back mechanism | Flutter `BackButton` / AppBar leading（与其它 sim 一致） |
| Lifecycle | pop 销毁整个 `*Home` 子树；再进 `builder` 新建实例 |
| Assets registration | Home **卡片**用 `IconData`；sim 内 PNG 在 `pubspec` / `RpalAssets` |

## Multi-screen pattern（SoT）

```text
HomeScreen card
  → *Home (KratosTabbedScreen)
      → Tab children = existing Screen widgets
```

对照：`MoleculeShapesHome`、`PlinkoProbabilityHome`。

## RPL placement decision

- 一级：**化学**（已有，禁止新建学科）
- 二级：现有子分类均不覆盖 stoichiometry（溶液 / 原子核 / 分子搭建 / 形状 / 极性 / 光与分子 / 物态）
- 因此沿用项目已有模式：**一 sim 一 `_SubjectGroup`**（同 `分子形状` / `分子极性` / `光与分子`）
- 分组名：**`反应物与生成物`**（产品主题名，**不是**「化学反应 / 化学实验」等化学同义分类）
- 禁止新建：化学反应 / 化学实验 / 反应实验

## RPL entry plan

| 角色 | 名称 |
|---|---|
| Home | `ReactantsProductsAndLeftoversHome` |
| Tabs | Sandwiches → Molecules → Game（PhET 顺序） |
| Screens | 复用 Phase 1–5 的 `SandwichesScreen` / `MoleculesScreen` / `GameScreen` |
| Controllers | Home 持有并 dispose（Plinko 模式） |
| Card icon | Material `Icons.restaurant_outlined`（与其它化学卡一致，不伪造 sim 内 asset） |
| Accent | `RpalColors.statusBarFill` `#3376C4` |
