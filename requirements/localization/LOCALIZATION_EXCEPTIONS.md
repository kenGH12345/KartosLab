# LOCALIZATION_EXCEPTIONS

> PHASE 0 · 2026-10-08
>
> 明确列出**允许保留英文**的类别与理由。Whitelist 必须显式登记；禁止为了过检测而批量塞入。

## 1. Allowed categories (product rule §7)

| Category | Examples | Why allowed |
|---|---|---|
| Code identifiers | `BuoyancyModel`, `QuantumMeasurement` | 非用户可见自然语言 |
| File / package names | `lib/bending_light/` | 工程标识 |
| Registry / route IDs | `bending-light`, `ohms-law` | 稳定 ID，禁止改名 |
| Git / debug / logs | `print('debug...')` | 开发者专用 |
| PhET source archaeology | `phet/`、原始 properties/JS | 证据链，禁止改成中文 |
| Scientific symbols / units | `kg`, `m³`, `Pa`, `N`, `°C`, `A`, `V`, `ρ`, `F=ma` | 非自然语言 |
| Brand / proper tech names | `PhET`（致谢对话框等必要时） | 品牌保留；UI 正文仍应中文说明 |

## 2. Provisional `allowedEnglishTerms` (PHASE 0 draft)

| Term | Scope | Justification | Review |
|---|---|---|---|
| `PhET` | about/credits | 品牌名 | keep |
| `KartosLab` / `Kratos` | about/title | 产品名 | keep |
| `pH` | chemistry UI | 国际通用科学符号 | keep |
| `RGB` | color-vision technical label | 通道缩写；旁注可用「红绿蓝」 | review in Batch 6 |
| `N-body` | astronomy subtitle | 专业缩写；建议改为「多体」 | prefer translate |
| `χ²` | curve-fitting | 统计符号 | keep |
| `VSEPR` | molecule-shapes | 理论缩写；可旁注中文全称 | review |
| `Planck` / `Wien` | blackbody subtitle | 科学家姓氏 | keep as proper nouns |
| `OK` | dialogs | 可译「确定」；若保留须登记 | prefer translate |
| `Go!` | forces net-force | 应译「开始!」 | **not allowed long-term** |

## 3. Explicitly NOT exceptions

以下**不得**因「太多英文」而加入 whitelist：

- Simulation 显示名（`Bending Light`、`Pendulum Lab`…）
- 控制面板标签（`Mass`、`Gravity`、`Density`…）
- Tab 名（`Intro`、`Lab`、`Explore`…）
- `Reset All` / tooltips / semantic labels
- 游戏提示（`Try Again`、`Show Answer`）
- Home 上的 `Physics` / `Chemistry` englishName（应隐藏或改为可选）

## 4. Source-only strings

- `phet/` 与 archaeology 目录内英文：**Source-only**，不计入用户可见 FAIL。
- requirements / docs / test 描述性英文：非运行时 UI；localization FAIL 规则仅针对 `lib/` 用户路径（测试另建 `test/localization`）。

## 5. Font substitution (related exception)

- 原版语义字体常为 Arial/Helvetica；无中文 glyph 时允许系统 CJK fallback。
- 必须在后续 `LOCALIZATION_REPORT` 记录 Font substitution，并用 Golden/Android 验证。
- PHASE 0 不改字体实现。

---

## 6. PHASE 1 allowlist implementation

Runtime classifier: `lib/l10n/scan/english_residue_classifier.dart`

Scoped FAIL (must be Chinese): Home + shared chrome files listed in
`test/localization/english_residue_scan_test.dart`.

Simulation interiors remain English until their batch — classified as
**NOT STARTED**, not as silent whitelist.

---

PHASE 1：Exceptions 已接入扫描器；每增 whitelist 条目必须附理由。

