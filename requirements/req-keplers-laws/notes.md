# Kepler's Laws · 决策与踩坑

## 2026-09-01 · Phase 0

- 原版是 HTML5/TypeScript，不是 Java 遗留。依赖 `solar-system-common`（与 My Solar System 共享）。
- 本工程没有 My Solar System，因此 **不把** Body / Engine / TimeControl 抽到 `lib/common/`（3-Time Rule 第 1 用户）。
- 目录选 `lib/astronomy/keplers_laws/`，类比已落地的 `lib/magnetism/magnet_and_compass/`。非不可逆。
- 原版无 JSON scenario；不做假 scenario 以满足 checklist 配置化条款。[有意差异]
- git clone / zip 下载 GitHub 失败（Connection reset / timeout）。源码以 raw.githubusercontent.com 与 GitHub API tree 取证。

## 2026-09-01 · Phase 6–10

- `VELOCITY_TO_VIEW_MULTIPLIER = 50 * 0.01 / VELOCITY_MULTIPLIER ≈ 0.04997`。之前临时 `* 4` 已删除。
- `periodTracker.step(dt)` 必须用墙钟秒。误乘 `modelToViewTime` 会让 3s 淡出在两帧内结束。
- All Laws radio 不能放进 NineGrid `bottomLeft`（剩余宽度约 68px）。改为中心画布左下 Positioned，对齐原版 AlignBox left-bottom。
- Reset All 颜色以 `PhetColorScheme.RESET_ALL_BUTTON_BASE_COLOR` 为准，不是截图猜的橙。
- Debug APK：`build/app/outputs/flutter-apk/app-debug.apk`。Kotlin Gradle Plugin warning 为既有工程问题，未改。

## 2026-09-01 · 布局续修

- 禁止再下 GitHub ZIP；thirdLaw 测试保持 `T = (a³ · INITIAL_MU / μ)^½`。
- 隐藏 overlay 的 `SizedBox.shrink()` 不能当 Stack 非定位子节点：会把 play area 高度压成 0，MVT 仍按整格计算，太阳画到格子下半。
- 定律面板必须 AlignBox 到 **整页** 边缘。叠在 NineGrid 70% 中心格内会挡住默认行星（+2 AU × 100 px）。
- Visual QA：用窗口内质心，不用整图 mean RGB。widget 截图文字是 Ahem。

## 2026-09-01 · 本地源码

- 用户指定：`d:\OneDrive\Desktop\phet sourses\keplers-laws-main\keplers-laws-main`（1.3.0-dev.0）。
- 后续取证只读该目录，不再下 GitHub ZIP。
- 本树没有 `solar-system-common`：`constrainDragPoint` 仍在父类；`images/`、`sounds/` 只有 `*_png.ts` / `*_mp3.js`，没有独立 png/mp3。
