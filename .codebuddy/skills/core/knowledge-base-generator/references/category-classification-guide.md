# 分类决策指南

> 用于 knowledge-base-generator 步骤 2 的分类决策。
> 本文档定义：每个分类应该包含什么、不应该包含什么、以及边界模糊时的判定规则。

## 分类决策树

```
源码模块
├── 是框架级基础设施？（启动/事件/数据/配置/资源）
│   └── → architecture/
├── 是跨模块交互流程？（通信/网络/登录/重连）
│   └── → flows/
├── 是开发操作手册？（how-to 类）
│   └── → conventions/
├── 是业务 System？（登录/网络/社交/背包...）
│   └── → systems/
├── 是 UI 控制层？（UICtrl/View/组件）
│   └── → uictrl/
├── 是核心玩法机制？（赛车/道具/AI/物理...）
│   └── → gameplay/
└── 不属于以上 → 考虑新增分类或归入 architecture/
```

## 各分类内容标准

### architecture/ —— 架构层

**应该包含**：
- 项目概览（三层架构、启动流程、核心概念）
- 框架生命周期（GameRoot、状态机、初始化链）
- 事件系统（注册/派发/注销机制）
- 数据层（MVC 模型、数据绑定、缓存策略）
- 配置系统（必须按数据归属拆为三类独立文档，禁止单文件混合）：
  - `config-files.md` 总览：三类对比表 + "我应该看哪个文档"决策表
  - `system-registration.md` 代码逻辑类：System/State 注册、事件定义、Enum 映射
  - `data-configs.md` 数据映射类：协议ID、UI路径、红点ID、上报ID
  - `table-config-system.md` 外部数据类：加载管线 + 管理层缓存 + 双模式读取 + 决策树
- 资源管理（加载器架构、资源生命周期）
- 设计模式（项目中实际使用的模式及示例）
- 通用工具类（单例、对象池、字典工具、协程工具）

**不应该包含**：
- 具体 UI 界面实现 → uictrl/
- 具体业务玩法逻辑 → gameplay/
- 网络协议细节 → flows/ 或 systems/network-system.md

**判断标准**：这个类/模块是否被 ≥ 3 个业务 System 使用？是 → architecture/

### flows/ —— 流程层

**应该包含**：
- 跨 System 通信方式对比与选型
- 网络协议收发完整流程（含时序图）
- 登录/重连/断线重连流程
- 资源热更新流程
- 关键业务流程（如匹配、结算）

**不应该包含**：
- 单个 System 内部的流程 → 放在对应 architecture/ 或 systems/ 文档中
- UI 打开关闭流程 → conventions/ 或 uictrl/

**判断标准**：这个流程是否涉及 ≥ 2 个不同的 System/模块协作？是 → flows/

### conventions/ —— 约定层

**应该包含**：
- 新增 System 完整模板
- 新增 State/状态机节点
- 打开/关闭 UI 标准流程
- 发送/处理网络消息模板
- 配置表新增流程
- 命名约定

**不应该包含**：
- 框架原理说明 → architecture/
- 具体 System 的业务逻辑 → systems/

**判断标准**：能否让一个新人照着文档做完一件事？是 → conventions/

### systems/ —— 系统层

**应该包含**：
- 完整 System 索引表（名称 + 路径 + 职责 + 状态绑定）
- 核心 System 深度文档（架构层清单级别的深度）
- 业务 System 间的依赖关系

**不应该包含**：
- 框架级 System 的深度文档 → architecture/（但在 systems/ 索引表中保留条目，写"详见 architecture/"）

**判断标准**：这个 System 是框架基础设施还是业务功能？框架级 → architecture/ 深度，systems/ 索引；业务级 → systems/ 深度

### uictrl/ —— UI 控制层

**应该包含**：
- **UI 框架核心**：UISystem（管理层）+ UICtrl（视图层）两层架构、Property 类型速查表、CreateUI/DestroyUI 生命周期、事件转发合约（Decision c1）
- UICtrl 继承链（全貌图）
- BaseUICtrl 生命周期所有 hook
- 通用 UI 组件（不是具体界面，是可复用的组件）
- 数据绑定机制（ModelViewBehaviour）
- 虚拟列表/对象池 UI 优化

