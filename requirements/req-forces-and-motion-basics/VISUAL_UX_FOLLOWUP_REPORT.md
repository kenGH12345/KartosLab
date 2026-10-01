========================================
FORCES AND MOTION: BASICS
VISUAL / UX FOLLOW-UP REPORT
========================================

Date:
2026-09-24

Scope:
Home Integration gate 之后的 Motion / Friction / Acceleration 观感与操作跟进。
不重开 MODEL 物理；不宣称 READY（Android Runtime 仍未验证）。

----------------------------------------
Issues closed
----------------------------------------

1. Toolbox clip / margin
   [布局已对齐]
   工具箱物品按 PhET home（left/top）+ imageScale × homeScale 摆放，
   Stack clipBehavior = none，避免左边物品被裁切或被过大 margin 挤开。

2. Drag hit-target（点左拖右）
   [行为一致]
   去掉会在 setState 中途 dispose 的 GestureDetector。
   堆叠拾取用固定 Listener + 几何命中（从上到下 hit-test）；
   全屏 Listener 跟手 move/up，避免按下后手势目标丢失导致“点的是左边、拖的是右边”。

3. People sit on crates
   [原版资源一致]
   人在堆上使用 sitting SVG（上层用 holding）；尺寸用 sitting intrinsic。
   堆叠从地面/滑板向上累加高度，坐在箱子上而不是站在旁边。

4. Screen fill
   [布局已对齐]
   MotionScreenV2 用 SizedBox.expand + FittedBox BoxFit.fill 铺满 tab 内容区，
   不再 letterbox 留边。

5. Tab switch flash
   [布局已对齐]
   KratosTabSwitcher：去掉 0.985 AnimatedScale；旧页保持不透明垫底，
   新页叠上 373ms easeOutCubic 淡入。过渡结束再关掉旧页 TickerMode。
   子页仍全部挂载，切回不丢仿真状态。

----------------------------------------
Core Tests:
NOT RE-RUN this follow-up (prior gate 62 / 62 PASS)

Analyze:
kratos_tab_bar.dart — no lints on this edit

P0:
0 (open)

P1:
0 (open)

Visual QA (this follow-up):
PASS — toolbox / sit / fill / drag / tab fade
判定：
  [原版资源一致] sitting/holding assets
  [布局已对齐] toolbox homes, fill layout, tab overlay fade
  [动态绘制已对齐] stack sit poses + Listener drag

Behavioral Acceptance:
unchanged (model isolation still PASS from prior gate)

Cross-Screen Regression:
unchanged from prior gate

Home Integration:
unchanged wiring (ForcesHome 四 tab)

Android Runtime:
NOT VERIFIED

----------------------------------------
Files
----------------------------------------
- lib/forces/screens/motion_screen_v2.dart
- lib/forces/model/motion_model.dart (homes / sit / hold)
- lib/common/widgets/kratos_tab_bar.dart  ← 全局 Tab 过渡

Note:
KratosTabSwitcher 是 L0。所有使用它的 sim（Forces 及其他 tabbed home）
都会拿到同一套无闪交叉淡入。非当前页仍 TickerMode 关闭（过渡中旧页短暂保持）。

----------------------------------------
Final Status:
READY CANDIDATE
(prior Home Integration gate + this visual/UX follow-up)

Remaining Limitations:
- Android Runtime not verified
- P2 chrome residuals still frozen (slider / brick grit / water / mountains / Go color)
- Legacy unused stubs under lib/forces still unwired
- Tab fade is overlay-in (not dual-fade); duration still 373ms
- BoxFit.fill 会轻微非等比拉伸以铺满；相对 letterbox 是刻意取舍
