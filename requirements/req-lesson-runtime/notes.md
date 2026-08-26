# req-lesson-runtime · 决策与留痕

## 代码评审（2026-08-25）遗留项记账

初评 has_blockers（design/代码评审.md）→ 修复全量闭环（复审 passed_with_suggestions）。以下 Minor 项**未修但有意留痕**（评审建议记账）：

| # | 项 | 状态 | 处置 |
|---|-----|------|------|
| Minor-1 | LessonSimHosts 全静态 + _loading Future 缓存：无失败重试/测试复位 | 接受 | 场景资产损坏是资产质量问题（有守卫+巡检兜底），运行时失败重试收益低；重启 app 即复位 |
| Minor-2 | 图校验缺「必须存在可达终点节点」规则 | 推迟 | 依赖「最后一节点是终点」的软约束；若未来出现无终点剧本再补硬规则 |
| Minor-3 | 异常捕获注释与实现不一致 + 兜底 catch 伪装编程错误 | 部分 | 宽 catch 注释已注明「课时级降级（Minor-4 约定）」；编程错误伪装由 fail loud 定位兜底，接受 |
| Minor-4 | _maybeNotifyObjectiveMet 存在不可达分支 | 已重构 | 统一入口 _checkAndNotify 已消除（Blocker-1 修复时并入） |
| Minor-5 | circuit「有 inquiryTask 场景 SnackBar 仍弹」AC-R1 关键回归双零覆盖 | 推迟 | 代码评审 §3.0 逐行推演证明等价；T-P1-13 手动冒烟 ⑧ 项补验 |

## T-P1-13 手动冒烟清单（补 ⑧ 项）

1. 首页 circuit 组「开关与电路诊断」、色觉组「RGB 加色法」课时卡片；其余 6 sim 组视觉零变化（AC-R2）
2. circuit 课时：合闸 n1 → SnackBar 流转 → 修断路 n2 → 保险丝 n3（秒完成属预期）→ 完成视图 → 返回首页
3. 「电与光的探索」混合课时 circuit→色觉→circuit 双向流转（AC-58）
4. 剧本模式 circuit 屏 AppBar 场景下拉已隐藏（Major-3）
5. simple-series 补导线后 SnackBar 提示仍在（降级回归）
6. circuit 条件课时「欧姆定律与电路诊断」：预测题 3/3 → 挑战线；2/3 → 复习线
7. cv 课时：探索模式调出目标色 → 节点完成流转（Blocker-1 修复实证）
8. **simple-series（有 inquiryTask）在非剧本模式补导线 → SnackBar「探究目标已达成」仍弹（Minor-5 补验）**

## 资产修复记录（C-R2 豁免）

- 2026-08-25：`rgb-yellow-only.json` / `rgb-cyan-challenge.json` successCriteria 双目标互斥（先后状态写成同一瞬时态 allSatisfied）→ 判定永不可满足（既有资产 bug·独立模式同样存在）→ 改单一可满足目标（white / cyan）
- 性质：bug 修复，非编排功能改动 → 触发 C-R2「46 场景零改动」豁免（用户认可"场景本身不该这么搭"）
- 防线：scenarioPlayable 补「colorMatch 叶子 ≤1」静态规则（D10 强化）——未来同型 UNSAT 场景解析期拦截
- 同型存量：`rgb-default`（黄/品红/青三目标）仍 UNSAT——独立探索场景（判定不通过是现状·不影响自由玩），剧本引用会被新规则拦截；如未来需要它进剧本，需同样修单一目标
