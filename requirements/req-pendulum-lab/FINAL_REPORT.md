# FINAL / STATUS REPORT — Pendulum Lab

```
Simulation: Pendulum Lab
Source: Local PhET source (1.1.0-dev.5)

Architecture: PASS
Physics: PASS
Behavior: PASS (model/unit)
Interaction: PASS (browser cross-validation: drag/release, sliders, tools)
Visual: PASS (18-state matrix ×2 + diffs; chrome converged; baseline documented)
Assets: PASS (mipmaps extracted; Substituted=0 for bitmaps; geometry rebuilt)
Lifecycle: PASS (SimulationClock dispose + TickerMode)
Reset: PASS (unit + capture symmetry 01=05, 06=10, 11=18)

Tests: 31 PASS / 0 FAIL
Analyze: CLEAN (lib/pendulum_lab + test/pendulum_lab)

P0: 0
P1: 0
P2: several micro chrome

Browser Cross Validation: PASS
  - Drag/Release 15°/60°: grab/follow/release/oscillation all correct
  - Energy: sliders (mass/length/gravity) real-drag to target; PE == m·g·L·(1−cosθ)
    exact; conservation 0.05%; PE scaling ×mass/×length/×gravity all exact
  - Period Timer: real click start → auto-stop at full period;
    measured 1.69127 s vs theory 1.69118 s (0.005%)
  - Stopwatch: real click play/pause; elapsed 1.71 s per 1.5 s wall; freeze on pause

Final Status: READY
```

## Delivered

- `lib/pendulum_lab/` full Model → Clock → View → Interaction
- Home 力学组入口
- `assets/simulations/pendulum_lab/` 原版 mipmaps
- `requirements/req-pendulum-lab/` Phase 0–5 docs + ASSET_MAP
- Visual QA pipeline: `tool/capture_pendulum_original.js` +
  `test/pendulum_lab/pendulum_visual_qa_capture_test.dart` +
  `tool/build_visual_manifest.py` + `tool/diff_visual_qa.py`
  （18 状态 × ORIGINAL/FLUTTER + 18 DIFF + manifest.json）
- Browser cross-validation: `tool/cross_validate_pendulum.js`（拖拽）、
  `tool/cross_validate_controls.js`（滑块/复选框/工具按钮，真实鼠标操作 +
  场景图候选发现 + 试拖/试点分类）

## Visual QA 结果（第二轮 vs 第一轮）

- 18/18 状态 mean_abs_diff 全部下降（如 04: 35.9→30.96，09: 35.9→30.67，17: 35.8→30.51）
- delta>32% 像素占比全部下降（04: 20.5→18.08，09: 18.0→15.83，17: 17.8→15.44）
- Stopwatch / Energy bar / Period Timer chrome 经裁剪目视对比确认收敛
- 残留差异 = 外壳基线（PhET 导航栏 vs KartosLab shell 的缩放/偏移）+
  运行态时序 ghost（双端积分器逐帧累积差），属文档化预期

## 本轮关键修复

1. 字体根因：widget 测试中 `Arial` 落 Ahem 回退（1em/字符）→ 重力显示框溢出 13px、
   Period Timer 溢出 23px、全局文本宽度失真；capture setUpAll 现加载真实
   Trebuchet MS + Arial，溢出清零
2. Stopwatch chrome 按 scenery-phet StopwatchNode 参数重建（边框色/图标高/按钮高/尺寸）
3. EnergyGraphAccordion 动态填充布局 + 堆叠 Total 条 + Thermal 垃圾桶标签
4. Period Timer capture 漏 setVisible（源码 setRunning 在不可见时强制回落）已修

## 性能（拖动卡顿修复，READY 后追加）

拖动配重卡顿的三重根因与修复：

1. 拖拽手势 `setState` + `notifyListeners` 双重全屏重建 → 移除冗余 `setState`
2. `modelStep` 空转也逐 tick notify（静止场景 60/s 全屏重建）→ 仅在实际步进/秒表走时通知
3. 五个场景 painter `shouldRepaint => true` → 值指纹比较，静止图层零重绘；
   右侧面板/播放条/Reset 包 RepaintBoundary

验证：31 tests PASS、analyze CLEAN、18 状态 diff 统计与修复前逐位一致（视觉零回归）。
