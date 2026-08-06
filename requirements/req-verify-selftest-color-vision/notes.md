# 决策 & 踩坑 & 实证债务

## 2026-08-05 · 实证债务清单（欠 3 个 AC 的真操作证据）

本需求补测（Diff-2）阶段只对 **AC-2 White + Red Filter** 完成了真 GUI 操作 + 截图。以下 3 个 AC 保持 `⚠️ 静态推演`，下次真需求接触到 color_vision 时需要偿还：

| AC | 需补的操作 | 需补的截图（建议路径） |
|---|---|---|
| **AC-1** | Source=Mono · 拖 SpectrumSlider 到 650nm · 观察光束呈红色 | `screenshots/ac-1-mono-650nm.png` |
| **AC-3** | Source=White · Filter=Blue · 观察 "Person sees: Blue" | `screenshots/ac-3-white-blue.png` |
| **AC-4** | Source=Mono(任意 nm) · Filter=Red · 观察光束按 passRates 调色 | `screenshots/ac-4-mono-red.png` |

**触发条件**：当有需求真正修改或验证 `lib/color_vision/` 时（如 `req-color-vision-layout-fix` 修完后的回归验证），可顺手把这 3 张图补齐并更新 `ac-verification.md`。

**豁免依据**：`.codebuddy/skills/core/self-testing/SKILL.md` v0.1.1 §「零真操作边界」允许 "真操作 AC 数 ≥ 1 且诚实标注其余为静态推演" 的情况通过诚实声明门禁。本需求 AC-2 已满足 "≥ 1 真操作" 硬约束。

## 2026-08-05 · 用户决策 1a/2/3a

- **1a**（AC-3 处理）：Blue 截图不本次补 · AC-3 保持静态推演 · 记入本 notes.md 实证债务
- **2**（Bug 定性）：图 3 是用户故意缩窄窗口验证适配 · 确认 L0-2/L0-3 违规 · 立独立需求 `req-color-vision-layout-fix`
- **3a**（时间戳）：保留原 2026-08-03 时间戳 + 追加 2026-08-05 补测段 · 尊重迭代痕迹

## 2026-08-05 · 衍生需求

- `requirements/req-color-vision-layout-fix/` — 修 single_bulb 屏窄视口主图消失
- 状态：`phase=1.intake` · `status=pending` · 等待主会话或 product-manager 走 phase 1→2 切换