**不应该包含**：
- 具体界面逻辑（如"登录界面怎么布局"） → 不放知识库，需求时直接读源码
- UI 框架底层原理 → architecture/

**判断标准**：这个内容是否对"开发任何新 UI"都有帮助？是 → uictrl/

### gameplay/ —— 玩法层

**应该包含**：
- 核心接口/抽象类定义与继承树
- 数据模型/动力模型
- 关键算法思路（非实现细节）
- 玩法模块间的交互关系

**不应该包含**：
- 具体数值表 → 不放知识库，这是配置数据
- UI 表现逻辑 → uictrl/
- 通用框架内容 → architecture/

**判断标准**：这个内容是否只在特定玩法中存在？是 → gameplay/

## 边界模糊场景判定

| 模糊场景 | 判定 | 理由 |
|---|---|---|
| 网络协议定义 vs 网络消息发送 | 协议定义 → flows/network-protocol.md；消息发送模板 → conventions/how-to-network-msg.md | 前者是原理，后者是操作 |
| 配置表结构 vs 配置加载流程 | 结构 → architecture/config-system.md；加载 → architecture/config-loading.md | 同属架构，但拆分避免单文件过长 |
| System 事件监听 vs 事件系统本身 | System 监听 → 写在对应 System 文档里；事件系统 → architecture/event-system.md | 各自归属 |
| 通用 UI 组件 vs 具体界面 UI | 通用组件 → uictrl/uictrl-common-components.md；具体界面 → 不写入知识库（按需读源码） | 知识库不存业务界面细节 |

## 合并策略

当某个分类的候选内容 < 3 个时：

| 候选数 | 处理方式 |
|---|---|
| 0 | 不创建该分类目录 |
| 1-2 | 归入 architecture/ 或生成单文件放在根目录（如 `network.md`） |
| ≥ 3 | 独立建目录 |

> [!IMPORTANT]
> 宁可少建目录也不要为了"看起来完整"凑内容。分类是为检索效率服务，不是为审美服务。

---

# 非游戏项目适配（Project Type Adaptation）

> 本章是知识库生成器的"类型适配层"。AI 在步骤 2 完成项目类型检测后，按本章对应类型的分类模板执行。
> 原则：通用分类（architecture/ conventions/ systems/ flows/）的结构不变，但**内容标准按项目类型调整**。

## 项目类型检测规则

| 检测信号 | 类型 | 置信度 |
|---|---|---|
| `*.c`/`*.h` + 链接脚本(`*.ld`) + 寄存器头文件 + 无 `main()` 或 main 只做初始化 | 嵌入式/硬件 | 高 |
| `*.c`/`*.h` + `Makefile`/`CMakeLists.txt` + `main.c` + 命令行参数解析 | CLI/工具（C） | 高 |
| `*.c`/`*.h` + socket 编程 + `fork()`/`epoll` + 无 GUI 依赖 | 后端服务（C） | 中 |
| `go.mod` + `cmd/` + `internal/` | 后端服务（Go） | 高 |
| `package.json` + `express`/`koa`/`fastify` 依赖 | 后端服务（Node.js） | 高 |
| `package.json` + `react`/`vue`/`angular` 依赖 + `index.html` | Web 前端 | 高 |
| `pyproject.toml` + `fastapi`/`django`/`flask` 依赖 | 后端服务（Python） | 高 |
| `pyproject.toml` + `torch`/`tensorflow`/`jax` 依赖 | 数据/AI | 高 |
| `Cargo.toml` + `src/main.rs` + `clap`/`structopt` | CLI/工具（Rust） | 高 |
| `*.sln` + `Assets/` + `.csproj` | 游戏（Unity） | 高 |

## 各项目类型的分类模板

### 类型 1：后端服务（Backend Service）

```
context/project/<name>/
├── INDEX.md
├── architecture/          ← 启动流程、依赖注入、中间件链、设计模式、通用工具
├── flows/                 ← API 请求生命周期、认证/授权链、数据库事务、消息队列消费
├── conventions/           ← 新增 API 端点、新增中间件、数据库迁移、错误处理约定
└── systems/               ← 服务/模块索引表 + 核心服务深度（3-5 个）
```

