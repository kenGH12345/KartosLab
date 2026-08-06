---
name: knowledge-base-generator
description: 用于在项目首次接入或代码库发生重大变更后，扫描源码目录生成结构化的项目知识库（context/project/<name>/），根据项目类型自动适配分类体系（游戏/后端/前端/嵌入式硬件/CLI工具等），包含 INDEX.md 入口索引。被主会话或 /kb-gen 命令调用。
tools: Read, Write, Edit, Glob, Grep, Bash, WebSearch
---

# knowledge-base-generator

> 这个 Skill 是 **「知识库优先」原则的起点**——它为项目生成第一版结构化知识库。
> 没有这个 Skill，AI 每次接手新项目都要从零 grep 源码，效率低下且容易遗漏关键模式。
> 生成的知识库应让一个不了解项目的 AI 在 5 分钟内读懂：项目怎么启动、有哪些核心模块、怎么新增一个功能。

## 何时使用

- ✅ 项目首次接入 AI 工作区，`context/project/<name>/INDEX.md` 不存在
- ✅ 代码库发生重大架构变更（如框架升级、模块重组），现有知识库严重过期
- ✅ 用户明确要求"生成项目知识库"或"扫描项目生成文档"
- ❌ 日常小范围文档补充——用 `managing-knowledge` Skill 增量回写
- ❌ 修改单个文档——直接编辑目标文件
- ❌ 纯代码需求（不涉及知识库建设）

## 输入

| 输入 | 类型 | 必需 | 说明 |
|---|:-:|---|
| project_name | string | ✓ | 项目名，决定 `context/project/<name>/` 根路径 |
| source_root | path | ✓ | 源码根目录绝对路径（如 `d:\MyProject\src`） |
| language | string | ✓ | 主要编程语言（c / cpp / csharp / go / typescript / python / rust / lua 等） |
| project_type | string | 否 | 显式指定项目类型（game / backend / web-frontend / cli-tool / embedded / data-ai），跳过自动检测 |
| framework_notes | string | 否 | 用户对框架的补充说明（如"基于 STM32 HAL 库"、"Express + Prisma"） |
| force_regenerate | bool | 否 | 默认 false；true = 即使 INDEX.md 已存在也重新生成 |

## 步骤

### 步骤 1：结构发现（Discovery）

**目标**：快速建立源码目录树的全局认知，不要一上来就深入读文件。

```
1. 运行 list_dir 扫描 source_root 的顶层目录（递归 ≤ 2 层）
2. 运行 search_files 找出关键入口文件（如 main.c、main.go、Program.cs、App.tsx、Makefile 等）
3. 运行 grep_search 定位框架级符号（入口函数、核心抽象类/接口、构建配置）
4. 记录发现到临时笔记：顶层模块列表、关键入口、命名约定
```

**产出**：一份"模块清单"，列出所有顶层模块及其子目录数和文件数估算。

### 步骤 2：分类决策（Classification）

**目标**：先检测项目类型，再按对应分类模板分桶。

#### 2.1 项目类型检测

从源码目录的特征中推断项目类型（按优先级）：

| 检测信号 | 判定类型 | 置信度 |
|---|---|---|
| 存在 `*.sln` + `Assets/` + `.csproj` + 大量 `.prefab` | 游戏（Unity） | 高 |
| 存在 `go.mod` + `main.go` + `cmd/` 目录 | 后端服务（Go） | 高 |
| 存在 `package.json` + `node_modules/` + 无 `public/index.html` | 后端服务（Node.js） | 高 |
| 存在 `package.json` + `src/App.tsx` 或 `index.html` | Web 前端 | 高 |
| 存在 `*.c`/`*.h` + `Makefile`/`CMakeLists.txt` + 无 `main()` | 嵌入式/硬件（C） | 中 |
| 存在 `*.c`/`*.h` + `Makefile`/`CMakeLists.txt` + `main.c` | CLI/工具（C） | 中 |
| 存在 `pyproject.toml`/`setup.py` + `src/` | Python 库/工具 | 高 |
| 存在 `Cargo.toml` + `src/main.rs` | CLI/工具（Rust） | 高 |
| 存在 `*.s`/`*.ld` 链接脚本 + 寄存器头文件 | 嵌入式/裸机（C/ASM） | 高 |
| 存在 `docker-compose.yml` + 多 `Dockerfile` | 微服务集群 | 中 |

