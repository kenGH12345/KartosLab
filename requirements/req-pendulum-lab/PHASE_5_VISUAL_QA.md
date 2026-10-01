# PHASE 5 — Visual QA

Status: **MATRIX CAPTURED + FIRST DIFF DONE** (2026-09-14)

## Pipeline（Capture → Manifest → Diff → Analysis，各司其职）

| 环节 | 工具 | 说明 |
|---|---|---|
| ORIGINAL capture | `tool/capture_pendulum_original.js` | Playwright + phet.colorado.edu 最新发布版（本地 1.1.0-dev.5 未构建、缺依赖仓库，不可直接运行） |
| ORIGINAL smoke | `tool/capture_pendulum_smoke.js` | 单张 Intro initial，带完整 ready 链 |
| FLUTTER capture | `test/pendulum_lab/pendulum_visual_qa_capture_test.dart` | widget 测试 + `RepaintBoundary.toImage`，同步写盘；per-test 15s 超时为**设计内行为**（FakeAsync 在 toImage 后无法完成收尾 pump，PNG 先于超时落盘，exit≠0 不代表失败） |
| Manifest + Diff | `tool/build_visual_manifest.py` → `manifest.json` | 配对 18 状态并逐对生成 DIFF |
| Diff 单元 | `tool/diff_visual_qa.py` | PIL 像素差 + 热力图 |
| 汇总 | `tool/summarize_visual_diffs.py` | 按 delta>32% 排序 |

## 之前失败的根因（已修复）

1. **ORIGINAL 等 `canvas` 出现**：该发布版渲染器为 SVG（`svg:3, canvas:0`），`waitForSelector('canvas')` 永远无法满足 → 120s 卡死假象 → 被当作 stale 手动杀掉。
2. **joist API 路径错误**：此版本是 `sim.currentScreenProperty`（非 `selectedScreenProperty`），无 `simulationTimeProperty`（用 `phet.joist.elapsedTime`）；`model()` 取不到模型 → evaluate 抛错 exit 1。
3. **模型属性路径错误**：`m.periodTrace.isVisibleProperty` 实为 `m.isPeriodTraceVisibleProperty`；秒表/尺子路径为 `m.stopwatch.isVisibleProperty` / `m.ruler.isVisibleProperty`（已经 `tool/probe_pendulum_sim.js`、`tool/probe_pendulum_models.js` 实测确认）。
4. **FLUTTER 矩阵被误杀**：by-design 的 30s/个超时使 18 个状态需 ~9 分钟，外观像挂起，多次在 ~2.5 min 被杀 → 只产出 01–05。已将 per-test 超时缩至 15s（PNG 同步写盘先于超时，缩短无风险），全程 ~4.5 min。
5. **直接调 flutter 缺环境变量**：`%PROGRAMFILES(X86)% not found` → 秒退 exit 1；需 `set "ProgramFiles(x86)=..."`（各 bat 已有）或在 PowerShell 中 `${env:ProgramFiles(x86)}=...`；cmd 的 `set && ...` 语法在 PowerShell 后台任务中同样会解析失败。

## 截图矩阵（18 状态 × 双端 + 18 DIFF + manifest.json）

```
visual-qa/
├── ORIGINAL/  01–18 + smoke_test（.png + .meta.txt）
├── FLUTTER/   01–18 + smoke_test（.png + .meta.txt）
├── DIFF/      01–18_diff.png + smoke_test_diff.png
└── manifest.json
```

viewport 1280×800、DPR 1 两端固定；ORIGINAL 含 PhET 导航栏，FLUTTER 为 KartosLab shell（FittedBox 1024×618 居中），chrome 差异属预期基线。

## 第一轮 Diff 结果（按 delta>32% 降序）

