# Under Pressure — Faucet / Valve Alignment Report

**Req id:** `req-port-under-pressure`  
**Date:** 2026-09-24  
**Scope:** View-only faucet structure + interaction (Model LOCKED)

---

## STATUS: DONE

Under Pressure 水阀已与 KartosLab 既有 scenery-phet `FaucetNode` 实现对齐；交互按产品要求改为「仅蓝钮拖动、无级调节」。

---

## What changed

| Item | Before | After |
|---|---|---|
| Shooter 结构 | 错位 Stack（knob/shaft/flange） | shaft → stop → flange → knob@0.6（对齐 `PhScaleFaucetNode` / `FaucetNode.ts`） |
| 点击蓝钮 | tapToDispense / 点按即开 | **不响应点击开闸** |
| 调节方式 | 大面积 hit + 松手关闸 | **仅蓝钮拖动**，位移无级映射流量，松手保持开度 |
| Hit 区域 | track + shooter + 37×60 dilation | **仅 `faucetKnob` 包围盒** |
| Assets | scenery-phet PNGs（UP 路径） | 不变 · Substituted = 0 |

**实现文件：** `lib/under_pressure/view/up_faucet_node.dart`  
**参考实现：** `lib/chemistry/ph_scale/view/widgets/ph_scale_faucet_node.dart`  
**源码：** `scenery-phet/js/FaucetNode.ts` + `UnderPressureFaucetNode.js`

---

## Interaction contract（产品定稿）

1. 只有按住**蓝色旋钮**才能开始拖动  
2. 拖动左右 = 流量 0…max 无级调节（按 shooter 行程 `4…66` native × scale）  
3. 单击 / 轻触不改变流量  
4. 松手**保持**当前流量（`closeOnRelease: false` 语义）  
5. 水管 / 轨道 / 灰轴 / flange **不可**作为拖动手柄

> 与 PhET 默认 `tapToDispense` + `closeOnRelease: true` 不同；本定稿以产品交互为准，结构仍复用 scenery-phet 精灵布局。

---

## Tests

| Suite | Result |
|---|---|
| `flutter test test/under_pressure` | **126 PASS** |
| Goldens | **12/12**（faucet 视觉变更后已 `--update-goldens`） |
| `flutter analyze` (`up_faucet_node.dart`) | clean |

Model / Home / Phase 0–6 结论不变。Runtime / Android：**仍 NOT VERIFIED**。

---

## Knowledge handoff

后续 sim 需要 scenery-phet 水阀时，优先读：

- `docs/knowledge/kratos-java-simulations/scenery-phet-faucet-node.md`
- Cursor rule：`.cursor/rules/87-scenery-phet-faucet.mdc`

**L1 状态：** 已有 2 个 Flutter 使用者（pH Scale + Under Pressure）→ 登记为 L1 候选；第 3 个 sim 再上抽 `lib/common/`。