**用户修正**：检测结果与用户声明（`framework_notes`/`language` 输入参数）冲突时，**以用户声明为准**。

#### 2.2 分类模板（按项目类型）

**通用分类**（所有项目类型均有）：
| 分类 | 目录名 | 说明 |
|---|---|---|
| 架构 | `architecture/` | 启动流程、核心抽象、设计模式、通用工具 |
| 约定 | `conventions/` | How-To 指南、编码规范、接入模板 |
| 系统 | `systems/` | 模块/服务索引表 + 核心模块深度文档 |

**类型特定分类**（按项目类型自动启用/禁用）：

| 分类 | 目录名 | 游戏 | 后端 | Web前端 | CLI/工具 | 嵌入式/硬件 | 数据/AI |
|---|---|---|---|---|---|---|---|
| 流程 | `flows/` | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| UI | `uictrl/` | ✅ | ❌ | ✅（改称 `frontend/`）| ❌ | ❌ | ❌ |
| 玩法 | `gameplay/` | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 硬件 | `hardware/` | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| 数据/模型 | `data/` | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |

**分类决策原则**（通用）：
- 每个分类至少要有 3 个文件才值得独立建目录，否则合并到 `architecture/`
- 只有上述表格标记 ✅ 的分类才创建目录
- 如果发现特殊领域（如编辑器工具、热更新、自动化测试），追加为独立分类

> 详细分类映射与硬件/嵌入式特定内容标准 → [category-classification-guide.md](references/category-classification-guide.md)

### 步骤 3：深度提取（Deep Extraction）—— 核心步骤

**目标**：对每个分类的每个子主题，从源码中提取结构化的技术事实。

**3.1 架构层提取清单**

对每个架构子主题，必须提取：

- [ ] **关键文件路径**（带行数、大小）
- [ ] **核心类/接口签名**（继承链、关键字段）
- [ ] **生命周期流程图**（用 mermaid sequenceDiagram，如果复杂）
- [ ] **注册/调用机制**（怎么被框架发现、怎么被外部访问）
- [ ] **设计模式标注**（如 partial class + lazy singleton、观察者、工厂等）
- [ ] **配置分类**：区分代码逻辑配置（System注册/事件定义，影响程序行为）、数据映射配置（协议ID/UI路径/上报ID，仅增删条目）、外部数据配置（表格，数据在XML/CSV，代码定义读取通道），三者不得合并到一个文档

**3.2 约定层提取清单**

每份 How-To 指南必须：

- [ ] 列出**前置条件**（需要哪些文件、哪些类）
- [ ] 给出**完整代码模板**（可直接复制粘贴修改）
- [ ] 标注**易错点**（如"ID 不能重复"、"必须在 `GetEventMap()` 注册"）
- [ ] 附 **5 步以内**的验证方法

**3.3 系统层提取清单**

- [ ] 首先生成**完整 System 索引表**（名称、文件路径、职责一句话、状态绑定）
- [ ] 对核心 System 做**深度提取**（同架构层清单）
- [ ] 非核心 System 只保留索引表条目

**3.4 UI 层提取清单**（仅游戏/Web前端项目，自动跳过不适用项目）

