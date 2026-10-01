# POST–PHASE 9 UX POLISH REPORT

**req-id:** `req-port-ph-scale`  
**date:** 2026-09-22  
**scope:** Phase 9 之后的交互 / 视口 / Micro Graph 用户反馈修复（非 Gate 重开）

---

```text
SESSION STATUS: PASS

FINAL STATUS (unchanged): READY CANDIDATE
```

**本轮结论：** 用户确认的水龙头拼装 / 拖动 / 点击出水、探针阻力、三屏铺满、Macro 水龙头命中、Micro 左侧对照表完整显示均已落地；`dart analyze` CLEAN；`flutter test test/chemistry/ph_scale/` **94 PASS**。  
**不升级为 READY：** 与 Phase 9 相同——截图 harness 仍 BLOCKED、Android Runtime 未验证、P2 chrome 仍在。

---

## 1. 用户反馈 → 修复对照

| # | 用户反馈 | 根因 | 修复 | 判定 |
|---|---|---|---|---|
| 1 | 水龙头拼接不像对照图 | Stack 简化拼装，缺 flange/shaft/track 几何 | 按 scenery-phet `FaucetNode` 重写 `PhScaleFaucetNode`（原 PNG + origin=spout 底心 + scale 0.6 + 水平翻转） | `[原版资源一致]` |
| 2 | 蓝钮拖动方向 / 不跟手 | 镜像映射反了；拖动手感差 | mirror：左开右关；`Listener` 绝对坐标拖动 | `[动态绘制已对齐]` |
| 3 | 探针拖动阻力大 / 延迟 | 全树 `setState` + 装饰层抢命中 | 探针 `Listener` 绝对定位；meter 装饰 `IgnorePointer`；水龙头叠在 meter 之上 | PASS |
| 4 | 三屏显示不全 / 留白 | `BoxFit.contain` 未铺满 Tab body | `PhScaleViewport` → `BoxFit.fill` | `[布局已对齐]` |
| 5 | Macro 水龙头点不动 | 探针线全幅 `CustomPaint` 抢 hit | meter chrome `IgnorePointer`；水龙头置顶 | PASS |
| 6 | Micro 左侧对照表裁切；色块化学式/分子太小 | Graph 左边距不足；indicator 偏小 | Graph `left` clamp ≥8；callout ≈168×96×0.85；公式 ~22px；分子 scale 0.62 + `FittedBox` | `[布局已对齐]` `[原版资源一致]`（数值几何仍按源；字号略放大属 UX） |
| 7 | 点击蓝钮不能马上开阀，只能拖 | 关闭时蓝钮在 flow≈0 位；按下按 X 映射仍为 0，松手 `closeOnRelease` 再清零 | 实现 PhET `tapToDispense`（0.05 L / 333 ms）；点击无拖动 → 短时出水；拖动仍控流量 | PASS（对齐 `PHScaleConstants.FAUCET_OPTIONS`） |

---

## 2. 主要改动文件

| 文件 | 变更摘要 |
|---|---|
| `lib/chemistry/ph_scale/view/widgets/ph_scale_faucet_node.dart` | 完整 FaucetNode 拼装 + drag + **tapToDispense** |
| `lib/chemistry/ph_scale/view/widgets/ph_scale_viewport.dart` | `BoxFit.fill` 铺满视口 |
| `lib/chemistry/ph_scale/view/widgets/macro_ph_meter_node.dart` | 探针绝对拖动；装饰层不抢 hit |
| `lib/chemistry/ph_scale/view/screens/macro_screen_view.dart` | Viewport + 水龙头叠层顺序 |
| `lib/chemistry/ph_scale/view/screens/ph_scale_screen.dart` | Micro / My Solution Viewport；Graph 左边距 clamp |
| `lib/chemistry/ph_scale/view/graph/graph_indicator.dart` | 色块 / 化学式 / 分子放大 |
| `lib/chemistry/ph_scale/view/graph/ph_scale_graph_node.dart` | gutters / totalWidth 配合 callout |

**Model / Home / Reset All / ASSET 替换策略：** 未改 Model；未改 Home 入口；仍用 `KratosResetAllButton`；**Substituted Assets = 0**。

---

## 3. 验收证据

| 门禁 | 结果 |
|---|---|
| `dart analyze lib/chemistry/ph_scale` | CLEAN |
| `flutter test test/chemistry/ph_scale/` | **94 PASS**（与 Phase 9 同量级） |
| Assets Substituted | **0** |
| P0 / P1 | **0 / 0** |
| P2 chrome | 仍约 5（ABSwitch / joist footer / callout bevel 等）— 本轮未清 |
| Visual screenshot harness | 仍 **BLOCKED**（`SimulationClock` + `toImage`；runtime 未改） |
| Android Runtime | 仍 **NOT VERIFIED** |
| 用户确认收尾 | **是**（「这个结束，可以 report 了」） |

---

## 4. 视觉判定（本轮相关）

```text
[原版资源一致]  Faucet / Graph / Molecule 仍走原 PNG 或源码几何等价
[布局已对齐]    三屏 Viewport fill；Micro Graph 左边完整可见
[动态绘制已对齐] tapToDispense + drag/closeOnRelease；探针绝对拖动
```

---

## 5. 遗留（诚实列表）

1. **READY 未达成** — 缺完整 1024×618 截图矩阵与 pixel diff  
2. **Android 真机** — 未跑  
3. **P2** — TabBar vs joist、ABSwitch 皮肤、indicator bevel、探针 stick 简化等  
4. **Graph 色块字号** — 相对 PhET `PhetFont(28)×0.75` 略放大（用户可读性请求）；未改物种几何语义  

---

## 6. 状态

```text
phase:           9.final + post-ux polish
session:         PASS
overall_status:  ready_candidate
final_status:    READY CANDIDATE
user_close:      confirmed 2026-09-22
```

**下一步（可选，非阻塞本轮收尾）：**

1. 解截图 harness（不关 `SimulationClock`）→ Visual PASS → 评估升 READY  
2. Android 真机冒烟  
3. 按需清 P2 chrome  

---

*Report closes the post–Phase 9 UX polish session. Phase 0–9 gate documents remain authoritative for the release candidate baseline.*