**architecture/ 特有内容**：
- 中间件注册顺序与洋葱模型（mermaid flowchart）
- 依赖注入容器配置
- 数据库连接池配置
- 配置管理（环境变量/配置文件加载优先级）
- 日志/追踪/指标三板斧

**conventions/ 特有内容**：
- 新增 REST/gRPC 端点完整模板（路由注册 → Handler → Service → Repository）
- 新增数据库迁移脚本模板
- 错误码体系与 HTTP 状态码映射表
- 分页/过滤/排序查询参数标准

### 类型 2：Web 前端（Web Frontend）

```
context/project/<name>/
├── INDEX.md
├── architecture/          ← 路由设计、状态管理、构建配置、设计模式
├── flows/                 ← 页面加载生命周期、SSR/CSR 渲染流程、API 请求拦截链
├── conventions/           ← 新增页面、新增组件、新增 API 调用、样式约定
├── systems/               ← 页面/模块索引表
└── frontend/              ← 组件树、基础组件库、布局系统、主题/样式变量
```

**frontend/（替代游戏的 uictrl/）特有内容**：
- 组件树（App → Layout → Page → Section → Component）
- 基础组件清单（Button/Input/Modal/Table/Form 等，含 Props 表）
- 路由配置表（路径 → 页面组件 → 权限 → 懒加载标记）
- 状态管理 store 结构（如 Redux slice / Zustand store / Pinia store）
- 主题变量表（颜色/间距/字体/断点）

### 类型 3：CLI/工具（CLI Tool）

```
context/project/<name>/
├── INDEX.md
├── architecture/          ← 命令注册与路由、参数解析、配置加载、插件系统
├── flows/                 ← 命令执行流程、错误处理与退出码、信号处理
├── conventions/           ← 新增子命令、新增参数/标志、输出格式约定
└── systems/               ← 子命令索引表
```

**architecture/ 特有内容**：
- 命令树（如 `app → subcmd1 → flag1, flag2`）
- 信号处理策略（SIGINT/SIGTERM/SIGHUP）
- stdout/stderr 输出约定（JSON/plain/color 模式）
- 配置文件发现优先级（环境变量 > 本地 .config > 全局 /etc）

### 类型 4：嵌入式/硬件（Embedded / Hardware）★ 新增

```
context/project/<name>/
├── INDEX.md
├── hardware/              ← 芯片平台、内存布局、外设寄存器、中断向量表、引脚配置、时钟树
├── architecture/          ← 启动流程（含汇编）、HAL/BSP 抽象、RTOS 拓扑、构建系统
├── flows/                 ← 中断处理流程、通信协议状态机、低功耗状态切换、DMA 传输链
├── conventions/           ← 新增外设驱动、新增 RTOS 任务、新增通信协议、调试方法
└── systems/               ← 驱动模块索引表 + 核心驱动深度（3-5 个）
```

#### hardware/ 内容标准（嵌入式项目特有）

##### 1. 芯片平台文档（chip-platform.md）
```markdown
# 芯片平台

> 创建时间: YYYY-MM-DD

## MCU 规格
| 属性 | 值 |
|---|---|
| 型号 | STM32F407VGT6 |
| 架构 | ARM Cortex-M4 |
| 主频 | 168 MHz |
| Flash | 1 MB |
| SRAM | 192 KB |
| 封装 | LQFP-100 |
| 数据手册 | [RM0090](<url>) |

## 启动模式
| BOOT0 | BOOT1 | 启动源 |
|---|---|---|
| 0 | X | Main Flash |
| 1 | 0 | System Memory (Bootloader) |
| 1 | 1 | Embedded SRAM |
```

##### 2. 内存布局文档（memory-layout.md）
```markdown
# 内存布局

> 创建时间: YYYY-MM-DD

## Flash 分区
| 区域 | 起始地址 | 大小 | 用途 |
|---|---|---|---|
| Bootloader | 0x08000000 | 32 KB | 第一级启动 |
| Application | 0x08008000 | 448 KB | 主程序 |
| Config | 0x08078000 | 16 KB | 用户配置 |
| EEPROM Emul. | 0x0807C000 | 16 KB | 模拟 EEPROM |

## SRAM 分区
| 区域 | 起始地址 | 大小 | 用途 |
|---|---|---|---|
| .data/.bss | 0x20000000 | 128 KB | 全局/静态变量 |
| Heap | 0x20020000 | 32 KB | 动态分配 |
| Stack | 0x20028000 | 32 KB | 调用栈 |
```

