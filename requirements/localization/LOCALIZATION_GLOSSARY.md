# LOCALIZATION_GLOSSARY

> PHASE 0 draft · 2026-10-08
>
> 科学术语优先采用中国大陆中学/大学物理、化学教材标准译法。
> 同一英文词在不同语境可有不同译文，但必须在 Notes 中固定，禁止无故混用。

## 1. Global / UI Controls

| Key | English | Chinese | Context | Notes |
|---|---|---|---|---|
| `resetAll` | Reset All | 全部重置 | global control | 统一；勿与「重置全部」混用 |
| `reset` | Reset | 重置 | global control |  |
| `play` | Play | 播放 | time control |  |
| `pause` | Pause | 暂停 | time control |  |
| `normal` | Normal | 正常 | speed | 时间倍率 |
| `slow` | Slow | 慢速 | speed |  |
| `fast` | Fast | 快速 | speed |  |
| `fastForward` | Fast Forward | 快进 | speed |  |
| `stopwatch` | Stopwatch | 秒表 | tool |  |
| `close` | Close | 关闭 | dialog |  |
| `ok` | OK | 确定 | dialog |  |
| `back` | Back | 返回 | navigation |  |
| `next` | Next | 下一步 | game/wizard |  |
| `tryAgain` | Try Again | 再试一次 | game |  |
| `showAnswer` | Show Answer | 显示答案 | game |  |
| `intro` | Intro | 介绍 | tab/screen | 全项目统一「介绍」 |
| `lab` | Lab | 实验室 | tab/screen |  |
| `explore` | Explore | 探索 | tab/screen |  |
| `compare` | Compare | 比较 | tab/screen |  |
| `mystery` | Mystery | 神秘材料 | density | Density 专用 tab |
| `game` | Game | 游戏 | tab/screen |  |
| `options` | Options | 选项 | panel |  |
| `values` | Values | 数值 | checkbox |  |
| `none` | None | 无 | slider extreme |  |
| `lots` | Lots | 很多 | slider extreme |  |
| `custom` | Custom | 自定义 | material/mode |  |
| `grid` | Grid | 网格 | view option |  |
| `path` | Path | 轨迹 | view option |  |
| `step` | Step | 步进 | time control |  |
| `ruler` | Ruler | 尺子 | toolbox |  |
| `measuringTape` | Measuring Tape | 卷尺 | toolbox |  |
| `graph` | Graph | 图像 | panel |  |
| `view` | View | 视图 | panel |  |
| `heat` | Heat | 加热 | control |  |
| `cool` | Cool | 冷却 | control |  |
| `go` | Go! | 开始! | forces |  |
| `return` | Return | 返回 | forces |  |
| `grab` | Grab | 抓取 | density a11y |  |
| `refresh` | Refresh | 刷新 | control |  |
| `configuration` | Configuration | 配置 | panel |  |

## 2. Physics / Chemistry Terms (consistency-critical)

