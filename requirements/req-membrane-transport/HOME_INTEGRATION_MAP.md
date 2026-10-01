# Membrane Transport · HOME_INTEGRATION_MAP

> PHASE 8 · Formal KartosLab Home entry  
> 审计对象：`lib/screens/home_screen.dart` + 现有 `_SimEntry` / `_Discipline` / `_SubjectGroup`

---

## 1. Home Architecture

| 角色 | 实现 | 说明 |
|------|------|------|
| Home Screen | `HomeScreen` (`lib/screens/home_screen.dart`) | `MaterialApp.home`（`lib/main.dart`） |
| Category（一级） | `_Discipline` | 现有仅 **物理** / **化学**（无「生物」） |
| Category（二级） | `_SubjectGroup` | 学科下分组，如「热学与气体」 |
| Simulation Entry | `_SimEntry` | title / subtitle / icon / `iconAsset?` / color / `builder` |
| Card | `_SimCard` | 统一 88h 卡片；`Semantics(button, label: title)` + `InkWell` 整卡可点 |
| Route | `Navigator.push(MaterialPageRoute(builder: sim.builder))` | 无独立 route enum / registry 文件 |
| Icon | Material `IconData` **或** 原版 `iconAsset`（SVG/PNG） | SVG 走 `SvgPicture.asset` |
| Back | AppBar 默认 `BackButton` → `Navigator.pop` | 回到 `HomeScreen` |
| Android | 同一 `HomeScreen` + 系统 Back | 与桌面同一导航栈 |

**不新建**：Navigator / HomeCard / Category System / Route System / Home Layout。

---

## 2. Category Decision

| 候选 | 结论 |
|------|------|
| 新建「生物 / 细胞膜运输」 | **否** — Home 无生物一级学科；禁止为本 sim 发明新分类体系 |
| 化学 · 溶液与浓度 | 弱相关（浓度主题） |
| 物理 · 热学与气体 | **采用** — 已有 **Diffusion**（粒子扩散）；Membrane Transport 为跨膜扩散 / 主动运输，主题最近 |

**最终**：

```text
物理 (Physics)
  └─ 热学与气体
       ├─ Diffusion
       ├─ Membrane Transport   ← 本阶段新增（排在 Diffusion 之后）
       ├─ Gases Intro
       ├─ Gas Properties
       ├─ Blackbody Spectrum
       └─ Energy Forms and Changes
```

Ordering：遵循组内既有顺序，仅在 Diffusion 后追加一条，不置顶。

---

## 3. Simulation Entry（本阶段）

| 字段 | 值 |
|------|-----|
| title | `Membrane Transport`（正式英文名，不改写） |
| subtitle | `Simple · Facilitated · Active · Playground` |
| icon（fallback） | `Icons.blur_on_rounded`（仅无 asset 时；实际用原版 SVG） |
| iconAsset | `MembraneTransportAssets.simpleDiffusionHome` = `assets/simulations/membrane_transport/images/simple_diffusion_home_icon.svg` |
| color | `MembraneTransportHome.accentColor` `#0288D1` |
| builder | `(_) => const MembraneTransportHome()` |

**唯一正式入口**：仅此 `_SimEntry`。`debug_membrane_transport_main.dart` 仍仅供开发，不出现在 Home。

---

## 4. Formal Route / Entry

```text
HomeScreen
  → tap Membrane Transport card
  → MaterialPageRoute → MembraneTransportHome
       → KratosTabbedScreen
            · Simple Diffusion
            · Facilitated Diffusion
            · Active Transport
            · Playground
```

- Tab 不是独立 route（与现有 `KratosTabbedScreen` 语义一致）。
- Back：离开整条 sim route → Home（非 Launcher）。
- Entry lifecycle：每次 push 新建 `MembraneTransportHome` → 各 tab 新建 `MembraneTransportScreenBody` / model / ticker（source：per-screen-independent；无跨次 session 持久化）。

---

## 5. Icon Provenance

| Item | Path |
|------|------|
| Original | `phet sourses/.../images/simple_diffusion_home_icon.svg` |
| Flutter | `assets/simulations/membrane_transport/images/simple_diffusion_home_icon.svg` |
| Used by | Home `_SimCard.iconAsset` via `MembraneTransportHome.homeIconAsset` |
| Status | **Original**（非重绘） |

另有四屏 `*_home_icon.svg` / `*_nav_icon.svg`（tabs 已用 nav）；Home 卡片选用 **Simple Diffusion** 屏 home icon（与 PhET 首屏一致）。

---

## 6. Back / Re-entry / Lifecycle

| 场景 | 期望 |
|------|------|
| Home → MT → Back | `HomeScreen`；MT route disposed |
| MT → Tab B → Back | 仍 pop 整条 sim（Tab 非 route） |
| Re-entry | 新 route / 新 model；source-defined initial state |
| After Back | ScreenBody `dispose` → ticker stop + `model.dispose()` |

---

## 7. Android Behavior

与桌面相同栈：`flutter run` 正式 `main.dart` → Home → Card → MT → Back → Home。

---

## 8. Non-goals（本阶段）

- 不改 Membrane / Particle / Transport / Drag / LayoutComposer / Golden states
- 不接 PHASE 9 Final QA 宣布 FINAL READY