##### 3. 外设寄存器映射文档（peripheral-register-map.md）
```markdown
# 外设寄存器映射

> 创建时间: YYYY-MM-DD

## 外设基地址
| 外设 | 总线 | 基地址 | 时钟使能位 |
|---|---|---|---|
| GPIOA | AHB1 | 0x40020000 | RCC_AHB1ENR[0] |
| USART1 | APB2 | 0x40011000 | RCC_APB2ENR[4] |
| SPI1 | APB2 | 0x40013000 | RCC_APB2ENR[12] |
| TIM2 | APB1 | 0x40000000 | RCC_APB1ENR[0] |
| ADC1 | APB2 | 0x40012000 | RCC_APB2ENR[8] |

## 关键寄存器（以 USART1 为例）
| 寄存器 | 偏移 | 位宽 | 说明 |
|---|---|---|---|
| USART_SR | 0x00 | 32 | 状态寄存器（TXE/TC/RXNE） |
| USART_DR | 0x04 | 32 | 数据寄存器 |
| USART_BRR | 0x08 | 32 | 波特率寄存器 |
| USART_CR1 | 0x0C | 32 | 控制寄存器 1（UE/TE/RE） |
```

##### 4. 中断向量表文档（interrupt-vector-table.md）
```markdown
# 中断向量表

> 创建时间: YYYY-MM-DD

| 位置 | 优先级 | IRQ 号 | 处理函数 | 触发源 | 用途 |
|---|---|---|---|---|---|
| 0x0040 | 0 | 0 | `WWDG_IRQHandler` | 窗口看门狗 | 系统保护 |
| 0x0058 | 5 | 6 | `EXTI0_IRQHandler` | 外部中断线 0 | 按键输入 |
| 0x00D8 | 10 | 37 | `USART1_IRQHandler` | USART1 全局 | 串口收发 |
| 0x0118 | 15 | 53 | `TIM2_IRQHandler` | 定时器 2 | 1ms 系统滴答 |
| 0x0130 | 8 | 59 | `DMA1_Stream0_IRQHandler` | DMA1 流 0 | ADC 数据传输 |
```

##### 5. 引脚配置文档（pin-configuration.md）
```markdown
# 引脚配置

> 创建时间: YYYY-MM-DD

| Pin | 功能 | 复用功能 | 方向 | 上拉/下拉 | 最大速度 | 备注 |
|---|---|---|---|---|---|---|
| PA0 | GPIO Input | - | Input | Pull-up | - | 按键 1 |
| PA2 | USART2_TX | AF7 | AF Push-Pull | - | 50 MHz | 调试串口 |
| PA3 | USART2_RX | AF7 | AF Input | Pull-up | 50 MHz | 调试串口 |
| PA5 | SPI1_SCK | AF5 | AF Push-Pull | - | 50 MHz | SPI Flash |
| PC13 | GPIO Output | - | Output PP | - | 2 MHz | LED 指示 |
```

##### 6. 时钟树文档（clock-tree.md）
```markdown
# 时钟树

> 创建时间: YYYY-MM-DD

## 时钟源
| 时钟 | 频率 | 来源 | 用途 |
|---|---|---|---|
| HSE | 8 MHz | 外部晶振 | PLL 输入 |
| HSI | 16 MHz | 内部 RC | 启动/安全时钟 |
| PLLCLK | 168 MHz | HSE × PLL | SYSCLK 主时钟 |
| LSE | 32.768 kHz | 外部晶振 | RTC |

## 总线频率
| 总线 | 频率 | 分频 | 挂载外设 |
|---|---|---|---|
| AHB (HCLK) | 168 MHz | /1 | 内核、DMA、GPIO |
| APB1 (PCLK1) | 42 MHz | /4 | TIM2-7, USART2-5, SPI2-3, I2C |
| APB2 (PCLK2) | 84 MHz | /2 | TIM1/8, USART1/6, SPI1, ADC |
```

#### architecture/ 内容标准（嵌入式项目特有）

