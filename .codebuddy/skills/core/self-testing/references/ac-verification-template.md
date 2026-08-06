# AC 验证报告 · &lt;req-id&gt; · &lt;YYYY-MM-DD&gt;

> **模板来源**：`.codebuddy/skills/core/self-testing/references/ac-verification-template.md` (v0.2.0)
> **使用方式**：复制本文件到 `requirements/<req-id>/test-report/ac-verification.md`，替换尖括号占位符

---

## 概况

- **需求**: &lt;一句话描述&gt;
- **执行者**: &lt;agent-name / 主会话&gt;
- **执行时间**: &lt;YYYY-MM-DD HH:MM&gt; - &lt;YYYY-MM-DD HH:MM&gt;
- **产物启动方式**: `flutter test integration_test/<sim>_test.dart -d windows` / &lt;其他&gt;
- **integration_test log**: `test-report/integration-test.log`
- **单测框架**: &lt;flutter test / mvn test / 无&gt;

---

## 逐 AC 验证（v0.2.0 · 自动化优先）

### AC-1 · &lt;数据/交互类 AC 描述，从 spec 摘录&gt;

**AC 类型**：数据/交互类（integration_test 可覆盖）

**integration_test 断言引用**：
- `integration_test/<sim>_test.dart:23-45` · testWidgets("AC-1 · <desc>")
- 断言要点：`expect(find.text('X'), findsOneWidget)` + `tester.tap(...)` + `expect(model.value, equals(Y))`

**验证结果**：

| 断言 | 预期 | 实际 | 通过 |
|---|---|---|---|
| 初始状态 &lt;X&gt; | X | X | ✅ |
| 操作后应变 &lt;Y&gt; | Y | Y | ✅ |

**AC-1 总体结论**：✅ 通过（integration-test.log:12-18 显示 PASSED）

---

### AC-2 · &lt;视觉/美观类 AC 描述&gt;

**AC 类型**：视觉/美观类（integration_test 不可覆盖）

**状态**：未验证
**理由**：需人工抽验（视觉美观 · integration_test 无法自动化）
**可能风险**：&lt;例如：主图在窄视口下可能被挤压 / 教学卡片颜色对比度可能不足&gt;
**后续处置**：用户按需 `flutter run -d windows` 抽验 · 或转下个迭代补 golden_test

---

### AC-N · &lt;未验证的 AC 示例&gt;

**AC 类型**：&lt;数据/交互 / 视觉/美观&gt;
**状态**：未验证
**理由**：&lt;例如：需要真人多点触控 · integration_test 环境不支持 / 需要生产环境数据&gt;
**后续处置**：&lt;用户手动补验 / 转 test-runner agent 补做 / 下个迭代补&gt;

---

## 补充证据

### 单元测试（若适用）

- **框架**: flutter test / 无
- **结果**: 见 `unit-test.log`
- **摘要**: &lt;X passed / Y failed / Z skipped&gt;
- **失败详情**（如有）: &lt;引用 unit-test.log 具体行号&gt;

### 人工抽验（可选 · v0.2.0 起不强制）

> v0.2.0 变更：3 视口截图从强制降为可选 · AI 不主动索要 · 用户按需自行观察

- **是否抽验**: 否 / 是
- **抽验方式**（若是）: &lt;例如：用户 `flutter run -d windows` 自行观察 · 结果口头反馈&gt;
- **可选截图**（若用户主动截）:
  - `screenshots/&lt;sim&gt;-desktop.png` （非强制 · 用户按需）

---

## 汇总

| 维度 | 数量 |
|---|---|
| AC 总数 | N |
| ✅ integration_test 通过 | X |
| ⚠️ 通过带备注 | Y |
| ❌ 失败 | Z |
| 未验证（视觉/美观类，转人工抽验） | W |

---

## 诚实声明（v0.2.0 语义调整）

> **依据规则**：`.codebuddy/rules/60-citation-and-honesty.mdc` "报告测试结果时" + `agile-vibe.md` §阶段 3 第 9.4 条

- [ ] 每个 ✅ 的 AC 都由本会话真实跑通 integration_test 断言，非源码推理
- [ ] 所有 integration-test.log 均由本次运行产出（mtime 在 phase 3 期间），非历史缓存
- [ ] 未验证 / 部分失败的 AC 已在报告中显式标注（视觉/美观类明确标"需人工抽验"）

**签署**（agent-name / 主会话）: &lt;name&gt;
**签署时间**: &lt;YYYY-MM-DD HH:MM&gt;

---

## 附录：本次自测未覆盖的风险面（诚实告知）

&lt;如有 · 列出本次自测无法验证的边界，如：视觉美观 / 并发场景 / 大数据量 / 极端网络条件 / 无障碍工具兼容性 等&gt;
