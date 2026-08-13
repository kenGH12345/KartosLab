# PhET Java Simulations 分学科清单

> 采样级：分学科抽样（Q3=b · 覆盖 5 学科 · 每 sim 附 Java 文件数 + 依赖标签）
> 数据源：`Get-ChildItem` 遍历 `<PHET_JAVA_ROOT>/simulations-java/simulations/*/src` + `<sim>-build.properties`（2026-07-22 实测）
> 总数：**89 个目录** → 剔除 8 个非 sim（含 test/demo/template/all-sims）→ **有效 sim 约 81 个**（部分 Scala 类 sim 的 `.java` 文件为 0，实际用 Scala 编写）

## 阅读约定

- **Java 文件数**：`src/**/*.java` 递归计数，粗略衡量 sim 复杂度
- **依赖标签**：从 `<sim>-build.properties` 的 `project.depends.lib` 字段读出，反映技术栈
- **技术门槛标签**（供 [shortlist](shortlist-for-flutter-port.md) 用）：
  - 🟢 **PC**：仅依赖 `kartoscommon` + `piccolo-kartos`（Flutter 复刻最直接）
  - 🟡 **PC+**：加 `jfreechart-kartos` / `chemistry` / `games` / `motion` 等辅助（中等复刻）
  - 🟠 **老栈**：依赖 `kartosgraphics`（早期 AWT，Flutter 需重写图形层）
  - 🔴 **3D**：依赖 `lwjgl` / `lwjgl-kartos` / `jme-kartos`（3D 渲染，Flutter 需 flutter_gl 或降级为 2D）
  - 🔴 **jbox2d**：物理引擎，Flutter 需 forge2d 或替代
  - 🟣 **Scala**：Scala 编写（`java=0` 或极少），Flutter 复刻需重写但逻辑清晰
- **⭐ 教学价值**：★★★ = PhET 官网仍是主推 sim / K-12 教材经典；★★ = 中等；★ = 冷门或废弃

---

## 剔除项（非 sim / 工程辅助）

| 目录 | 性质 |
|---|---|
| `all-sims/` | 打包容器 |
| `java-common-strings/` | i18n 字符串聚合 |
| `test-java-project/` | 构建测试 |
| `test-lwjgl-project/` | LWJGL 环境测试 |
| `simsharing-test-sim/` | simsharing 功能测试 |
| `kartosgraphics-demo/` | 库 demo |
| `mvc-example/` | 教学示例 |
| `modes-example/` | 教学示例 |
| `balance-and-torque-study/` | 是 `balance-and-torque` 的 A/B study 变体，非独立 sim |

---

## 一、力学 / 运动（Mechanics · Flutter 已复刻 forces 模块）

| sim | Java 文件 | 依赖标签 | 技术门槛 | ⭐ | 备注 |
|---|---:|---|---|---|---|
| **forces-and-motion-basics** | 28 | piccolo-kartos | 🟢 PC | ★★★ | Flutter forces 模块**主要蓝本**（同名） |
| **forces-1d** | 65 | kartosgraphics + piccolo-kartos | 🟠 老栈 | ★★★ | Flutter forces 的 motion 子屏参考 |
| **the-ramp** | 97 | jfreechart-kartos + piccolo-kartos + kartosgraphics | 🟠 老栈+PC | ★★★ | Flutter forces 未覆盖（斜坡 · 摩擦力经典） |
| **moving-man** | 30 | motion + record-and-playback + beanshell | 🟡 PC+ | ★★★ | 一维运动 · 位置/速度/加速度图 · 录制回放 |
| **motion-series** | 9 (+Scala) | scala-common + motion + record-and-playback | 🟣 Scala | ★★ | Scala 编写的运动系列 |
| **motion-2d** | 9 | kartosgraphics | 🟠 老栈 | ★ | 老 sim，早期 2D 运动 |
| **ladybug-motion-2d** | 1 (+Scala) | scala-common + motion + record-and-playback | 🟣 Scala | ★★ | 2D 运动 · 瓢虫轨迹 |
| **energy-skate-park** | 126 | timeseries + spline + jfreechart-kartos + piccolo-kartos | 🟡 PC+ | ★★★ | 能量守恒经典 · 用 spline 平滑轨道 |
| **work-energy** | 28 (+Scala) | scala-common + motion + record-and-playback | 🟣 Scala | ★★ | 功与能 |
| **balance-and-torque** | 92 | piccolo-kartos + games | 🟡 PC+ | ★★★ | 杠杆与力矩 · 含游戏化 |
| **gravity-and-orbits** | 44 | piccolo-kartos | 🟢 PC | ★★★ | 万有引力 · PhET 明星 sim |
| **force-law-lab** | 0 (Scala) | scala-common | 🟣 Scala | ★★ | 库仑定律 / 万有引力律 |
| **fluid-pressure-and-flow** | 103 | piccolo-kartos + spline | 🟡 PC+ | ★★★ | 流体压强与流量 |
| **rotation** | 102 | timeseries + motion + jfreechart-kartos + JSci | 🟡 PC+ | ★★ | 转动力学 |
| **eating-and-exercise** | 96 | piccolo-kartos + motion | 🟡 PC+ | ★ | 卡路里模型（非物理） |

