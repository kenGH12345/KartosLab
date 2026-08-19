# 色觉单光源屏接入做中学探究抽屉 —— 笔记与沉淀

## 已确认发现

- D3 实证：`single_bulb_screen.dart:136-142` 仅有 `ExperimentIntroPanel`（未传 `onOpenInquiry`），全文件无 `InquiryDrawer` 引用；同模块 `rgb_bulbs_screen.dart` 已接入完整抽屉
- 色觉带 inquiryTask 的场景（rgb-inquiry-additive / rgb-challenge-basic）均绑定 RGB 屏，single_bulb 无探究场景
- 接入模式已通过 req-inquiry-extend（5 sim 推广）完全验证：model 加字段 + screen 接 InquiryDrawer + JSON 补 inquiryTask + snapshotProvider，四参数签名（task/columns/snapshotProvider/open）
- single_bulb 屏参数域：bulbMode(white/mono) + wavelength(nm) + filterType(none/red/green/blue/custom) → perceivedColor(reading)
- PRD §10.7 明确预测题目前仅 circuit/molarity 试点，single_bulb 暂无需 predictions → 进度条 2 节点
- req-color-vision-layout-fix 同文件改动，建议先完成布局修复再做本需求接入（改动正交但需序列化避免 merge 冲突）

## 开发踩坑

- 用例计数口误：iteration 首次汇报写"9 用例"，实际 `single_bulb_inquiry_test.dart` 含 **10 个**（1 unit + 9 widget，testWidgets×3 视口循环计 1 处定义 3 次执行）。教训：**汇报测试计数前先 `grep -c "testWidgets\|test(" 数一遍**，别凭印象报数（code-reviewer m-1 抓出，已在 ac-verification.md §三-1 勘误）。
- manifest 新增场景的 knock-on 易漏：`test/color_vision_l9_regression_test.dart` 场景数断言写死 10，新增第 11 个场景后必须同步 +1，否则回归立刻红。**后续任何需求动 manifest 场景数时，先全局搜 `10` 相关断言**。
- test-report 证据链文档（ac-verification.md + integration-test.log）在 agile-vibe iteration 阶段容易顺手漏掉，到 closing 被评审打回 Blocker 才补（B-1）。**建议 iteration 收工时即把 flutter test 输出重定向落盘**，零成本避免返工。

## 决策记录

- **D-1 默认场景切换（用户拍板）**：`color_vision_home.dart:37` 场景 ID 硬编码，single_bulb 屏又无场景菜单（X3）——新探究场景若不做 home fallback 就永远不可达，AC-1/3/5 端到端路径断裂。选择「默认场景切为 single-inquiry-subtractive + 双 findById fallback」而非「保持现状仅靠测试可达」：后者 AC 手动验证路径断裂，且 fallback 保证 JSON 缺失时回退现状不 crash。
- **入口按钮放 topRight**：spec AC-2 首选位；当前无占位（topCenter/center/footer/bottomRight 已占，topRight/midLeft/bottomLeft 空闲）；X3 排除场景菜单后无竞争。若未来加场景菜单再迁移按钮位置（低成本）。
- **snapshot 列设计 3 文本 + 1 条件数值**：bulbMode/wavelength/filter 为文本型 param，perceivedColor 为文本型 reading——导致 SnapshotChart 默认关系图无有效数值点显示空态文案。**这是组件契约行为非 bug**（design §5.2 R1），不擅自给 spec 已确认列设计加数值列；用户若要图表有点，属后续迭代。
- **F4 不做预测题**：PRD §10.7 预测题仅 circuit/molarity 试点 → 进度条 2 节点（L0 按 predictions 有无自动决定节点数，零开发）。

## 推迟的 Major 项

- 无（评审 Major 仅 M-1 commit 切分，属收尾执行动作非推迟项；已在 closer 阶段以切分提案闭环，等用户确认 commit）。

## 遗留 TODO

- **m-2（用户抽验点）**：AC-4 端到端手动抽验——启动 App → 色彩视觉 → 滤光镜 Tab → 应默认展开探究抽屉（默认加载「滤光片减色探究」）。等用户抽验。
- **n-2（非本需求）**：仓库根目录约 90 个调试 txt（a6.txt / wr.txt 等）建议清理或入 .gitignore。
- **n-1（Nit 已接受不改）**：single_bulb_inquiry_test.dart:164 注释「看到颜色：红色」实际断言的是英文 Red（ColorModel.colorName 返回英文名），断言正确仅注释措辞误导。

## 收尾沉淀（closer · 2026-08-19 15:30）

- **跨需求可复用经验**：
  1. 「L0 组件接入型需求」的验收铁三角——接入模式 1:1 对照先例屏（本次 rgb_bulbs_screen）+ L0 零改动 git 实证 + 纯观察场景回退安全性正负双例测试。三方齐了，评审基本一次过。
  2. **场景 ID 硬编码是 sim 类工程的隐形可达性陷阱**：新增场景 ≠ 可达，必须追「谁加载它」的调用链到 home/菜单层。tech-leader 方案阶段做 D-1 这类"spec 未覆盖点发现"并提请拍板，比收尾时发现死资产便宜一个数量级。
  3. **同文件多需求并行（本需求 vs layout-fix）的正交性论证范式**：按"改动域 = 屏内哪些结构"逐项对照（footer 内部结构 vs 外层 Stack 包裹），行级重叠面≈0 即可同工作区序列开发，无需机械等待。
- **对后续需求的提示**：涉及 `assets/scenarios/*/manifest.json` 增删场景时，检查对应 sim 的回归测试是否有硬编码场景计数断言（本工程至少 color_vision 的 l9_regression 有）；涉及 InquiryDrawer 新屏接入时，`test-report/ac-verification.md` 的 AC→test:line 引用表格式可直接复用（6 个先例需求已沉淀该惯例）。
- **失败模式提取脚本说明**：`.workflow/scripts/auto-extract-failures.sh` 在本工程（kratosLab）不存在（`.workflow/` 目录为空），SOP 步骤 1.5/4.5 的自动提取不适用；本节收尾沉淀为 closer 手工提炼的等价产物，已覆盖 process.txt 中的失败模式（B-1 证据链漏落盘 / m-1 计数口误）。
