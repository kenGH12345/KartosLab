# 附录：inquiryTask（探究任务配置）

> **单一源文件**。本段由 `scripts/ai_scenario_gen/generate.py` 在组装 system prompt 时
> 自动拼接到每个 `docs/prompts/<sim>_scenario.md` 之后——**不要把内容复制进各 sim 的
> prompt**，否则会产生 8 份副本漂移。
>
> 契约权威源：`lib/common/widgets/inquiry_models.dart`（Dart model）
> 与各 `schemas/<sim>_scenario.schema.json` 的 `properties.inquiryTask`。

`inquiryTask` 驱动 app 右侧的**五阶段探究抽屉**：猜测 → 任务 → 操作 → 记录 → 归纳。
学生按阶段渐进解锁，一次只聚焦一件事。

- **省略该字段** = 纯观察场景，探究抽屉完全不显示（不报错）
- **配置该字段** = 学生完成"先猜 → 做 → 记 → 归纳"的完整探究闭环

## 1. 顶层字段

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `question` | string | 是 | 探究的核心问题，一句话。必须是**可探究的问题**而非陈述句 |
| `predictions` | array | 否 | 先猜后验预测题。**缺省则「猜测」阶段自动跳过** |
| `steps` | array | 否 | 操作步骤清单，建议 ≥ 2 条 |
| `snapshotColumns` | array | 否 | 记录表列定义。**缺省则学生无法记录数据**，「记录」「归纳」阶段将没有内容 |
| `referenceConclusion` | string | 否 | 参考结论。学生提交自己的结论后作为对照展示 |

## 2. predictions[] —— 猜测阶段

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `id` | string | 是 | 唯一标识，如 `p1` |
| `question` | string | 是 | 单选题干 |
| `options` | string[] | 是 | 2–4 个选项 |
| `answer` | int | 是 | 正确选项在 `options` 中的下标（**0 基**） |
| `explanation` | string | 否 | 验证后展示的原理解析 |

设计要求：

- **针对典型迷思概念（misconception）出题**，不要考记忆性事实
- 每题只聚焦一个变量关系，不要把多个概念塞进一题
- `explanation` **强烈建议填写**——学生答错时这是唯一的纠正反馈
- 交互行为：学生答一题 → 立即显示判定 + 解析 → 1.5 秒后自动进入下一题；全部答完才解锁「任务」阶段

## 3. steps[] —— 任务阶段

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `id` | string | 是 | 唯一标识，如 `s1` |
| `instruction` | string | 是 | 一句话操作指令，**动词开头** |
| `hint` | string | 否 | 学生卡住时的提示 |

## 4. snapshotColumns[] —— 记录阶段

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `key` | string | 是 | 取值键名，**必须是本 sim 真实存在的参数/读数键** |
| `label` | string | 是 | 表头显示名，建议带单位，如 `电流(A)` |
| `source` | enum | 是 | `param`（学生可调参数）或 `reading`（仪器读数 / 计算量） |

约束：

- 至少 1 个 `param` + 1 个 `reading`——否则记录表无法体现"自变量 vs 因变量"
- **恰好 2 列时 app 自动生成关系图**（第 1 列为 X 轴、第 2 列为 Y 轴），这是最推荐的配置
- `key` 必须与本 sim 的 model 字段对应，**不可臆造**（对不上会记录为空值）
- 单次探究最多记录 20 组数据

## 5. 完整示例

```json
{
  "inquiryTask": {
    "question": "保持电压不变，改变电阻，电流会如何变化？",
    "predictions": [
      {
        "id": "p1",
        "question": "电压不变时，把电阻从 5Ω 换成 50Ω，电流会？",
        "options": ["变大", "变小", "不变"],
        "answer": 1,
        "explanation": "由 I = U / R，电压不变时电阻越大电流越小，两者成反比。"
      }
    ],
    "steps": [
      { "id": "s1", "instruction": "把电压固定在 6V", "hint": "拖动电压滑块" },
      { "id": "s2", "instruction": "依次把电阻调到 5Ω / 10Ω / 20Ω，每次记录电流" }
    ],
    "snapshotColumns": [
      { "key": "resistance", "label": "电阻(Ω)", "source": "param" },
      { "key": "current", "label": "电流(A)", "source": "reading" }
    ],
    "referenceConclusion": "电压不变时，电流与电阻成反比：电阻越大，电流越小。"
  }
}
```

## 6. 自查清单

- [ ] `question` 是可探究的**问题**（不是陈述句）
- [ ] 若有 `predictions`：每题 `answer` 下标落在 `options` 范围内（0 基）
- [ ] 若有 `predictions`：题目针对迷思概念，且填了 `explanation`
- [ ] 若有 `snapshotColumns`：含 ≥1 个 `param` + ≥1 个 `reading`
- [ ] 若有 `snapshotColumns`：所有 `key` 都是本 sim model 里真实存在的字段
- [ ] 优先配成**恰好 2 列**以触发自动关系图
- [ ] `steps` ≥ 2 条（若提供）
- [ ] 所有文案为简体中文
