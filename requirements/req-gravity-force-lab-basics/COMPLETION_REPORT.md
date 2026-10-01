# COMPLETION_REPORT — Gravity Force Lab: Basics

## Verdict

**移植成功 · 可封板。**

PhET **Gravity Force Lab: Basics**（本地 `1.2.0-dev.0`）已迁入 KARTOSLAB。

| 维度 | 状态 |
|---|---|
| 源码版本 | [已确认] `1.2.0-dev.0` |
| Screen | [已确认：单 Screen] |
| 物理一致 | [物理一致] \(F=G m_1 m_2/r^2\)，G=6.67430e-11 |
| 默认力 | **33.3715 N** → 显示 **33.4 N** |
| Constant Size / Radius | [源码一致] \(\rho=1.5\) |
| 拖拽 / snap / 间距 | [行为一致] 100 m / 200 m / ±5000 m |
| 力箭头 | [源码一致] 双段线性映射 |
| Robots / Assets | [已确认] **31/31** `figurePull_*.png`；pubspec 目录已覆盖 |
| Home | 物理 → 力学 |
| Tests | **20 passed** |
| Analyze | **0 issues** |
| Debug APK | ✅ `app-debug.apk` |
| Release APK | ✅ `app-release.apk` (62.7MB) |

---

## Acceptance

| AC | 结果 |
|---|---|
| AC-1 Home 进出 | ✅ |
| AC-2 默认力 ≈33.4 N | ✅ |
| AC-3 Values / Distance / Constant Size 默认 | ✅ true / true / false |
| AC-4 拖球约束 | ✅ |
| AC-5 箭头 + 第三定律 | ✅ |
| AC-6 测试 + analyze | ✅ |

---

## 交付

- 代码：`lib/gravity_force_lab_basics/`
- 资源：`assets/phet/gravity_force_lab_basics/pullers/`（**31/31**，见 `ASSET_MAPPING.md`）
- 测试：`test/gravity_force_lab_basics/`
- 文档：`requirements/req-gravity-force-lab-basics/`

未迁移完整版 `gravity-force-lab`。未改其他 simulation。

## 资源确认

**[已确认]** 本地 `figurePull_1.png` … `figurePull_31.png` 齐全。

- `pubspec.yaml`：`assets/phet/gravity_force_lab_basics/pullers/`（目录级，覆盖全部 31 张）
- 运行时：`PullerImageWidget` → `figurePull_(frameIndex+1).png`
- 无缺失 PNG；无运行时加载缺口；不影响构建/测试
- 此前下载曾在约 `figurePull_9` 中断属过程事件，**最终状态不是** BLOCKED / [缺失资源]

## 有意差异 / 待确认

- **Audio**：**[源码确认：原版存在音效 → 待迁移]**（见 `AUDIO_ANALYSIS.md`）。Flutter 当前无声属功能缺口，**不是**「原版无音效」。禁止自制音效。
- [待确认：缺少原版 runtime 截图] — 无像素 overlay
- A11y / Voicing / Vibration — 有意省略（与 tambo 音效分列）
- 共享库无本地克隆：算法/音效实现细节部分依赖 GFL+tambo 公开源；Basics 本树已确认 **有** sound wiring

## 运行

**Home → 物理 → 力学 → Gravity Force Lab: Basics**