## 二、电磁学 / 电路（Electricity · Flutter 已复刻 circuit 模块）

| sim | Java 文件 | 依赖标签 | 技术门槛 | ⭐ | 备注 |
|---|---:|---|---|---|---|
| **circuit-construction-kit** | 172 | jfreechart-kartos + Jama + nanoxml | 🟡 PC+ | ★★★ | Flutter circuit 模块**主要蓝本**（CCK） |
| **battery-resistor-circuit** | 91 | kartoscommon | 🟢 PC | ★★★ | 电池-电阻电路 · 电子动画经典 |
| **signal-circuit** | 60 | piccolo-kartos | 🟢 PC | ★★ | 信号电路（脉冲传播） |
| **battery-voltage** | (未采样) | kartoscommon | 🟢 PC | ★★ | 电池内部电压模型 |
| **conductivity** | 54 | kartosgraphics + piccolo-kartos | 🟠 老栈 | ★★ | 导电性能 |
| **semiconductor** | 141 | kartoscommon | 🟢 PC | ★★ | 半导体 · 能带模型 |
| **capacitor-lab** | 111 | piccolo-kartos | 🟢 PC | ★★★ | 电容器 · 电场可视化 |
| **efield** | 60 | piccolo-kartos | 🟢 PC | ★★★ | 电场线 · 点电荷 |
| **electric-hockey** | 12 | kartoscommon | 🟢 PC | ★★ | 电场曲棍球（游戏化） |
| **travoltage** | 33 | piccolo-kartos + jcommon | 🟢 PC | ★★★ | 静电（约翰·特拉沃塔卡通） |
| **balloons** | 43 | piccolo-kartos | 🟢 PC | ★★★ | 气球与静电 · 经典入门 sim |
| **faraday** | 76 | kartosgraphics + piccolo-kartos | 🟠 老栈 | ★★★ | 法拉第电磁感应 · PhET 经典 |
| **inside-magnets** | 9 (+Scala) | kartoscommon + piccolo-kartos | 🟣 Scala | ★★ | 磁畴模型（Scala） |
| **charges-and-fields-scala** | 0 (Scala) | scala-common | 🟣 Scala | ★★★ | 电荷与电场（Scala 版） |

## 三、光学 / 波动（Optics & Waves · Flutter 已复刻 optics 模块）

| sim | Java 文件 | 依赖标签 | 技术门槛 | ⭐ | 备注 |
|---|---:|---|---|---|---|
| **bending-light** | 62 | piccolo-kartos | 🟢 PC | ★★★ | Flutter optics **完整版蓝本**（折射/反射/全反射） |
| **color-vision** | 33 | kartosgraphics + piccolo-kartos | 🟠 老栈 | ★★★ | 色觉 · RGB 合成经典 |
| **wave-interference** | 196 | jfreechart-kartos + piccolo-kartos | 🟡 PC+ | ★★★ | 水波/光波/声波干涉三合一（**大型**） |
| **sound** | 111 | kartosgraphics + piccolo-kartos | 🟠 老栈 | ★★ | 声波 · 频率/振幅 |
| **radio-waves** | 57 | mechanics + kartosgraphics + piccolo-kartos | 🟠 老栈 | ★★ | 无线电波（天线-接收） |
| **fourier** | 88 | kartosgraphics + charts + piccolo-kartos | 🟠 老栈 | ★★★ | 傅里叶合成（波形叠加） |
| **microwaves** | 61 | kartosgraphics + quantum + mechanics + controls | 🟠 老栈 | ★★ | 微波（分子加热） |
| **optical-quantum-control** | 28 | kartosgraphics + charts | 🟠 老栈 | ★ | 量子光学控制（研究向） |
| **optical-tweezers** | 112 | jfreechart-kartos + piccolo-kartos | 🟡 PC+ | ★★ | 光镊（研究向） |

## 四、原子/量子/核物理（Modern Physics）

