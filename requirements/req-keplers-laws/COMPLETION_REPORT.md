# COMPLETION_REPORT · Kepler's Laws

> 日期：2026-09-01  
> 原版：https://phet.colorado.edu/en/simulations/keplers-laws  
> 源码：本地 `d:\OneDrive\Desktop\phet sourses\keplers-laws-main\keplers-laws-main`（1.3.0-dev.0）+ solar-system-common  
> 工程落点：`lib/astronomy/keplers_laws/`

**禁止声称「完全一模一样」。** 下表按证据分级。

---

## 总览

| 维度 | 状态 |
|---|---|
| 引擎公式 vis viva / Kepler NR / 面积分割 | [源码一致] |
| Play / Pause / Step / Restart ≠ Reset | [行为一致] |
| 播放门闩 `allowedOrbit` | [行为一致] |
| Always Circular / 逃逸半径夹逼 / 速度最小模 | [行为一致] |
| Zoom 0.5 s CUBIC_IN_OUT；Reset 跳到 100 | [行为一致] |
| PeriodTracker 淡出 3 s（墙钟） | [行为一致] |
| 速度矢 `VELOCITY_TO_VIEW_MULTIPLIER` | [源码一致] |
| 重力矢 `10^(power-3) * VELOCITY_TO_VIEW` | [源码一致] |
| 目标轨道椭圆 | [行为一致] |
| 第三定律 T–a 图 + 越界箭头 | [行为一致] 几何简化 |
| FirstLawGraph 离心率条 | [行为一致] e=0 在轴顶，对齐 scenery Y-down |
| 测量尺 | [视觉近似] |
| 太阳在 play area 中心、行星默认 +x 200 view-px | [视觉已对齐] Flutter 1024×768 质心 (508,360) / Δx≈200 |
| 面积扇 clockwise（`anticlockwise=false`） | [源码一致] `SweptAreaPainter.clockwiseSweep` |
| NineGrid + AppBar/Tab | [有意差异] |
| 声音 / Info 对话框 PNG | [待确认] 本地仅有 `*_mp3.js` / `*_png.ts`，无独立文件 |
| `constrainDragPoint` 面板最近点 | [BLOCKED] 缺 `solar-system-common`；已知 bounds 名单，未猜算法 |
| live PhET 同视口 overlay | [待确认] 无原版运行截图；screen3/4 缺失不伪造 |
| 键盘拖 / PDOM / PhET-iO / Projector | [有意差异] |

---

## Phase 记录

| Phase | 产物 | 结果 |
|---|---|---|
| 0 Discovery | `PROJECT_DISCOVERY.md` | 完成 |
| 1 Source | `SOURCE_ANALYSIS.md` | 完成 |
| 2 Baseline | `visual-qa/BASELINE.md` + 官方 PNG | 完成；构图参考非金标 |
| 3 Architecture | `ARCHITECTURE_PLAN.md` | 无阻塞决策 |
| 4 Model | Engine + Controller + 单测 | 完成；thirdLaw **按源码公式** |
| 5 Static render | Painters + 画布 | 完成 |
| 6 Interaction | 拖位置/速度、面板、Reset/Restart | 完成 |
| 7 Animation | Zoom 0.5s、Period fade 3s | 完成 |
| 8 Screen | AppBar / Tab / NineGrid + 页面 AlignBox 面板 | 完成 |
| 9 Visual | Flutter 截图 + 几何测量 | 见 `visual-qa/PHASE9.md` |
| 10 QA | analyze 0；专项 35 tests | 见下 |
| 11 Home | 物理 → 天体力学 → Kepler's Laws | 完成，未改入口设计 |
| 12 Legacy | `phet/` 无 Kepler 实现 | 无归档对象 |

---

## 测试

```
flutter analyze lib/astronomy/keplers_laws test/astronomy/keplers_laws
→ No issues found

flutter test test/astronomy/keplers_laws
→ 35 passed
```

覆盖：默认椭圆、崩溃/逃逸、Always Circular、Reset≠Restart、播放门闩、T²/a³（`INITIAL_MU/μ` 非理想 T=a^1.5）、太阳质量 snap、周期分割、速度缩放常数、zoom reset、period fade 3s、面积扇 **始终顺时针**、Home 卡片、Home↔Kepler **5 次**、KeplersLawsHome create/dispose 5 次、四 Tab、Play、Reset、All Laws radio、play area 尺寸、视口 1024/1280/1366/840 无 overflow、四张 1024×768 截图落盘。

**未**把 thirdLaw 测试改回理想公式。

全仓回归：未跑全部历史 sim 测试（本迁移未改其他 sim 源码，仅 `home_screen.dart` 注册一处）。

---

## Analyze / 构建

- Kepler 目录 **analyze 0 issues**。[已确认]
- Debug APK：**失败**（既有工程 / 镜像，非 Kepler）
  - `:integration_test:compileDebugJavaWithJavac` 无法解析 `androidx.test:runner:1.2+`
  - `storage.flutter-io.cn` 返回 **403 Forbidden**
  - Kotlin Gradle Plugin deprecation warning 同既有工程
  - **未改** android / integration_test / unrelated code
- Release APK：未跑（debug 已因既有依赖镜像失败）
- 全仓 `flutter test`：**未完成**。跑到 `test/forces/forces_scenario_test.dart`（netforce-tug）约 +748 ~1 后停滞 >10 min。与 Kepler 无关，已中止。未改 forces 测试。

---

## 有意差异（开工已锁定）

1. joist 四 Screen + 底栏 → KARTOSLAB AppBar + `KratosTabbedScreen`
2. Tab 无 KeepAlive（切走 dispose）
3. 不做 PDOM / PhET-iO / 多语言 / Projector 色表
4. 不把 Body/Engine 抽到 `lib/common`
5. 键盘拖一期不做
6. 不自制缺失 asset（碰撞/逃逸/Success mp3、Info PNG）

---

## 已知缺口（只记录，不擅自发明）

| 项 | 标记 | 说明 |
|---|---|---|
| live PhET vs Flutter overlay | [待确认] | 官方 PNG 是构图态；screen3/4 缺失不伪造 |
| 面积扇区扫掠 | [源码一致] | `clockwiseSweep` ≡ kite `anticlockwise=false`；未做 live 播放态叠图 |
| `constrainDragPoint` | [BLOCKED] | 父类不在本地树；只夹 escapeRadius |
| 天体循环音 / 节拍器 | [有意差异] | 缺独立 mp3 |
| widget 截图文字 | Ahem 方块 | 真机字体未截 |

---

## 遗留分类

1. **本迁移引入（已修）** — TimeControl 缺 Material；速度矢 `*4`；Period fade 误乘 modelToViewTime；非法轨道实线+虚线叠画；All Laws radio 挤进窄 NineGrid 格；Play area Stack 高度 0 导致太阳下移；中心格内面板挡住默认行星；面积扇最短弧（已改为始终顺时针）。
2. **原 PhET 本身** — 无需要修的。
3. **工程既有** — 未改 common API、未改其他 sim。
4. **缺失资源** — sounds / info dialog images 未复制。
5. **证据不足** — live 视口 overlay。

---

## 如何运行

Home → 物理 → **天体力学** → **Kepler's Laws** → First / Second / Third / All Laws。
