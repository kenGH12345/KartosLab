# scenery-phet FaucetNode · Flutter 复用指南

> **状态**：L1 候选（2/3 使用者）· **勿再平行发明第三套 shooter**  
> **更新**：2026-09-24 · Under Pressure 水阀对齐 + 产品交互定稿  
> **源码**：`phet sourses/scenery-phet/js/FaucetNode.ts`（ShooterNode + PNG sprites）

---

## 何时用

任何 PhET HTML5 / scenery-phet 水阀（入水、出水、排水）在 Flutter 侧需要：

- 原版 PNG（body / spout / pipes / track / shaft / stop / flange / knob）
- 滑杆式开度（shooter 左右移动）

**禁止**：Material `Icons`、自绘「差不多」旋钮、整阀 `GestureDetector` 冒充 hit。

---

## 权威参考实现（按优先级）

| 优先级 | 路径 | 说明 |
|---|---|---|
| 1 · 结构+交互样板 | `lib/chemistry/ph_scale/view/widgets/ph_scale_faucet_node.dart` | 完整 scenery-phet 布局；含 mirror / tapToDispense / closeOnRelease |
| 2 · UP 产品交互 | `lib/under_pressure/view/up_faucet_node.dart` | 同结构；**仅蓝钮拖动、无级、松手保持**（产品定稿） |
| Assets · pH Scale | `assets/simulations/ph_scale/images/faucet*.png` | 经 `PhScaleAssets` |
| Assets · Under Pressure | `assets/simulations/under_pressure/images/faucet*.png` | 同源 scenery-phet PNG |

复制时：**先抄布局常量与 sprite 顺序**，再按 sim 改 `scale` / `horizontalPipeLength` / mirror / 交互开关。

---

## 结构硬约束（FaucetNode.ts）

Origin = **喷口底边中心**。

Sprite 顺序（底→顶）：

1. horizontalPipe（按 `horizontalPipeLength - 112 + 1` 拉伸）  
2. verticalPipe（默认 length 43）  
3. spout  
4. body（右齐 verticalPipe）  
5. track（`TRACK_Y_OFFSET = 15`）  
6. **Shooter**：shaft → stop(+13) → flange(shaft.right−1) → knob(flange.right−8, **knobScale 0.6**)

Shooter X：`body.left + 4 + f*(66−4)`，`centerY = track.top + 16`。

---

## 交互模式（二选一，写进 EDD）

### A · PhET 默认（pH Scale）

- 拖动 shooter（hit ≈ track+knob）→ 流量  
- `closeOnRelease: true` → 松手关闸  
- `tapToDispense` → 短促放水  

### B · 滑块式（Under Pressure 产品定稿 · 2026-09-24）

- **Hit = 仅蓝色 knob 包围盒**（管/轴/轨道不可拖）  
- 单击不改变流量  
- 水平拖动用 **delta** 映射到 `4…66` 行程（避免按住瞬间跳变）  
- 松手**保持**当前流量  

新 sim 默认跟源码选项；若产品明确要求「拖旋钮调节」，用模式 B，并在 report 注明与 PhET 默认差异。

---

## 接线清单（新 sim）

1. 拷贝 / 引用 scenery-phet `faucet*.png` → `ASSET_MAP.md`（Substituted=0）  
2. 以 `PhScaleFaucetNode` 或 `UpFaucetNode` 为模板，**不要**从零画 shooter  
3. Model：`flowRate` / `maxFlowRate` / `enabled`；流柱另做（如 `UpFaucetFluidNode`），勿与阀体混在一个 painter  
4. 第 3 个使用者出现时：走 tech-leader，上抽 `lib/common/widgets/kratos_faucet_node.dart`（L0）

---

## L1 登记

| 使用者 | 文件 |
|---|---|
| 1 · pH Scale | `ph_scale_faucet_node.dart` |
| 2 · Under Pressure | `up_faucet_node.dart` |
| 3 · （待） | 触发上抽 |

详见 `shared-abstraction-plan.md` 候选「scenery-phet FaucetNode」。