| sim | Java 文件 | 依赖标签 | 技术门槛 | ⭐ | 备注 |
|---|---:|---|---|---|---|
| **build-an-atom** | 113 | piccolo-kartos + games | 🟡 PC+ | ★★★ | 组装原子 · PhET 明星 |
| **rutherford-scattering** | 42 | piccolo-kartos | 🟢 PC | ★★★ | α 粒子散射（原子模型） |
| **hydrogen-atom** | 105 | jfreechart-kartos + jfreechart | 🟡 PC+ | ★★ | 氢原子模型（多模型对比） |
| **nuclear-physics** | 176 | jfreechart-kartos + piccolo-kartos | 🟡 PC+ | ★★★ | 核物理综合（衰变/裂变/链式） |
| **bound-states** | 115 | jfreechart-kartos + jfreechart | 🟡 PC+ | ★★ | 束缚态波函数 |
| **quantum-tunneling** | 85 | jfreechart-kartos + jfreechart | 🟡 PC+ | ★★ | 量子隧穿 |
| **quantum-wave-interference** | 228 | jfreechart-kartos + piccolo-kartos | 🟡 PC+ | ★★ | 量子波干涉（**最大原子物理 sim**） |
| **lasers** | 65 | quantum + mechanics + controls + kartosgraphics | 🟠 老栈 | ★★ | 激光 · 三能级模型 |
| **discharge-lamps** | 55 | kartosgraphics + lasers | 🟠 老栈 | ★★ | 气体放电灯 |
| **photoelectric** | 40 | lasers + discharge-lamps + charts | 🟠 老栈 | ★★★ | 光电效应（爱因斯坦） |
| **mri** | 84 | quantum + piccolo-kartos | 🟡 PC+ | ★★ | MRI 磁共振 |
| **ideal-gas** | 110 | kartosgraphics + mechanics + collision + controls | 🟠 老栈 | ★★★ | 理想气体 · 经典 sim |
| **states-of-matter** | 79 | jfreechart-kartos + piccolo-kartos | 🟡 PC+ | ★★★ | 物态变化 |

## 五、化学（Chemistry）

| sim | Java 文件 | 依赖标签 | 技术门槛 | ⭐ | 备注 |
|---|---:|---|---|---|---|
| **acid-base-solutions** | 87 | piccolo-kartos | 🟢 PC | ★★★ | 酸碱溶液 |
| **advanced-acid-base-solutions** | (未采样) | piccolo-kartos | 🟢 PC | ★★ | 进阶版 |
| **balancing-chemical-equations** | 48 | piccolo-kartos + games + chemistry | 🟡 PC+ | ★★★ | 配平化学方程式（游戏化） |
| **beers-law-lab** | 74 | piccolo-kartos + chemistry | 🟡 PC+ | ★★★ | 比尔定律（分光光度法） |
| **molarity** | 24 | piccolo-kartos + chemistry | 🟡 PC+ | ★★★ | 摩尔浓度（最小 · 适合首个化学复刻） |
| **ph-scale** | 53 | piccolo-kartos | 🟢 PC | ★★★ | pH 值 |
| **molecule-polarity** | 53 | piccolo-kartos + chemistry + jmol-kartos | 🟡 PC+ | ★★ | 分子极性（用 Jmol） |
| **molecule-shapes** | 46 | piccolo-kartos + chemistry + lwjgl-kartos + jama-kartos + lwjgl | 🔴 3D | ★★★ | 分子形状（**3D · LWJGL**） |
| **molecules-and-light** | 8 | kartosgraphics + timeseries + mechanics + photon-absorption | 🟠 老栈 | ★★★ | 温室气体分子（光子吸收） |
| **build-a-molecule** | 59 | piccolo-kartos + chemistry + jmol + games + jmol-kartos | 🟡 PC+ | ★★★ | 搭建分子（游戏化） |
| **reactants-products-and-leftovers** | 77 | piccolo-kartos + games + chemistry | 🟡 PC+ | ★★★ | 反应物-生成物 |
| **chemical-reactions** | 25 | piccolo-kartos + chemistry + jbox2d + jama-kartos | 🔴 jbox2d | ★★ | 化学反应（用 jbox2d 物理） |
| **reactions-and-rates** | 135 | charts + collision + jfreechart-kartos + mechanics | 🟠 老栈+ | ★★★ | 反应速率（碰撞模型） |
| **titration** | 35 | kartoscommon + jfreechart + piccolo-kartos | 🟡 PC+ | ★★ | 滴定 |
| **soluble-salts** | 87 | piccolo-kartos + collision | 🟡 PC+ | ★★ | 可溶盐（离子晶格） |
| **sugar-and-salt-solutions** | 167 | piccolo-kartos + jbox2d + chemistry + jmol-kartos | 🔴 jbox2d | ★★★ | 糖盐溶液（**大型** · jbox2d 物理） |
| **conductivity** | (重复见电磁) | | | | 也归电化学 |
| **self-driven-particle-model** | 70 | piccolo-kartos + jfreechart-kartos | 🟡 PC+ | ★ | 自驱粒子模型（研究向） |

