# Membrane Transport · RISK_REGISTER

> PHASE 0 · 风险登记

| ID | 风险 | 严重度 | 阶段 | 缓解 |
|----|------|--------|------|------|
| R01 | 4 Screen × 独立 Model 被错误做成 singleton | P0 | Model | FeatureSet 工厂；每屏 Provider 隔离 |
| R02 | 用圆/Material icon 替代 SVG 粒子与通道 | P0/P1 | Visual | VISUAL_ASSET_AUDIT 硬门槛 |
| R03 | 磷脂误用位图或圆角矩形“膜” | P1 | Visual | 按 Phospholipid.ts 程序绘制 |
| R04 | 随机不可复现导致测试/Golden 失败 | P0 | Model/Test | injectable seeded RNG |
| R05 | AnimationController 驱动粒子代替 model.step | P0 | Architecture | Model→RenderData 管线 |
| R06 | Eraser 与 Reset All 语义混淆 | P1 | Behavior | RESET_SEMANTICS 测试 |
| R07 | 梯度偏置参数被“科学修正” | P1 | Science | 锁定 BIAS_* 常量 |
| R08 | 蛋白状态机（泵/共转运）漏迁移 | P0 | Physics | Phase 1 逐文件状态图 |
| R09 | 每粒子一个 Widget → 200×多类型卡顿 | P1 | Perf | Canvas 批绘（对齐 source） |
| R10 | layoutBounds 未核实导致比例偏差 | P1 | Layout | Phase 1 查 joist DEFAULT / 运行时测量 |
| R11 | a11y/音效范围过大拖垮排期 | P2 | Scope | 先 CORE+DISPLAY；Audio/A11y 分里程碑但不删需求 |
| R12 | Ligands reset 语义误解（清空数组） | P1 | Reset | 保留预分配；只关 Property |
| R13 | 自行添加 Step 按钮 | P2→P1 | UX | TimeControl 无 step |
| R14 | Home 图标自绘 | P1 | Home | 用 `*_home_icon.svg` |
| R15 | 跨屏共享浓度/蛋白状态 | P0 | Architecture | 禁止；对齐 source |

---

## Open Questions

| Q | 状态 |
|---|------|
| joist `DEFAULT_LAYOUT_BOUNDS` 精确值？ | 待 Phase 1（惯例 768×504） |
| `model.time` 是否在 reset 归零？ | **已确认：不归零** |
| Voltage / Ligand / Pump 完整状态转移表 | 待 Phase 1 深挖 proteins/*.ts |
| CAPTURE_RADIUS 默认数值 | **已确认：40**（ATP×2=80）；Phase 0 误记 20 已更正 |
| KartosLab Home 生物分类挂载点 | 待 Home 阶段查现有 category |