- [ ] 图形框架继承链图（如 UICtrl / React Component tree）
- [ ] 基础组件生命周期 hook 列表
- [ ] 通用 UI 组件列表（组件名、文件路径、核心 API、典型用法）
- [ ] 数据绑定/状态管理机制
- [ ] 虚拟列表/窗口化机制（如存在）
- [ ] **两层架构图**（UISystem 管理层 + UICtrl 视图层分离）：若检测到 `PPLuaSystemBase` + `PPLuaComponentBase` 双重继承模式，必须生成架构图（mermaid flowchart）与职责对照表
- [ ] **Property 类型速查表**：从 UICtrl 源码中提取 `self:Property(name, type)` 的实际 type 字符串及其对应 NGUI 组件（UILabel/UISprite/UIButton/GameObject/GameObject[]/UIGrid[]/FrameWindowController）
- [ ] **CreateUI/DestroyUI 模式**：从 UISystem 源码中提取 `resTool:CreateUI` / `DestroyUI` / `SetNGUIGameObjectActive` 的标准范式、单例复用模式与 LuaBehaviourNew 桥接
- [ ] **事件转发合约（Decision c1）**：若检测到 UICtrl → UISystem → 业务 System 三层转发模式（`CS.EventDelegate.Add` + `PPLib.PPLuaSystem.X:OnClickYYY()`），提取为标准文档段

**3.5 玩法层提取清单**（仅游戏项目，自动跳过不适用项目）

- [ ] 核心接口/抽象类定义
- [ ] 实现类继承树
- [ ] 数据模型/动力模型
- [ ] 关键算法（如有，描述思路 + 指向源码行号）

**3.6 流程层提取清单**（通用，所有项目类型）

- [ ] 时序图（mermaid sequenceDiagram）
- [ ] 关键类的角色（谁发起、谁处理、谁响应）
- [ ] 异常路径（超时、失败、重试）

**3.7 硬件层提取清单**（仅嵌入式/硬件项目，自动跳过不适用项目）

硬件项目有独特的提取维度，与软件项目差异巨大：

- [ ] **芯片/平台信息**：MCU 型号、架构（ARM Cortex-M/R、RISC-V、AVR 等）、数据手册引用
- [ ] **内存布局**：Flash/RAM 分区表、链接脚本（`.ld`）摘要、堆栈配置、DMA 区域
- [ ] **外设寄存器映射**：外设模块列表（GPIO/UART/SPI/I2C/TIM/ADC/DAC/PWM/CAN/USB）、寄存器基地址
- [ ] **中断向量表**：ISR 清单（中断号、处理函数名、优先级、触发源）
- [ ] **引脚配置**：引脚功能分配表（Pin → Function → Alternate Function → 方向）
- [ ] **时钟树**：时钟源（HSE/HSI/PLL）、总线频率（AHB/APB1/APB2）、外设时钟使能
- [ ] **启动流程**：复位向量 → SystemInit → main() 的完整链，含汇编启动文件分析
- [ ] **HAL/BSP 抽象层**：硬件抽象层 API 分类（初始化、读写、DMA、中断回调）
- [ ] **通信协议栈**：如存在协议实现（Modbus/CANopen/BLE profile/TCP-IP lwIP），提取状态机
- [ ] **RTOS 集成**（如适用）：任务列表（名称、优先级、栈大小、入口函数）、信号量/队列/互斥量清单
- [ ] **低功耗策略**：睡眠模式等级、唤醒源、功耗数据（如文档中有）
- [ ] **构建系统**：Makefile/CMake 的关键目标、编译选项、链接库、toolchain 路径

**3.8 数据/模型层提取清单**（仅数据/AI 项目，自动跳过不适用项目）

- [ ] 数据管道拓扑（数据源 → 清洗 → 特征 → 模型 → 输出）
- [ ] 模型架构（层结构、输入/输出 shape、参数量）
- [ ] 训练/推理配置（超参数、优化器、loss 函数）
- [ ] 数据 schema（表结构、字段类型、约束）

> [!IMPORTANT]
> 每个提取的事实都必须附**源码引用**（`<file>:<line>` 或 `view_code_item` 确认的函数名）。知识库文件里不允许出现"应该是"、"可能是"等不确定表述；**未经精确统计的数字断言**（如比例、耗时、数量）必须显式标注为"抽样估算"或改用范围表述（"少数/多数/绝大多数"），不允许写"~70%""约 300 个"等看似精确的假数字。