## 六、生物（Biology）

| sim | Java 文件 | 依赖标签 | 技术门槛 | ⭐ | 备注 |
|---|---:|---|---|---|---|
| **natural-selection** | 77 | piccolo-kartos + jfreechart-kartos + jfreechart + javaws | 🟡 PC+ | ★★★ | 自然选择（兔子毛色进化） |
| **neuron** | 71 | piccolo-kartos + jfreechart-kartos + record-and-playback | 🟡 PC+ | ★★★ | 神经元动作电位 |
| **gene-expression-basics** | 93 | piccolo-kartos + jfreechart-kartos | 🟡 PC+ | ★★★ | 基因表达 |
| **gene-network** | 81 | piccolo-kartos + jfreechart-kartos | 🟡 PC+ | ★★ | 基因网络（研究向） |
| **membrane-channels** | 49 | piccolo-kartos + jfreechart-kartos | 🟡 PC+ | ★★★ | 膜通道离子运输 |

## 七、地学 / 大气（Earth Science）

| sim | Java 文件 | 依赖标签 | 技术门槛 | ⭐ | 备注 |
|---|---:|---|---|---|---|
| **plate-tectonics** | 76 | piccolo-kartos + lwjgl + lwjgl-kartos | 🔴 3D | ★★★ | 板块构造（**3D · LWJGL**） |
| **glaciers** | 101 | piccolo-kartos + jfreechart-kartos + jfreechart + javaws | 🟡 PC+ | ★★★ | 冰川演化 |
| **greenhouse** | 69 | kartosgraphics + piccolo-kartos + timeseries + mechanics + photon-absorption | 🟠 老栈+ | ★★★ | 温室效应 |
| **energy-forms-and-changes** | 101 | piccolo-kartos | 🟢 PC | ★★★ | 能量形式与转化 |

## 八、数学（Math）

| sim | Java 文件 | 依赖标签 | 技术门槛 | ⭐ | 备注 |
|---|---:|---|---|---|---|
| **fractions** | 229 | piccolo-kartos + functionaljava + lombok + games | 🟡 PC+ | ★★★ | 分数（**最大数学 sim** · 函数式 Java） |
| **functions** | 39 | games | 🟡 PC+ | ★★★ | 函数机（输入输出） |
| **line-graphing** | 103 | piccolo-kartos + games | 🟡 PC+ | ★★★ | 直线图（斜率截距） |

## 九、其他 / 玩具（Misc）

| sim | Java 文件 | 依赖标签 | 技术门槛 | ⭐ | 备注 |
|---|---:|---|---|---|---|
| **maze-game** | 12 | piccolo-kartos | 🟢 PC | ★ | 迷宫（运动学玩具） |

---

## 汇总统计

- **技术门槛分布**（有效 sim 81 个抽样估算）：
  - 🟢 PC（纯 kartoscommon+piccolo）：约 **17** 个 → Flutter 复刻最直接
  - 🟡 PC+（+jfreechart/games/chemistry/motion 等）：约 **35** 个
  - 🟠 老栈（依赖 kartosgraphics）：约 **16** 个
  - 🔴 高门槛（3D / jbox2d）：**4** 个（molecule-shapes / plate-tectonics / chemical-reactions / sugar-and-salt-solutions）
  - 🟣 Scala：**7** 个

- **规模分布**（按 Java 文件数）：
  - 小（<50）：约 25 个 → Flutter 复刻工作量小
  - 中（50-100）：约 30 个
  - 大（100-200）：约 20 个
  - 特大（>200）：3 个（`fractions` 229 / `quantum-wave-interference` 228 / `wave-interference` 196）

- **教学价值 ★★★ 且技术门槛 🟢/🟡 的候选**（约 30 个）→ 详见 [shortlist-for-flutter-port.md](shortlist-for-flutter-port.md)（Loop 3 产出）

## 采样局限

- 6 个 sim 未做 Java 文件计数（`battery-voltage` / `advanced-acid-base-solutions` 等），标注 "(未采样)"，Loop 3 打分时若入围将补测
- Java 文件数**≠ 代码行数**；`fractions` 229 文件用 functionaljava 函数式，单文件小；`circuit-construction-kit` 172 文件多为图形节点，单文件中等。真实 LOC 估算需 grep 而不是 count files
- `study` 变体与主 sim 未分开评估（如 `balance-and-torque-study`）
- ⭐ 教学价值主要基于 PhET 官网 [kartos.colorado.edu/en/simulations/browse](https://kartos.colorado.edu/en/simulations/browse) 的公开热度经验判断，非精确统计
