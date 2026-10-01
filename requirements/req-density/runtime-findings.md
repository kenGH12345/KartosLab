# Loop 8 Runtime Findings

> 2026-09-02 · Agent 验收 + 针对性修复

---

## 17.4 FAIL（840×520 Intro footer overflow）

**现象：** `RenderFlex overflowed` — IntroBlockPanel 内 KratosComboBox / KratosSlider 在 footer 高度 ~83px 内被压至 ~17px 交叉轴。

**预期：** 矮视口（840×520）三屏 footer 无黄黑溢出条。

**实际：** Intro footer `Column` + `Expanded` 水平 ListView 与底部 Row 争高，控件被压缩溢出。

**影响：** 小窗口/矮屏 Intro 控件不可读、不可点。

**证据：** `test/density/runtime_acceptance_test.dart` · `840x520 intro compare mystery`

**相关代码：** `lib/density/view/screens/introduction_screen.dart` · `_IntroFooter`

**修复：** footer 改为 `SingleChildScrollView` 垂直 + 水平双滚动，去掉 `Expanded` 争高。Compare/Mystery footer 加水平 `SingleChildScrollView` 防 840px 宽 Radio 溢出。

**状态：** 已修复

---

## 3.16 FAIL（Reset 后 Density Table 仍展开）

**现象：** `ExpansionTile.initiallyExpanded` 仅在首次 mount 生效；Reset 将 `tableExpanded=false` 但 UI 仍展开。

**预期：** Reset All 后 Accordion 恢复 collapsed。

**实际：** 状态已 false，UI 未折叠。

**证据：** 状态测试 `3.16 reset collapses density table state` + PhET `densityTableAccordionBox.reset()`

**相关代码：** `lib/density/view/screens/mystery_screen.dart` · `DensityTablePanel`

**修复：** `DensityTablePanel(key: ValueKey(state.tableExpanded))` 强制 remount。

**状态：** 已修复

---

## Texture 视觉（BLOCKED · 需人工）

**现象：** Agent 无法目视 JPEG 木纹/砖纹/金属质感。

**程序化验证：** 六材 `DensityTextureCache.imageFor` 非 null；`cubeFrontRect` 随 volume 缩放（`paintImage` 绑定 front rect）。

**状态：** BLOCKED — 请实机确认贴图质量

---

## Loop 11：Density Table 顶行裁剪（FAIL → 已修复）

**现象：** Mystery 屏 Density Table 放在 NineGrid `topCenter`（~55px 高）；展开 13 行被裁剪，用户看不到表格。

**修复：** `mystery_screen.dart` 改为 `Stack` overlay，表盘浮于顶部居中并向下展开覆盖实验区。

**状态：** 已修复 · `density_widget_test` 840×520 通过

---

## Loop 11：AC-F19 About 署名

**修复：** AppBar info 按钮 → `density_about_dialog.dart`（Adapted from PhET · GPL-3.0 · CC0）

**状态：** 已修复

---

## Loop 11：Texture 生命周期

**修复：** `DensityTextureCache.dispose()` 于 `DensityHome.dispose` 调用。

**状态：** 已修复

---

## Mass labels 开关（PASS · 源码无 UI）

PhET Density Mystery 仅 `massValuesInitiallyDisplayed: false`，无 Buoyancy 式 Checkbox。Flutter 默认隐藏质量标签符合源码。