### 步骤 4：文档生成（Document Generation）

**目标**：把步骤 3 提取的事实写入标准化的 Markdown 文档。

**4.1 文件命名规则**

```
kebab-case，动词/名词短语，≤ 40 字符
正例: boot-sequence.md, how-to-add-module.md, interrupt-vector-table.md, api-middleware-chain.md
反例: GameRootCfgSummary.md, 如何添加模块.md
```

**4.2 文档标准模板**

每个知识库文档必须包含三个区域：

```markdown
# <标题：一句话概括本文档覆盖的范围>

> 来源: <如果是拆分自大文档则写原始来源>
> 创建时间: YYYY-MM-DD

## <第一个核心主题>

<正文：代码引用 + 表格 + 流程图>

## <第二个核心主题>

...

---
*<文件路径模式>*
```

**4.3 代码引用格式**

```markdown
**文件**：`src/core/boot.c`（12.5 KB，300+ 行）
```

**4.4 表格使用标准**

| 列数 | 适用场景 | 示例 |
|---|---|---|
| 3 列 | 属性/方法速查 | `字段名 | 类型 | 说明` |
| 4 列 | 生命周期对照 | `方法 | 调用时机 | 典型用途 | 标志位` |
| 2 列 | 简单映射 | `特性 | 说明` |

### 步骤 5：INDEX.md 生成（入口索引）

**目标**：生成 `context/project/<name>/INDEX.md`，作为 AI 检索知识库的入口。

**INDEX.md 必须包含**：

1. **目录树**（ASCII art，展示完整分类）
2. **文档清单表格**（文档路径 | 说明 | 最近更新）
3. **跨引用**（原始大文档路径、业务代码根路径、关联的 output/ 文档）

**INDEX.md 模板**：

```markdown
# <project_name> 项目知识库

> 本目录由 knowledge-base-generator 自动生成。
> 单一源原则：同一事实只在一处定义，其他位置用引用。
> 来源: <原始大文档路径或"首次扫描"> | 创建时间: YYYY-MM-DD
> 项目类型: <game / backend / web-frontend / cli-tool / embedded / data-ai>

## 目录结构
\`\`\`
context/project/<name>/
├── INDEX.md
├── architecture/          ← 总是需要
│   ├── overview.md
│   └── ...
├── flows/                 ← 条件：存在跨模块流程
│   └── ...
├── conventions/           ← 条件：存在固定接入模式
│   └── ...
├── systems/               ← 条件：模块/服务数量 > 5
│   └── ...
├── hardware/              ← 条件：嵌入式/硬件项目
│   └── ...
├── uictrl/ 或 frontend/   ← 条件：游戏/Web前端项目
│   └── ...
├── gameplay/              ← 条件：游戏项目
│   └── ...
└── data/                  ← 条件：数据/AI项目
    └── ...
\`\`\`
```
## 文档清单
| 文档 | 说明 | 最近更新 |
|---|---|---|
| ... | ... | YYYY-MM-DD |

## 跨引用
- 业务代码: `<source_root>`
```

### 步骤 6：质量验证（Quality Gate）

生成完成后，逐项自检：

- [ ] INDEX.md 存在且目录树与实际文件一致
- [ ] 每个 .md 文件都有 `# <标题>` 和创建时间
- [ ] 每个架构/系统文档都至少有 1 个 mermaid 图或 ≥ 2 个表格
  - [ ] 每份 How-To 指南都有可复制粘贴的代码模板
  - [ ] 每份 `conventions/*.md` 都有独立的"## 验证方法"段，内含 5 步以内的 checklist
  - [ ] 所有代码引用都有具体文件路径（不允许模糊的"在 X 模块中"）
  - [ ] 文件行数分布合理（单文件 50-400 行为佳，超过 500 行考虑拆分）
  - [ ] 没有"应该"、"可能"等猜测性表述（或已标注为 `[待验证]`）
  - [ ] 所有 `[text](path)` 引用的目标文件都存在于本知识库；指向尚未生成的知识库时必须标 `[待生成]`；指向外部源码时必须是绝对路径且存在

