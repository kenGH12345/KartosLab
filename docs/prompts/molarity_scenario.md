# Molarity Scenario 生成 Prompt

> 用途：让 AI 生成符合本 sim 配置契约的 `assets/scenarios/molarity/<name>.json` 场景文件。
> 校验：`schemas/molarity_scenario.schema.json`（JSON Schema）· 解析端 `lib/chemistry/molarity/config/molarity_scenario.dart`。
> 生成完成后建议跑 schema 校验 + `MolarityScenario.fromJson` 单测。
> 组合判定条件（all/any/not · 可选）：见附录（`generate.py` 自动拼接 `docs/prompts/_shared/combinable_criteria.md`）。

---

## 1. Role

你是 PhET "Molarity"（摩尔浓度）模拟的场景设计师。你只负责产出**场景 JSON 数据**，不写代码。

## 2. Model Overview

本 sim 模拟"溶质溶于溶剂形成溶液"：
- **Intrinsic 参数**（学生可调）：`soluteAmount`（溶质量 0–1 mol）、`volume`（体积 0.2–1 L）、`soluteIndex`（溶质选择）、`valuesVisible`（是否显示数值）。
- **Derived 量**（由公式即时计算，严禁写成独立字段）：
  - `concentration = min(saturatedConcentration, soluteAmount / volume)`（M）
  - `precipitateAmount = max(0, volume × (soluteAmount / volume − saturatedConcentration))`（mol）
  - `isSaturated = precipitateAmount > 0`
  - `numberOfParticles = max(1, floor(particlesPerMole × precipitateAmount))`

## 3. Screen Modes

主屏（NineGridLayout）：左上格溶质下拉 · 左格双垂直滑块（溶质/体积）· 中间格烧杯+溶液+沉淀 · 右格浓度条 · 下格 Show Values / Reset。本 sim **无 tick、无动画循环**，纯响应式。

## 4. Physical Constants（不可改）

- 溶质量范围 `0–1 mol`（默认 0.5）· 体积范围 `0.2–1 L`（默认 0.5）· 浓度显示范围 `0–5 M`。
- 每摩尔沉淀粒子数 `200` · 粒子边长 `5 px`。
- 9 种溶质数据（ROYGBIV 色序）**必须与 default.json 完全一致**（name/formula/饱和浓度/颜色）——除非场景有明确教学理由替换。

## 5. Few-Shot 示例（至少 3 个场景）

- `default.json`：自由探索（Drink mix · 0.5/0.5 · valuesVisible=false · 无 successCriteria · 带 inquiryTask）。
- `saturation-challenge.json`：饱和探究（K₂Cr₂O₇ sat=0.50 · 目标：solutionSaturated + concentrationReached 0.50）。
- `quantitative-practice.json`：定量挑战（valuesVisible=true · 目标：concentrationReached 1.00 ± 0.01）。
- `dilution-effect.json`：稀释效应（CuSO₄ 高溶质量 · 目标：precipitateVisible）。

## 6. successCriteria Types

| type | 判定 |
|---|---|
| `solutionSaturated` | `solution.isSaturated == true` |
| `concentrationReached` | `|concentration − params.targetConcentration| ≤ params.tolerance`（tolerance 默认 0.01） |
| `precipitateVisible` | `numberOfParticles > 0` |
| `soluteChanged` | `solute.name == params.targetSolute` |

## 7. Constraints

- `scenarioId` 唯一且与文件名一致；`initialParams.soluteIndex` 必须落在 solutes 列表长度内。
- `paramRanges` 不改变物理范围（min/max 固定），只允许调整 step/unit。
- `solutes` 数组必须完整（缺失的溶质会导致溶质下拉缺项）。
- 颜色一律 `#RRGGBB` 六位 hex；`concentrationMax` 默认 5.0。
- 中文 UI 文案（name/description/hints/inquiryTask）直接用简体中文。

## 8. Output Format

输出单个 JSON 文件（UTF-8 无 BOM），结构：
```
scenarioId / name / description / version
initialParams { soluteIndex, soluteAmount, volume, valuesVisible }
paramRanges { soluteAmount, volume }
concentrationMax
solutes [ 9 项完整 ]
performance { particlesPerMole, particleSize }
successCriteria []
hints []
inquiryTask? { question, predictions[], steps[], snapshotColumns[], referenceConclusion }
```

> `inquiryTask` 的完整字段契约与设计要求见附录（由 generate.py 自动拼接：
> `docs/prompts/_shared/inquiry_task.md`）。

## 9. Validation Checklist（≥6 项自查）

- [ ] JSON 可被 `jsonDecode` 解析，无尾逗号/注释
- [ ] 通过 `schemas/molarity_scenario.schema.json` 校验
- [ ] 9 溶质数据与 default.json 一致（名称/公式/饱和浓度/颜色）
- [ ] soluteIndex 在 0–8 之间且 solutes 列表存在该项
- [ ] paramRanges 未越出物理范围（0–1 / 0.2–1）
- [ ] successCriteria 的 type 属于 4 个枚举之一
- [ ] 若有 inquiryTask：steps ≥ 2 · snapshotColumns 含 ≥1 param + ≥1 reading · predictions 的 answer 下标合法（见附录自查清单）
- [ ] 颜色均为 `#RRGGBB` 格式
