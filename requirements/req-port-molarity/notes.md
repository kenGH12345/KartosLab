# Notes — req-port-molarity

## 已确认发现

1. **无 SimulationClock 需求**：molarity 是纯响应式 sim（无 tick/动画循环）· 所有 Derived 参数都是即时数学计算 · 不需要 `SimulationClock`。这与color-vision（光子运动需stepInTime）显著不同。（S2, S6, S7）

2. **KMnO₄ 粒子颜色例外**：9 种溶质中 8 种的粒子颜色 =溶液深色 · 唯一例外是 KMnO₄ 使用 Color.BLACK。蓝本通过不同构造函数实现此特例。Flutter 版须在Solute 数据中支持独立 particleColor 字段。（S1MolarityModel.java:49）

3. **浓度条的渐变 +灰段设计**：浓度条渐变从淡色到深色覆盖 0到饱和浓度区间 ·饱和浓度以上区域显示为灰色（表示"不可能到达"的浓度区间）。当溶质切换时灰段高度动态变化。（S8ConcentrationDisplayNode.java:108-113）

4. **粒子最少显示 1 个**：当 precipitateAmount > 0 但 particlesPerMole × precipitateAmount < 1 时，强制显示至少 1 个粒子。这是教学设计——确保"视觉上能看到饱和已经发生"。（S7 PrecipitateNode.java:115-116）

5. **蓝本无 WiggleMe**：与 color-vision 不同，molarity 蓝本未实现首次进入引导动画。Flutter 版可选择性添加。

6. **volume 最小值非零**：volume 范围为 0.2-1L（不含 0）。蓝本有 assert 验证 `SOLUTION_VOLUME_RANGE.getMin() > 0`——避免除以零。（S1 MolarityModel.java:31）

## 决策记录

| # | 决策 | 原因 | 日期 |
|---|---|---|---|
| D1 | 模块路径为 `lib/chemistry/molarity/` | 首个化学 sim · 建立 chemistry 分类 | 2026-08-10 |
| D2 | particlesPerMole(200)/particleSize(5) 归类为 🟡 代码常量+JSON可覆盖 | 性能调优需要 · 但教学一般无需修改 | 2026-08-10 |
| D3 | 不使用 SimulationClock | 纯数学计算 · 无时间演进 · 响应式 ChangeNotifier 足够 | 2026-08-10 |
| D4 | BeakerPainter 暂为 L1 候选不上抽 | 当前仅 1个用户 · 等 concentration / beer-law-lab 复刻时评估 | 2026-08-10 |

## 待确认项

| # | 问题 | 影响 | 状态 |
|---|---|---|---|
| T1 | [待技术确认] ScenarioManagerBase 公共层是否已就绪 · 若未就绪需先完成 P2 债务 | 影响 config 层实现顺序 | ✅ 已就绪 |
| T2 | [待技术确认] KratosSlider 是否支持垂直方向 · 蓝本滑块为垂直 | 影响 UI 实现 · 若不支持需扩展 | ✅ 已支持 vertical |

## 评审修复登记（2026-08-11 code-reviewer request_changes 后）

| # | 条目 | 内容 |
|---|---|---|
| D5 | CompactSlider 3-Time Rule | `compact_slider.dart` 为 sound `_compactSlider` 的**第 2 用户**（sound 第 1）· 已达上抽门槛 · **第 3 用户前必须上抽 `lib/common/controls/`** |
| D6 | ColorRange 用户数修正 | 方案 §6 称"color-vision 已有类似"**不实**（实测全 lib 无）· 实际第 1 用户 · L1 候选（beer-law-lab 等浓度系未来复用） |
| D7 | i18n 决策（AC-5.3 偏离记录） | 项目无 arb 体系（全 sim 中文硬编码）· molarity 对齐现状 · AC-5.3「UI 标签进 .arb」**未实现** · 记录为项目现状偏差 |
| D8 | 布局偏离方案 | 方案 §5 左格垂直 KratosSlider → 实现右格控制面板**水平 CompactSlider**（NineGrid 边格 ~65px 放不下垂直滑块 trackLength）· R3 风险实际落地 |
| D9 | 评审 M1 修正 | Cobalt chloride `#006A6A`(墨绿) → `#FF6A6A`(RGB 255,106,106 暗红) · 蓝本 `MolarityModel.java:43` 0xFF6A6A · 化学正确（CoCl₂ 溶液粉红） |
| D10 | 防御性修复（评审 m4/m5） | solutionColor sat≤0 → 取 maxColor（防除零）· controller setVolume/setSoluteAmount clamp 物理范围 |

**评审遗留 Suggestion（记录取舍）**：s1 MolarityState 非 ChangeNotifier（两层通知模型不统一 · screen setState 兜底）· s2 golden test 未实现 · s3 `_fallbackSolute` 内联 JSON 与 default.json 重复（极端降级路径 · 可接受）。

## 收尾经验沉淀（2026-08-11 closer）

- **AC 计数偏差 22 vs 29**：早期记录（process.txt:7）称"AC 清单 5 组 22 条"，实际按需求简述逐条清点为 **29 条**（AC-1.x 7 / AC-2.x 6 / AC-3.x 6 / AC-4.x 5 / AC-5.x 5）。教训：收尾核对 AC 时**以需求简述逐条 + ac-verification.md 实证为准**，不采信 process.txt 里的汇总数字；此类"组数正确但条数口误"易在需求中期口头流转中产生。
- **closing 门禁脚本在本仓不存在**：`.workflow/scripts/auto-extract-failures.{sh,ps1}` 与 `check-before-done.ps1` 均缺失（先例 req-inquiry-chart-extend 已记过同样结论）。教训：closing 门禁**必须人工核对**（final_summary_path 非空 + spec/最终需求.md 存在 + process.txt 含 closer 日志 + 证据链存在），不可依赖缺失脚本；此缺陷建议立项修复脚本基础设施。
- **对后续化学 sim 的提示**：①BeakerPainter / ColorRange / VerticalGradientBar 为 L1 候选，concentration / beer-law-lab 复刻时应评估上抽公共层（D4/D6）；②CompactSlider 已达 3-Time Rule 上抽门槛（D5），第 3 用户前必须上抽；③化学 sim 的"溶质颜色"须按真实化学核对（本需求 CoCl₂ 曾误用墨绿，实为粉红，D9）——化学正确性优先于视觉惯例。