| Key | English | Chinese | Context | Notes |
|---|---|---|---|---|
| `mystery` | Mystery | 神秘材料 | density | Density 专用 tab |
| `material` | Material | 材料 | density/buoyancy |  |
| `velocity` | Velocity | 速度 | physics | 矢量；与 speed 区分 |
| `speed` | Speed | 速率 | physics | 标量；中学 UI 可标「速度」需统一决策 |
| `acceleration` | Acceleration | 加速度 | physics |  |
| `force` | Force | 力 | physics |  |
| `netForce` | Net Force | 合力 | physics |  |
| `gravity` | Gravity | 重力 | physics control | g；非「引力」除非万有引力语境 |
| `gravityForce` | Gravity Force | 引力 | gravity-force-lab | 万有引力 |
| `mass` | Mass | 质量 | physics | 勿与 weight 混译 |
| `weight` | Weight | 重量 | physics | PHASE 1 冻结：名词标签用「重量」；受力叙述可用「重力」见 GLOSSARY_CONFLICTS |
| `density` | Density | 密度 | physics |  |
| `volume` | Volume | 体积 | physics |  |
| `pressure` | Pressure | 压强 | physics | 流体静力学用「压强」 |
| `buoyancy` | Buoyancy | 浮力 | physics |  |
| `displacement` | Displacement | 位移 | kinematics | 浮力语境另用「排开体积」 |
| `displacedVolume` | Displaced Volume | 排开体积 | buoyancy |  |
| `wavelength` | Wavelength | 波长 | waves |  |
| `frequency` | Frequency | 频率 | waves |  |
| `amplitude` | Amplitude | 振幅 | waves |  |
| `particle` | Particle | 粒子 | physics |  |
| `particles` | Particles | 粒子 | gas |  |
| `molecule` | Molecule | 分子 | chemistry |  |
| `atom` | Atom | 原子 | chemistry |  |
| `proton` | Proton | 质子 | chemistry |  |
| `neutron` | Neutron | 中子 | chemistry |  |
| `electron` | Electron | 电子 | chemistry |  |
| `electricField` | Electric Field | 电场 | physics |  |
| `voltage` | Voltage | 电压 | physics |  |
| `current` | Current | 电流 | physics |  |
| `resistance` | Resistance | 电阻 | physics |  |
| `energy` | Energy | 能量 | physics |  |
| `kineticEnergy` | Kinetic Energy | 动能 | physics |  |
| `potentialEnergy` | Potential Energy | 势能 | physics |  |
| `thermal` | Thermal | 热能 | efac |  |
| `mechanical` | Mechanical | 机械能 | efac |  |
| `electrical` | Electrical | 电能 | efac |  |
| `chemical` | Chemical | 化学能 | efac |  |
| `light` | Light | 光 | optics | 能量形式语境用「光能」 |
| `friction` | Friction | 摩擦 | physics | 力语境「摩擦力」 |
| `centerOfMass` | Center of Mass | 质心 | physics |  |
| `intensity` | Intensity | 强度 | optics/waves |  |
| `symbol` | Symbol | 符号 | build-an-atom |  |
| `objectDensity` | Object Density | 物体密度 | buoyancy |  |
| `percentSubmerged` | % Submerged | 浸没百分比 | buoyancy |  |
| `water` | Water | 水 | material |  |
| `earth` | Earth | 地球 | astronomy |  |
| `jupiter` | Jupiter | 木星 | astronomy |  |
| `mars` | Mars | 火星 | astronomy |  |
| `cartesian` | Cartesian | 直角坐标 | vector |  |
| `polar` | Polar | 极坐标 | vector |  |
| `balanced` | Balanced | 已配平 | chemistry |  |
| `returnLid` | Return Lid | 放回盖子 | gas |  |
| `lightBulb` | Light Bulb | 灯泡 | circuit |  |
| `ph` | pH | pH | chemistry | 保留科学符号 |
| `screenBrightness` | Screen Brightness | 屏幕亮度 | qwi |  |
| `sourceIntensity` | Source Intensity | 源强度 | qwi |  |
| `slitSeparation` | Slit Separation | 缝间距 | qwi |  |
| `barrierScreenDistance` | Barrier-Screen Distance | 障壁-屏距离 | qwi |  |
| `damping` | Damping | 阻尼 | woas |  |
| `tension` | Tension | 张力 | woas |  |
| `pulseWidth` | Pulse Width | 脉宽 | woas |  |
| `holdConstant` | Hold Constant | 保持恒定 | gas |  |
| `fluid` | Fluid | 流体 | fluids | ≠ liquid |
| `liquid` | Liquid | 液体 | fluids | ≠ fluid |
| `gas` | Gas | 气体 | fluids |  |
| `atmosphere` | Atmosphere | 大气 | under-pressure | 控制标签；大气压用 atmosphericPressure |
| `atmosphericPressure` | Atmospheric Pressure | 大气压 | fluids |  |
| `temperature` | Temperature | 温度 | fluids |  |
| `container` | Container | 容器 | gas |  |
| `piston` | Piston | 活塞 | gas |  |
| `pump` | Pump | 泵 | gas |  |
| `fluidDensity` | Fluid Density | 流体密度 | fluids |  |
| `fluidDisplaced` | Fluid Displaced | 排开的流体 | buoyancy |  |
| `wood` | Wood | 木材 | material | 勿用「木头/木板」 |
| `wire` | Wire | 导线 | electricity |  |
| `battery` | Battery | 电池 | electricity |  |
| `resistor` | Resistor | 电阻器 | electricity | ≠ resistance |
| `capacitor` | Capacitor | 电容器 | electricity | ≠ capacitance |
| `capacitance` | Capacitance | 电容 | electricity |  |
| `voltmeter` | Voltmeter | 电压表 | electricity |  |
| `ammeter` | Ammeter | 电流表 | electricity |  |
| `conventional` | Conventional | 常规电流 | electricity | current direction |
| `resistivity` | Resistivity | 电阻率 | electricity |  |
| `equipotential` | Equipotential | 等势 | electricity |  |
| `magneticField` | Magnetic Field | 磁场 | electricity |  |
| `fieldLines` | Field Lines | 磁场线 | faradays / magnet | E-field sims use 电场线 if needed |
| `appliedForce` | Applied Force | 外力 | hookes-law |  |
| `diameter` | Diameter | 直径 | projectile |  |
| `dragCoefficient` | Drag Coefficient | 阻力系数 | projectile |  |
| `altitude` | Altitude | 海拔 | projectile |  |
| `bonding` | Bonding | 成键 | molecule-shapes |  |
| `lonePair` | Lone Pair | 孤对电子 | molecule-shapes |  |

