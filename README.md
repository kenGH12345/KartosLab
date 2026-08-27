# kratos · PhET 风格物理/化学学习模拟

> 原生 Flutter 交互式教学模拟（interactive simulations），PhET 风格，面向中小学物理/化学课堂。
> 跨平台：Web · Android · iOS · Windows · macOS · Linux。

kratos 是一组**可拖拽、可交互、场景化**的物理/化学模拟实验。学生像在真实实验室一样搭电路、调透镜、配溶液——每个实验都带教学目标（成功判定）、可配置场景（JSON）与预测验证闭环。

---

## ✨ 特性

- **8 个主题模拟**（分属物理/化学两大学科），全部支持拖拽交互与场景切换
- **课时剧本（lesson plan）**：用一份 JSON"剧本"把多个实验串成一节课——顺序解锁、按预测题得分分支、跨 sim 混排（如"电路 → 色觉 → 电路挑战"）
- **AI 可生成**：所有场景与剧本由 JSON 定义 + JSON Schema 校验 + 生成 prompt（`docs/prompts/`），AI 可生成、可校验、可运行
- **配置化优先**：实验参数、判定条件、剧本流程全部外置为配置，业务代码零硬编码
- **统一交互框架**：`DragDropWorkspace`（拖拽工作区）+ `NineGridLayout`（九宫格屏幕适配）+ `PropertyControlPanel`（属性面板）跨 sim 复用

---

## 🧪 模拟清单

### 物理（Physics）

| 模拟 | 主题 | 说明 |
|---|---|---|
| ⚡ 电路搭建 | 电学与电路 | 串并联 · 电流路径 · 灯泡亮度（图论求解） |
| 🔦 几何光学 | 光学与波动 | 透镜 · 镜面 · 成像 · 光线追迹 |
| 🌈 色觉 | 光学与波动 | RGB 合成 · 滤光 · 单色光 |
| 🌊 波的干涉 | 光学与波动 | 双缝 · 叠加原理 |
| 🔊 声波 | 光学与波动 | 频率 · 振幅 · 波形 |
| 📡 电磁波 | 光学与波动 | 天线 · 传播 |
| 🏃 力与运动 | 力学 | 合力 · 摩擦 · 加速度（1D 牛顿力学） |

### 化学（Chemistry）

| 模拟 | 主题 | 说明 |
|---|---|---|
| 🧪 摩尔浓度 | 溶液与浓度 | 溶液配比 · 浓度计算 |

### 课时剧本（教学编排层）

在任一学科首页可见「课时」入口卡片：老师（或 AI）用一份 lesson JSON 把多个实验串成一节课，支持：

- **顺序解锁**：先完成场景 A 才能进场景 B（`unlock` 门禁）
- **条件分支**：预测题得分达标 → 挑战路线，否则 → 复习路线（`routes` 条件路由）
- **跨 sim 混排**：circuit + color_vision 等任意组合（试点已验证）
- **拖拽式剧本编辑器**（开发中）：App 内作者模式，拖拽编排节点与连线

---

## 🚀 快速开始

```bash
# 前置：Flutter SDK ≥ 3.11（Dart ^3.11.1）
flutter pub get

# 运行（任选目标）
flutter run -d windows     # Windows 桌面
flutter run -d chrome      # Web
flutter run -d android     # Android
```

首次打开即见首页学科入口，点击任意模拟即可开始；首页「课时」卡片可体验剧本化的一节课。

---

## 📁 项目结构

```
lib/
├── main.dart                    # 入口（MaterialApp → HomeScreen）
├── screens/                     # 共享屏幕（home / lesson / scenario_selection）
├── common/                      # 跨 sim 共享设施
│   ├── widgets/                 #   DragDropWorkspace / NineGridLayout / PropertyControlPanel
│   ├── controls/                #   KratosSlider / ComboBox / RadioGroup / NumberField
│   ├── scenario/                #   ScenarioManager / LessonPlan / SuccessCondition
│   └── geometry/                #   SceneProjection 坐标映射
├── circuit/                     # 电路模块（模型 + 求解器 + 渲染）
├── optics/                      # 几何光学模块
├── color_vision/                # 色觉模块
├── wave_interference/           # 波的干涉模块
├── sound/                       # 声波模块
├── radio_waves/                 # 电磁波模块
├── forces/                      # 力与运动模块
├── chemistry/molarity/          # 摩尔浓度模块
└── lesson_editor/               # 拖拽式剧本编辑器（开发中）

assets/
├── scenarios/                   # 场景 JSON（sim 各自目录 + manifest）
├── lessons/                     # 课时剧本 JSON
├── schemas/                     # JSON Schema（scenario / lesson 契约）
├── images/ · sounds/            # 素材
└── prompts/                     # AI 生成 prompt

test/ · integration_test/        # 单元 + 集成测试
```

---

## 🏗️ 架构与设计原则

四个贯穿全部模块的设计原则（详见 `docs/knowledge/kratos/architecture/`）：

1. **MVC 分层**：Model 层（`*State`/`*World`）与 View 层（`CustomPainter`）分离，Controller 只做状态流转；View 不直接改 Model
2. **组件化**：一元件一 Painter，Model 与 Render 通过接口通信（Model 不依赖 Flutter）
3. **通用化**：L0 基础组件（拖拽工作区/九宫格/属性面板）在 `lib/common/` 单一实现，所有 sim 复用，禁止平行实现
4. **配置化**：Intrinsic 参数、成功判定、剧本流程全部外置 JSON + Schema 校验，AI 可生成

核心交互链路：**状态 → 求解 → 渲染**（`state.copyWith → Solver.solve → CustomPainter.paint`），求解器为纯函数，不持有状态。

---

## ✅ 测试

```bash
flutter test               # 461 个单元测试（模型/求解器/布局/剧本）
flutter test integration_test  # 集成测试
```

测试覆盖：电路图论求解、光学追迹、各 sim 布局（九宫格合规/无溢出）、剧本图校验（9 规则）与运行时流转。

---

## 📚 参考

- 模拟设计参考 PhET Interactive Simulations（科罗拉多大学）
- `kratos-reference/`：Java/TS 参考实现
- 架构与约定知识库：`docs/knowledge/kratos/`

---

## 🛠️ 开发协作（AIVibe 框架）

本项目集成了 AIVibe 协作框架（规则 / Subagents / SOP / 需求工程骨架），用于 AI 辅助开发：

- 规则：`.codebuddy/rules/*.mdc`（工程原则 · 状态同步 · 自进化协议）
- Subagents：`.codebuddy/agents/*.md`（PM / Tech Leader / Reviewer / Tester 等）
- SOP：`agile-vibe`（轻量 4 阶段）/ `deep-vibe`（含正式评审）
- 需求工程：`requirements/req-*/`（每个需求独立目录，状态可追溯）

> 框架细节见 `.codebuddy/docs/`。业务开发通常只需关注 `lib/` 与 `assets/`。

---

## License

待定。
