# DEPENDENCY_PROVENANCE — Diffusion

| Dependency | Lock SHA (dependencies.json) | Analyzed SHA | Migration SHA | Status |
|---|---|---|---|---|
| **gas-properties** | `7a52c48ab2892644dc8afb426b523d47d621a56d` | 同左（clone `gas-properties-for-diffusion`） | 同左 | **A** — Diffusion 模型全部取证自此 |
| diffusion (self) | `5ebcdc0c3cc1bed439592b50e1277817ba0723c7` | 本地 1.2.0-dev.0 树 | 启动壳 | 薄壳 |
| scenery-phet | `b491faff…` | 未单独改语义 | UI 控件模式参考 | 不强制锁 UI |
| dot / axon | lock 内 | random / Property 模式 | Dart 等价 | — |
| tambo | lock 内 | 本轮未迁音频 | [待实现] 音效 | — |

**不使用**：Collision Lab、IdealGasLawModel、官网 latest、GitHub main HEAD（除非 SHA 相同）。

**判定**：核心物理/碰撞取证 **A**（lock 对齐）。