| state | mean_abs | changed% | d>32% |
|---|---|---|---|
| 04_Intro_modified | 35.9 | 27.8 | 20.5 |
| 09_Energy_pendulum2 | 35.9 | 28.4 | 18.0 |
| 17_Lab_period_timer | 35.8 | 28.4 | 17.8 |
| 03_Intro_paused | 30.2 | 22.8 | 16.9 |
| 08_Energy_paused | 33.8 | 25.5 | 16.9 |
| 02_Intro_running | 30.1 | 22.7 | 16.9 |
| 07_Energy_running | 33.7 | 25.4 | 16.8 |
| 14_Lab_modified | 33.7 | 25.7 | 16.4 |
| 01_Intro_initial / 05_Intro_reset | 29.4 | 22.4 | 16.4 |
| 16_Lab_released | 33.2 | 26.1 | 15.8 |
| 15_Lab_dragged | 33.2 | 26.0 | 15.8 |
| 06_Energy_initial / 10_Energy_reset | 31.1 | 24.1 | 15.2 |
| 13_Lab_paused | 31.2 | 23.1 | 15.0 |
| 12_Lab_running | 31.0 | 23.0 | 14.8 |
| 11_Lab_initial / 18_Lab_reset | 30.4 | 22.7 | 14.5 |

解读：
- 基线 ~15–16% 为大面板/chrome 系统性差异（双方外壳不同），属预期。
- **差异最大三态恰为工具可见态：04（秒表+周期迹）、09（能量框）、17（周期计时器）** —— 与 P1 项（Stopwatch chrome、Energy bar polish）互相印证，下一轮 chrome 对齐以这三张 diff 热力图为依据。
- Reset 对称性双端成立：01=05、06=10、11=18（FLUTTER 侧字节级一致；ORIGINAL 侧统计一致）。

## 回归

- `dart analyze lib\pendulum_lab test\pendulum_lab`：No issues found
- 门控测试（physics + interaction + widget）：All tests passed（31 个）

## 下一步（按 diff 热力图驱动）

1. ~~对照 `DIFF/04_Intro_modified_diff.png` 修 StopwatchNode chrome（P1）~~ ✅
2. ~~对照 `DIFF/09_…` / `DIFF/17_…` 修 Energy bar / Period Timer chrome（P1）~~ ✅
3. NumberControl 微调（P2）
4. ~~浏览器交叉验证拖拽 / 周期计时 / 能量（M3 遗留）~~ ✅
5. ~~重跑 Final Gate~~ ✅

---

# M4.5 Visual Closure（2026-09-14 第二轮）

## Chrome 精修（04 / 09 / 17 三态驱动）

- **Stopwatch**：按 `scenery-phet/StopwatchNode.ts` 重建——浅灰显示边框（0xFFD3D3D3）、图标高度 10、按钮高 20、`PlShadedRectangle` 显式 shades（实测原版边缘色）；`DraggableStopwatch.nodeSize` 校正为 98×72。
- **Energy bar**：`EnergyGraphAccordion` 重写为原版的动态填充布局（Expanded 占满剩余高度，折叠时收缩为标题行）；宽度 170→160；`_EnergyBarsPainter` 重写——Total 堆叠条、Thermal 用垃圾桶图标作标签、移除原版不存在的隐含网格线/轴标签。
- **Period Timer**：capture 漏 `setVisible(true)`（源码 `setRunning` 在不可见时强制回落 false）已修；读数 0.4026 s 与 ORIGINAL 一致。

## 字体根因（本轮最重要发现）

widget 测试环境中 `fontFamily: 'Arial'` 落到 Ahem 回退字体（每字符 1em 宽），导致：
- 重力 NumberControl 显示框 142px 宽 → Row 溢出 13px（黑黄条纹画进截图）
- Period Timer 内容溢出 23px
- 所有文本宽度/布局与生产环境不符

修复：capture 测试 `setUpAll` 同时加载 `trebuc.ttf`（Trebuchet MS）与 `arial.ttf`（Arial）真实字体。溢出全部消除（17 号状态帧零异常）。

## 第二轮 Diff（全矩阵重截后，与第一轮对比）