## 输出

- 产出目录：`context/project/<project_name>/`
- 核心产出：`INDEX.md` + 各分类目录下的所有 .md 文件
- 执行摘要给主会话：

```md
## knowledge-base-generator 执行结果
- 状态: completed / partial
- 产出: context/project/<project_name>/INDEX.md
- 项目类型: <game / backend / web-frontend / cli-tool / embedded / data-ai>
- 文件数: N 个（请按实际分类列出，如 architecture X / hardware Y / conventions Z / ...）
- 总行数: ~N 行
- 覆盖范围: <简述覆盖的模块>
- 未覆盖: <说明跳过或需要后续补充的部分>
- 下一步: 建议运行 managing-knowledge 建立增量维护基线
```

## 边界与陷阱

> [!IMPORTANT]
> **不允许**一次生成一个超过 2000 行的巨型 .md 文件。必须按分类拆分为独立文件。如果某个主题确实需要超长内容（如 560 个 System 的索引），控制在 500 行以内，用表格而非大段文字。

> [!WARNING]
> **不允许**跳过步骤 3 直接凭文件名猜测内容生成文档。每个文件的关键类/函数/寄存器必须从实际源码中读取确认。

> [!WARNING]
> **不允许**在业务层文档里写大段非技术描述。必须落到代码级——函数签名、数据结构、寄存器地址、中断向量号。

- ❌ 不要生成纯叙述性段落（"X 模块负责 Y" 而无代码引用）
- ❌ 不要生成没有 mermaid 图或表格的流程文档
- ❌ 不要为了"看起来完整"编造不存在的函数/寄存器/类；也不要为了"看起来精确"编造未验证的百分比/数量
- ❌ 不要超过 500 行仍不拆分（INDEX.md 除外）
- ❌ 不要在步骤 2 之前就开始写文档——先检测项目类型，再决定分类
- ❌ 不要对嵌入式项目强行套用"UI"/"玩法"等游戏分类
- ❌ 不要对后端项目生搬硬件层提取清单
- ✅ 每个分类目录生成完后，立即更新 INDEX.md（不要攒到最后）
- ✅ 遇到不确定的源码段，标注 `[待验证: <file>:<line>]` 而非猜测
- ✅ 发现代码模式与预期不符时，在 process.txt 记录偏差
- ✅ 硬件项目优先提取寄存器/中断/引脚，再提取软件架构

## 大型代码库处理策略

当源码目录 > 500 个文件或 > 50 个子目录时：

### 分层生成（按项目类型）

**游戏项目**：
```
第 1 层：框架层（architecture/ + flows/）—— 总是先生成，提供全局上下文
第 2 层：约定层（conventions/）—— 基于框架模式提取 how-to
第 3 层：UI 层（uictrl/）—— 如果项目有 UI 框架
第 4 层：系统层（systems/）—— 生成索引表即可，核心 System 选 3-5 个深度
第 5 层：玩法层（gameplay/）—— 最后，依赖框架上下文
```

**后端/服务项目**：
```
第 1 层：架构层（architecture/）—— 启动流程、中间件链、依赖注入、设计模式
第 2 层：流程层（flows/）—— API 请求生命周期、认证链、数据库事务流程
第 3 层：约定层（conventions/）—— 新增 API/新增中间件/数据库迁移模板
第 4 层：系统层（systems/）—— 服务/模块索引表 + 核心服务深度
```