与通用架构层的差异：
- 不只是"软件架构"，而是**硬件-软件接口架构**
- **启动流程必须包含汇编阶段**（reset_handler → SystemInit → main），不能只从 main() 开始
- "通用工具类"在嵌入式项目中是 ring buffer、CRC 校验、位操作宏、临界区保护等

```markdown
# 启动流程

## 汇编启动阶段（startup_xxx.s）
1. 设置初始堆栈指针（SP = _estack）
2. 跳转 Reset_Handler
3. Reset_Handler：调用 SystemInit() 配置时钟
4. 复制 .data 段（Flash → SRAM）
5. 清零 .bss 段
6. 调用 __libc_init_array()（C 运行时初始化）
7. 跳转 main()

## C 启动阶段（main.c）
1. HAL_Init()：HAL 库初始化
2. SystemClock_Config()：配置系统时钟
3. 外设初始化：GPIO / USART / SPI / TIM / ADC ...
4. RTOS 初始化（如使用）：osKernelInitialize()
5. 创建任务/队列/信号量
6. osKernelStart()：启动调度器
```

#### flows/ 内容标准（嵌入式项目特有）

典型流程文档选题：
- 中断处理全流程（硬件触发 → NVIC → ISR → 任务通知 → 应用处理）
- DMA 传输链（外设 → DMA → 内存 → 回调 → 应用）
- 通信协议状态机（Modbus RTU slave 状态机：IDLE → 接收地址 → 接收功能码 → 接收数据 → CRC 校验 → 执行 → 响应）
- 低功耗唤醒链（SLEEP → 外部中断唤醒 → 时钟恢复 → 外设重初始化 → 恢复任务）

#### conventions/ 内容标准（嵌入式项目特有）

每一份 how-to 必须包含完整的 `.c` + `.h` 代码模板：

1. **新增外设驱动**：`peripheral_init()` + `peripheral_deinit()` + 中断回调 + DMA 配置
2. **新增 RTOS 任务**：任务函数签名 + 栈大小计算 + 优先级选择依据 + 创建代码
3. **新增通信协议**：协议帧结构体 + 解析状态机 + 超时处理 + CRC 校验
4. **调试方法**：J-Link/SWD 连接、逻辑分析仪引脚选择、printf 重定向到串口

### 类型 5：数据/AI（Data / AI Pipeline）

```
context/project/<name>/
├── INDEX.md
├── architecture/          ← 数据管道拓扑、模型架构、服务部署、设计模式
├── flows/                 ← 数据流（源→清洗→特征→训练→评估→部署）、推理请求生命周期
├── conventions/           ← 新增数据源、新增模型、新增特征、实验追踪
├── systems/               ← 数据源/模型/服务索引表
└── data/                  ← 数据 schema、特征定义、模型配置、评估指标
```

**data/ 特有内容**：
- 数据 schema 表（表名 → 字段 → 类型 → 约束 → 示例值）
- 特征 engineering 配置（特征名 → 来源 → 变换 → 重要性）
- 模型配置（架构 → 超参数 → 输入/输出 shape → 训练环境）
- 评估指标定义与阈值

### 类型 6：游戏（Game）— 保持原有

```
context/project/<name>/
├── INDEX.md
├── architecture/          ← 框架启动、事件系统、数据层、配置加载、资源管理
├── flows/                 ← 跨系统通信、网络协议、登录/重连
├── conventions/           ← 新增 System、新增 State、打开 UI、网络消息
├── systems/               ← System 索引表 + 核心 System 深度
├── uictrl/                ← UICtrl 继承链、BaseUICtrl 生命周期、通用 UI 组件
└── gameplay/              ← 核心玩法机制（赛车/道具/AI/物理）
```

## 跨类型边界场景

| 场景 | 判定 |
|---|---|
| C 语言网络服务（lwIP + socket + epoll） | 如果运行在 MCU 上 → 嵌入式/硬件；如果运行在 Linux → 后端服务（C） |
| Python 项目同时有 FastAPI + 数据处理 | 按主要用途判定：对外提供 API → 后端服务；主要做训练 → 数据/AI |
| Rust 嵌入式（no_std） | 嵌入式/硬件，不按 Cargo.toml 判定为 CLI |
| 游戏项目含 C native plugin | 仍按游戏分类，C 代码作为 gameplay/ 的技术子文档 |

---

*本指南最后更新：2026-07-15*