| state | mean_abs（前→今） | d>32%（前→今） |
|---|---|---|
| 04_Intro_modified | 35.9 → **30.96** | 20.5 → **18.08** |
| 09_Energy_pendulum2 | 35.9 → **30.67** | 18.0 → **15.83** |
| 17_Lab_period_timer | 35.8 → **30.51** | 17.8 → **15.44** |
| 03_Intro_paused | 30.2 → 27.42 | 16.9 → 15.63 |
| 02_Intro_running | 30.1 → 27.23 | 16.9 → 15.51 |
| 01/05 Intro | 29.4 → 26.66 | 16.4 → 15.12 |
| 08_Energy_paused | 33.8 → 29.10 | 16.9 → 14.95 |
| 07_Energy_running | 33.7 → 29.01 | 16.8 → 14.88 |
| 14_Lab_modified | 33.7 → 28.35 | 16.4 → 13.98 |
| 16_Lab_released | 33.2 → 28.86 | 15.8 → 13.84 |
| 15_Lab_dragged | 33.2 → 28.52 | 15.8 → 13.61 |
| 06/10 Energy | 31.1 → 26.82 | 15.2 → 13.30 |
| 13_Lab_paused | 31.2 → 26.94 | 15.0 → 13.05 |
| 12_Lab_running | 31.0 → 26.85 | 14.8 → 12.96 |
| 11/18 Lab | 30.4 → 26.08 | 14.5 → 12.47 |

**18/18 状态全部下降**。残留差异构成：外壳基线（PhET 导航栏 vs KartosLab shell，坐标系缩放/偏移不同 → 右侧/底部控件边缘 ghost）+ 运行态时序（双端积分器逐帧累积差 → 摆球/能量条/周期迹 ghost）。三件套 chrome 区域在目视裁剪对比中已收敛。

## 浏览器交叉验证（真实鼠标操作，Playwright + 发布版 1.0.35）

工具：`tool/cross_validate_pendulum.js`（拖拽）、`tool/cross_validate_controls.js`（控件）。
交互定位策略：PDOM 在该发布版未启用（`?accessibility` 下 slider 无 label/bbox）→ 改用场景图遍历（`_inputListeners` + `globalBounds`）找候选，**试拖/试点分类**（观察哪个模型 Property 变化），再用真实 `page.mouse` 完成操作。MVT 为常量：`model(0,0)→view(512,15)`，scale 618/1.33，Y 翻转；view→screen 仿射运行时校准。

### Drag / Release（Intro，真实拖拽摆球）
| 用例 | 抓取 | 拖拽跟随 | 释放 | 后续振荡 |
|---|---|---|---|---|
| 15° | isUserControlled=true ✅ | θ=0.2618 rad 精确 ✅ | 解除控制 ✅ | ±0.25 rad 持续 ✅ |
| 60° | 同上 ✅ | θ=1.0472 rad 精确 ✅ | ✅ | ±1.0 rad 持续 ✅ |

### Energy（Energy 屏，真实滑块拖拽 + 摆球拖拽）
- 滑块试拖映射：mass(1173,176) / length(1176,84) / gravity(1141,287) / friction(1087,411)
- 拖至目标：mass→1.500 kg 精确；length→1.000 m 精确；gravity→1.5（量程 1% 容差内）
- 悬挂 PE 与理论 `m·g·L·(1−cosθ)` **逐位相等**（0.9200035522122594）
- 能量守恒：maxKE 0.91956 ≈ PE 0.92000（差 0.05%）
- 比例性：PE ∝ mass（×1.5000）、∝ length（×1.4286=1/0.7）、∝ gravity（×0.1019=1/9.81）✅

### Period Timer / Stopwatch（Lab 屏，真实点击）
- 复选框定位：Period Timer(91,705) / Stopwatch(91,678) / Ruler(91,650)
- Stopwatch：play → 1.5s 墙钟计时 1.7119s；pause → 读数冻结不变 ✅
- Period Timer：start → running；摆完一整周期（4 个迹点）**自动停止**；实测 **1.69127 s** vs 振幅修正理论 **1.69118 s**（误差 0.005%）✅

## 回归（第二轮后）

- `dart analyze lib\pendulum_lab test\pendulum_lab`：No issues found
- 门控测试：31 PASS / 0 FAIL
- Reset 对称性保持：01=05、06=10、11=18