**嵌入式/硬件项目**：
```
第 1 层：硬件层（hardware/）—— 芯片平台、内存布局、外设寄存器、中断表（最先，因软件依赖硬件）
第 2 层：架构层（architecture/）—— 启动流程（含汇编）、HAL/BSP 抽象、RTOS 任务拓扑
第 3 层：流程层（flows/）—— 中断处理流程、通信协议状态机、低功耗状态切换
第 4 层：约定层（conventions/）—— 新增外设驱动/新增 RTOS 任务/新增通信协议的模板
第 5 层：系统层（systems/）—— 驱动模块索引表 + 核心驱动深度
```

### 采样策略

对于数量超过 100 个的同类模块（如大量驱动文件、大量微服务、大量 System）：

1. 用 `search_files` + `grep_search` 生成**完整索引表**（名称 + 路径 + 职责推断）
2. 按**调用频率**选 Top 10 深度提取（grep 被引用次数最多的）
3. 按**框架/基础设施角色**补充（如中断系统、调度器、核心中间件等）
4. 其余模块仅保留索引表条目，标注 "详见源码"

## 引用资料

- [category-classification-guide.md](references/category-classification-guide.md) —— 分类决策树与各分类内容标准
- [document-template.md](references/document-template.md) —— 知识库文档标准模板与格式检查清单

## 关联 Skill

- 完成后通常调用 `docs-index-updater` 同步 INDEX
- 日常增量维护用 `managing-knowledge`
- 如需生成可视化图表（架构图、类图），可调用 `visual-doc-generator`
- 知识库生成过程中的进度日志通过 `progress-logger` 写入 process.txt

## 变更历史

| 日期 | 版本 | 变更 | 触发原因 | 操作者 |
|---|---|---|---|---|
| 2026-07-17 | 0.2.3 | §3.4 XLua 游戏项目 UI 提取清单扩展 4 条：(a) 两层架构图（UISystem+PPLuaComponentBase 双重继承检测）；(b) Property 类型速查表（7 种 NGUI 组件映射）；(c) CreateUI/DestroyUI 标准范式 + LuaBehaviourNew 桥接；(d) 事件转发合约 Decision c1（UICtrl→UISystem→业务 System 三层）；同步扩展 category-classification-guide.md uictrl/ 段 + document-template.md uictrl/ 格式检查 | req-tikatuka-mvp M7-UI-D 产出 uictrl-framework.md → 用户要求沉淀到 knowledge-base-generator skill 使其自动生成；3-Time Rule 第 3 次 UI 开发（M7-UI-A/B/C/D 共 5 轮） | 主会话 |
| 2026-07-15 | 0.2.2 | §6 门禁追加两项：(a) 跨引用有效性检查（未生成目标须标 `[待生成]`）；(b) `conventions/*.md` 必须有独立"## 验证方法"段；§3 事实性规则扩展到数字类断言（禁止假精确的 `~70%`/`约 300 个`），§边界与陷阱反模式补一行 | 首次全量审查 wepop-xlua 产物发现 3 类可预防缺陷：(1) INDEX/overview 出现指向未生成的 wepop-trunk 虚引用；(2) how-to-network-msg 缺验证方法段；(3) table-config-system 出现未验证的 ~70%/~30% 假精确数字 | 主会话 |
| 2026-07-15 | 0.2.1 | 架构层增加配置分类清单项：区分代码逻辑/数据映射/外部数据三类，禁止单文件混合；category-classification-guide 同步扩展配置系统拆分规则；document-template 追加配置文档格式检查 | 用户反馈配置合并文档过于简单，要求代码逻辑类配置与非代码配置分开展开为独立文档 | 主会话 |
| 2026-07-14 | 0.2.0 | 非游戏项目适配：新增 6 种项目类型分类模板（后端/前端/CLI/嵌入式/数据AI/游戏）、硬件项目完整提取清单（寄存器/中断/引脚/时钟树/内存布局/启动流程）、嵌入式文档格式规范 | 用户要求适配 C 语言硬件项目等非游戏项目 | 主会话 |
| 2026-07-14 | 0.1.0 | 初始创建，沉淀 wepop-trunk 全量知识库生成方法论 | 3-Time Rule：第 3 次全量生成知识库 | 主会话 |
