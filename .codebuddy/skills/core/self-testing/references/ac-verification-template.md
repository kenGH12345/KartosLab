# AC 验证报告 · &lt;req-id&gt; · &lt;YYYY-MM-DD&gt;

> **模板来源**：`.codebuddy/skills/core/self-testing/references/ac-verification-template.md`
> **使用方式**：复制本文件到 `requirements/<req-id>/test-report/ac-verification.md`，替换尖括号占位符

---

## 概况

- **需求**: &lt;一句话描述&gt;
- **执行者**: &lt;agent-name / 主会话&gt;
- **执行时间**: &lt;YYYY-MM-DD HH:MM&gt; - &lt;YYYY-MM-DD HH:MM&gt;
- **产物启动方式**: `flutter run -d windows` / `npm run dev` / &lt;其他&gt;
- **单测框架**: &lt;flutter test / mvn test / 无&gt;

---

## 逐 AC 验证

### AC-1 · &lt;AC 描述，从 spec 摘录&gt;

**用户操作路径**：
1. 启动 sim → 默认状态 → 截图 `ac-1-step-1-init.png`
2. &lt;操作 2 的具体描述&gt; → 截图 `ac-1-step-2-&lt;desc&gt;.png`
3. &lt;操作 3 的具体描述&gt; → 截图 `ac-1-step-3-&lt;desc&gt;.png`

**验证结果**：

| 步骤 | 预期 | 实际 | 证据 | 结论 |
|---|---|---|---|---|
| 1 | 默认呈 &lt;X&gt; 状态 | 确认呈 &lt;X&gt; | `ac-1-step-1-init.png` | ✅ |
| 2 | 应发生 &lt;Y&gt; | 确认发生 &lt;Y&gt; | `ac-1-step-2-*.png` | ✅ |
| 3 | 应发生 &lt;Z&gt; | 实际略偏差 &lt;desc&gt; | `ac-1-step-3-*.png` | ⚠️ 已记入 notes.md |

**AC-1 总体结论**：✅ 通过 / ⚠️ 通过带备注 / ❌ 失败

---

### AC-2 · &lt;AC 描述&gt;

（同上结构 · 略）

---

### AC-N · &lt;未验证的 AC 示例&gt;

**状态**：未验证
**理由**：&lt;例如：需要真人多点触控 · 本次会话环境不支持 / 需要生产环境数据 · 本地无法复现 / 需要跨设备联调&gt;
**后续处置**：&lt;例如：用户手动补验 / 转 test-runner agent 补做 / 下个迭代补&gt;

---

## 补充证据

### 代码测试（若适用）

- **框架**: flutter test / 无
- **结果**: 见 `code-test.log`
- **摘要**: &lt;X passed / Y failed / Z skipped&gt;
- **失败详情**（如有）: &lt;引用 code-test.log 具体行号&gt;

### 视觉回归（若 UI 改动）

- **触发原因**: 改动涉及 `lib/&lt;sim&gt;/screens/&lt;file&gt;.dart`
- **3 视口截图**:
  - `screenshots/&lt;sim&gt;-mobile-portrait.png` （375×667）
  - `screenshots/&lt;sim&gt;-tablet-landscape.png` （1024×768）
  - `screenshots/&lt;sim&gt;-desktop.png` （1920×1080）
- **溢出/警戒条纹**: 无 / 有（列具体视口 + 详情）

---

## 汇总

| 维度 | 数量 |
|---|---|
| AC 总数 | N |
| ✅ 通过 | X |
| ⚠️ 通过带备注 | Y |
| ❌ 失败 | Z |
| 未验证 | W |

---

## 诚实声明

> **依据规则**：`.codebuddy/rules/60-citation-and-honesty.mdc` "报告测试结果时" + `agile-vibe.md` §阶段 3 强制约束第 9.4 条

- [ ] 每个 ✅ 的 AC 都由本会话真实操作产物完成，非源码推理
- [ ] 所有截图均由本次运行产出（mtime 在 phase 3 期间），非历史缓存
- [ ] 未验证 / 部分失败的 AC 已在报告中显式标注

**签署**（agent-name / 主会话）: &lt;name&gt;
**签署时间**: &lt;YYYY-MM-DD HH:MM&gt;

---

## 附录：本次自测未覆盖的风险面（诚实告知）

&lt;如有 · 列出本次自测无法验证的边界，如：并发场景 / 大数据量 / 极端网络条件 / 无障碍工具兼容性 等&gt;
