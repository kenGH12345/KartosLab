# Notes · req-cck-ac-virtual-lab

## 决策

- 2026-09-02：独立目录 `lib/cck_ac_virtual_lab/`，不合并既有 `lib/circuit/`。
- 2026-09-02：求解器跟发布路径 = PhET LTA/MNA。`LinearTransientAnalysis` 里 spice 分支已注释。
- 2026-09-02：日用品电阻以 `ResistorType.ts` 为准（1E6 不是文档 1E9）。

## 源码本地镜像

- VL 用户提供 zip：`phet sourses/circuit-construction-kit-ac-virtual-lab-main/...`
- 依赖 clone：`phet sourses/circuit-construction-kit-common/`、`phet sourses/circuit-construction-kit-ac/`

## 与 checklist 冲突

配置化 JSON：原版无 scenario。按 Kepler 先例标 [有意差异]，不做假 schema。

## 收尾

- 2026-09-02：Home 卡「AC 虚拟实验室」。`lib/circuit` 保留。
- 视觉：[视觉近似] + [待确认：缺少原版运行截图]。