## 3. Simulation Display Names

> registry / route id 保持英文 kebab-case；仅 displayName 中文。

| Registry Key | English | Chinese | Context |
|---|---|---|---|
| `bending-light` | Bending Light | 光的折射 | sim title |
| `wave-on-a-string` | Wave on a String | 绳波 | sim title |
| `ohms-law` | Ohm's Law | 欧姆定律 | sim title |
| `faradays-law` | Faraday's Law | 法拉第电磁感应定律 | sim title |
| `under-pressure` | Under Pressure | 液体压强 | sim title |
| `density` | Density | 密度 | sim title |
| `buoyancy` | Buoyancy | 浮力 | sim title |
| `collision-lab` | Collision Lab | 碰撞实验室 | sim title |
| `vector-addition` | Vector Addition | 矢量加法 | sim title |
| `projectile-motion` | Projectile Motion | 抛体运动 | sim title |
| `pendulum-lab` | Pendulum Lab | 单摆实验室 | sim title |
| `hookes-law` | Hooke's Law | 胡克定律 | sim title |
| `friction` | Friction | 摩擦 | sim title |
| `forces-and-motion-basics` | Forces and Motion: Basics | 力与运动 | sim title |
| `gravity-force-lab` | Gravity Force Lab | 万有引力实验室 | sim title |
| `gravity-force-lab-basics` | Gravity Force Lab: Basics | 万有引力实验室：基础 | sim title |
| `gravity-and-orbits` | Gravity and Orbits | 引力与轨道 | sim title |
| `keplers-laws` | Kepler's Laws | 开普勒定律 | sim title |
| `my-solar-system` | My Solar System | 我的太阳系 | sim title |
| `charges-and-fields` | Charges and Fields | 电荷与电场 | sim title |
| `capacitor-lab-basics` | Capacitor Lab: Basics | 电容器实验室：基础 | sim title |
| `cck-ac-virtual-lab` | Circuit Construction Kit: AC - Virtual Lab | 电路搭建工具包：交流虚拟实验室 | sim title |
| `john-travoltage` | John Travoltage | 约翰·特拉伏特 | sim title |
| `balloons-and-static-electricity` | Balloons and Static Electricity | 气球与静电 | sim title |
| `resistance-in-a-wire` | Resistance in a Wire | 导线电阻 | sim title |
| `waves-intro` | Waves Intro | 波导论 | sim title |
| `normal-modes` | Normal Modes | 简正模式 | sim title |
| `fourier-making-waves` | Fourier: Making Waves | 傅里叶：合成波 | sim title |
| `energy-forms-and-changes` | Energy Forms and Changes | 能量形式与转化 | sim title |
| `energy-skate-park` | Energy Skate Park | 能量滑板公园 | sim title |
| `blackbody-spectrum` | Blackbody Spectrum | 黑体辐射光谱 | sim title |
| `gases-intro` | Gases Intro | 气体导论 | sim title |
| `gas-properties` | Gas Properties | 气体性质 | sim title |
| `diffusion` | Diffusion | 扩散 | sim title |
| `membrane-transport` | Membrane Transport | 膜转运 | sim title |
| `masses-and-springs-basics` | Masses and Springs: Basics | 质量与弹簧：基础 | sim title |
| `curve-fitting` | Curve Fitting | 曲线拟合 | sim title |
| `plinko-probability` | Plinko Probability | 弹珠概率 | sim title |
| `balancing-act` | Balancing Act | 平衡木 | sim title |
| `rutherford-scattering` | Rutherford Scattering | 卢瑟福散射 | sim title |
| `molecule-polarity` | Molecule Polarity | 分子极性 | sim title |
| `molecule-shapes` | Molecule Shapes | 分子形状 | sim title |
| `molecules-and-light` | Molecules and Light | 分子与光 | sim title |
| `build-a-molecule` | Build a Molecule | 搭建分子 | sim title |
| `build-an-atom` | Build an Atom | 构建原子 | sim title |
| `build-a-nucleus` | Build a Nucleus | 构建原子核 | sim title |
| `isotopes-and-atomic-mass` | Isotopes and Atomic Mass | 同位素与原子质量 | sim title |
| `acid-base-solutions` | Acid-Base Solutions | 酸碱溶液 | sim title |
| `ph-scale` | pH Scale | pH 标度 | sim title |
| `molarity` | Molarity | 摩尔浓度 | sim title |
| `beers-law-lab` | Beer's Law Lab | 比尔定律实验室 | sim title |
| `concentration` | Concentration | 浓度 | sim title |
| `balancing-chemical-equations` | Balancing Chemical Equations | 化学方程式配平 | sim title |
| `reactants-products-and-leftovers` | Reactants, Products and Leftovers | 反应物、生成物与剩余物 | sim title |
| `states-of-matter` | States of Matter | 物质的状态 | sim title |
| `color-vision` | Color Vision | 色觉 | sim title |
| `quantum-measurement` | Quantum Measurement | 量子测量 | sim title |
| `quantum-coin-toss` | Quantum Coin Toss | 量子抛硬币 | sim title |
| `quantum-wave-interference` | Quantum Wave Interference | 量子波干涉 | sim title |
| `sound` | Sound | 声波 | sim title |
| `radio-waves` | Radio Waves | 无线电波 | sim title |
| `wave-interference` | Wave Interference | 波的干涉 | sim title |

## 4. Consistency Rules

1. **Gravity vs Gravity Force**：控件「重力」= g；万有引力实验「引力」。
2. **Mass ≠ Weight**：质量 / 重力（重量）不得互换。
3. **Pressure**：流体静力学一律「压强」。
4. **Velocity / Speed**：术语表区分；UI 若中学简化，全项目统一一种。
5. **Reset All**：一律「全部重置」（对齐产品用语；与 L0 按钮配套）。
6. **Intro / Lab / Explore**：Tab 译名全项目统一，禁止同一 sim 内混用「入门/介绍」。
7. 数学公式与单位（`F=ma`、`kg`、`m³`、`Pa`）**不翻译**。

---

PHASE 0：本 glossary 为草稿，实施阶段按 source context 复核后冻结。

