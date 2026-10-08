import 'package:kratos/l10n/kartos_locale.dart';

/// Home / registry **display** titles (`sim.<id>.title` / `.subtitle`).
///
/// Stable simulation IDs remain English kebab-case and are never translated.
class SimTitlesL10n {
  const SimTitlesL10n(this.locale);

  final KartosLocale locale;

  /// id → (titleZh, titleEn, subtitleZh, subtitleEn)
  static const Map<String, List<String>> _sims = {
    'forces-and-motion-basics': [
      '力与运动',
      'Forces and Motion: Basics',
      '合力 · 摩擦 · 加速度',
      'Net Force · Friction · Acceleration',
    ],
    'collision-lab': [
      '碰撞实验室',
      'Collision Lab',
      '动量 · 弹性 · 非弹性',
      'Momentum · Elastic · Inelastic',
    ],
    'vector-addition': [
      '矢量加法',
      'Vector Addition',
      '矢量 · 分量 · 合矢量',
      'Vectors · Components · Resultant',
    ],
    'energy-skate-park': [
      '能量滑板公园',
      'Energy Skate Park',
      '动能 · 势能 · 轨道运动',
      'Kinetic · Potential · Track',
    ],
    'curve-fitting': [
      '曲线拟合',
      'Curve Fitting',
      '最佳拟合 · 残差 · χ²',
      'Best fit · Residuals · χ²',
    ],
    'gravity-force-lab-basics': [
      '万有引力实验室：基础',
      'Gravity Force Lab: Basics',
      '牛顿引力 · 两个质量',
      "Newton's gravity · two masses",
    ],
    'gravity-force-lab': [
      '万有引力实验室',
      'Gravity Force Lab',
      '牛顿引力 · 质量 · 距离 · 力',
      "Newton's gravity · kg · m · N",
    ],
    'masses-and-springs-basics': [
      '质量与弹簧：基础',
      'Masses and Springs: Basics',
      '拉伸 · 弹跳 · 实验室',
      'Stretch · Bounce · Lab',
    ],
    'hookes-law': [
      '胡克定律',
      "Hooke's Law",
      '介绍 · 系统 · 能量',
      'Intro · Systems · Energy',
    ],
    'pendulum-lab': [
      '单摆实验室',
      'Pendulum Lab',
      '介绍 · 能量 · 实验室',
      'Intro · Energy · Lab',
    ],
    'projectile-motion': [
      '抛体运动',
      'Projectile Motion',
      '炮弹出膛 · 轨迹 · 落地',
      'Cannon · Trajectory · Landing',
    ],
    'balancing-act': [
      '平衡木',
      'Balancing Act',
      '介绍 · 平衡实验室 · 游戏',
      'Intro · Balance Lab · Game',
    ],
    'friction': [
      '摩擦',
      'Friction',
      '摩擦 · 微观原子 · 温度',
      'Friction · Atoms · Temperature',
    ],
    'plinko-probability': [
      '弹珠概率',
      'Plinko Probability',
      '高尔顿板 · 伯努利 · 二项分布',
      'Galton · Bernoulli · Binomial',
    ],
    'density': [
      '密度',
      'Density',
      '质量 · 体积 · 材料',
      'Mass · Volume · Material',
    ],
    'buoyancy': [
      '浮力',
      'Buoyancy',
      '比较 · 探索 · 实验室 · 形状 · 应用',
      'Compare · Explore · Lab · Shapes · Applications',
    ],
    'under-pressure': [
      '液体压强',
      'Under Pressure',
      '压强 · 深度 · 密度',
      'Pressure · Depth · Density',
    ],
    'circuit': [
      '电路搭建',
      'Circuit Construction',
      '串并联 · 电流路径',
      'Series/Parallel · Current Path',
    ],
    'cck-ac-virtual-lab': [
      '交流虚拟实验室',
      'Circuit Construction Kit: AC - Virtual Lab',
      '交流 · 电容 · 电感',
      'AC · Capacitance · Inductance',
    ],
    'capacitor-lab-basics': [
      '电容器实验室：基础',
      'Capacitor Lab: Basics',
      '电容 · 电荷 · 灯泡放电',
      'Capacitance · Charge · Light Bulb',
    ],
    'ohms-law': [
      '欧姆定律',
      "Ohm's Law",
      '电压 · 电阻 · 电流',
      'Voltage · Resistance · Current',
    ],
    'resistance-in-a-wire': [
      '导线电阻',
      'Resistance in a Wire',
      '电阻率 · 长度 · 截面积',
      'Resistivity · Length · Area',
    ],
    'charges-and-fields': [
      '电荷与电场',
      'Charges and Fields',
      '点电荷 · 电场 · 电势 · 等势线',
      'Point charges · Field · Potential',
    ],
    'john-travoltage': [
      '约翰·特拉伏特',
      'John Travoltage',
      '静电 · 摩擦起电 · 放电',
      'Static · Triboelectric · Discharge',
    ],
    'balloons-and-static-electricity': [
      '气球与静电',
      'Balloons and Static Electricity',
      '摩擦起电 · 诱导电荷 · 静电吸引',
      'Charging · Induction · Attraction',
    ],
    'magnet-and-compass': [
      '磁铁与罗盘',
      'Magnet and Compass',
      '条形磁铁 · 磁场 · 罗盘',
      'Bar Magnet · Field · Compass',
    ],
    'faradays-law': [
      '法拉第电磁感应定律',
      "Faraday's Law",
      '磁铁 · 线圈 · 感应电动势',
      'Magnet · Coil · Induced EMF',
    ],
    'keplers-laws': [
      '开普勒定律',
      "Kepler's Laws",
      '椭圆轨道 · 面积定律 · 周期定律',
      'Ellipses · Equal Areas · Periods',
    ],
    'my-solar-system': [
      '我的太阳系',
      'My Solar System',
      '多体引力 · 轨道系统',
      'N-body Gravity · Orbits',
    ],
    'gravity-and-orbits': [
      '引力与轨道',
      'Gravity and Orbits',
      '引力 · 轨道 · 模型 / 按比例',
      'Gravity · Orbits · Model / To Scale',
    ],
    'optics': [
      '几何光学',
      'Geometric Optics',
      '透镜 · 镜面 · 成像',
      'Lenses · Mirrors · Images',
    ],
    'color-vision': [
      '色觉',
      'Color Vision',
      '单色灯泡 · 红绿蓝灯泡',
      'Single Bulb · RGB Bulbs',
    ],
    'wave-interference': [
      '波的干涉',
      'Wave Interference',
      '双缝 · 叠加原理',
      'Double Slit · Superposition',
    ],
    'quantum-wave-interference': [
      '量子波干涉',
      'Quantum Wave Interference',
      '实验 · 高强度 · 单粒子',
      'Experiment · High Intensity · Single Particles',
    ],
    'quantum-coin-toss': [
      '量子抛硬币',
      'Quantum Coin Toss',
      '经典 · 量子硬币',
      'Classical · Quantum Coin',
    ],
    'quantum-measurement': [
      '量子测量',
      'Quantum Measurement',
      '硬币 · 光子 · 自旋 · 布洛赫球',
      'Coins · Photons · Spin · Bloch',
    ],
    'waves-intro': [
      '波导论',
      'Waves Intro',
      '水波 · 声波 · 光波',
      'Water · Sound · Light',
    ],
    'sound': [
      '声波',
      'Sound',
      '频率 · 振幅 · 波形',
      'Frequency · Amplitude · Waveform',
    ],
    'normal-modes': [
      '简正模式',
      'Normal Modes',
      '耦合振子 · 简正模',
      'Coupled Oscillators · Modes',
    ],
    'fourier-making-waves': [
      '傅里叶：合成波',
      'Fourier: Making Waves',
      '傅里叶合成 · 波包',
      'Fourier Synthesis · Wave Packets',
    ],
    'radio-waves': [
      '无线电波',
      'Radio Waves',
      '天线 · 传播',
      'Antenna · Propagation',
    ],
    'bending-light': [
      '光的折射',
      'Bending Light',
      '折射 · 棱镜 · 传感器',
      'Refraction · Prism · Sensors',
    ],
    'wave-on-a-string': [
      '绳波',
      'Wave on a String',
      '绳波 · 反射 · 阻尼 · 张力',
      'Reflection · Damping · Tension',
    ],
    'diffusion': [
      '扩散',
      'Diffusion',
      '粒子扩散 · 隔板 · 质量/半径',
      'Particles · Barrier · Mass/Radius',
    ],
    'membrane-transport': [
      '膜转运',
      'Membrane Transport',
      '通道 · 载体 · 主动转运',
      'Channels · Carriers · Active Transport',
    ],
    'gases-intro': [
      '气体导论',
      'Gases Intro',
      '理想气体 · 介绍 / 定律',
      'Ideal Gas · Intro / Laws',
    ],
    'gas-properties': [
      '气体性质',
      'Gas Properties',
      '理想气体 · 探索 · 能量 · 扩散',
      'Ideal · Explore · Energy · Diffusion',
    ],
    'blackbody-spectrum': [
      '黑体辐射光谱',
      'Blackbody Spectrum',
      '黑体辐射 · 普朗克 · 维恩',
      'Blackbody · Planck · Wien',
    ],
    'energy-forms-and-changes': [
      '能量形式与转化',
      'Energy Forms and Changes',
      '介绍 · 系统 · 能量转化',
      'Intro · Systems · Energy Transfer',
    ],
    'molarity': [
      '摩尔浓度',
      'Molarity',
      '溶液配比 · 浓度计算',
      'Solution Ratio · Concentration',
    ],
    'beers-law-lab': [
      '比尔定律实验室',
      "Beer's Law Lab",
      '浓度 · 比尔定律',
      "Concentration · Beer's Law",
    ],
    'ph-scale': [
      'pH 标度',
      'pH Scale',
      '酸 · 碱 · 浓度 · 宏观/微观',
      'Acid · Base · Concentration · Macro/Micro',
    ],
    'acid-base-solutions': [
      '酸碱溶液',
      'Acid-Base Solutions',
      '介绍 · 我的溶液 · 酸碱电离',
      'Intro · My Solution · Ionization',
    ],
    'build-a-nucleus': [
      '构建原子核',
      'Build a Nucleus',
      '质子 · 中子 · 衰变',
      'Protons · Neutrons · Decay',
    ],
    'rutherford-scattering': [
      '卢瑟福散射',
      'Rutherford Scattering',
      '卢瑟福 · 葡萄干布丁',
      'Rutherford · Plum Pudding',
    ],
    'build-an-atom': [
      '构建原子',
      'Build an Atom',
      '质子 · 中子 · 电子 · 符号 · 游戏',
      'Protons · Neutrons · Electrons · Symbol · Game',
    ],
    'isotopes-and-atomic-mass': [
      '同位素与原子质量',
      'Isotopes and Atomic Mass',
      '同位素 · 原子质量',
      'Isotopes · Atomic Mass',
    ],
    'build-a-molecule': [
      '搭建分子',
      'Build a Molecule',
      '原子 · 成键 · 收集',
      'Atoms · Bonding · Collect',
    ],
    'molecule-polarity': [
      '分子极性',
      'Molecule Polarity',
      '双原子 · 三原子 · 真实分子',
      'Two · Three · Real Molecules',
    ],
    'molecule-shapes': [
      '分子形状',
      'Molecule Shapes',
      '模型 · 真实分子 · VSEPR',
      'Model · Real Molecules · VSEPR',
    ],
    'molecules-and-light': [
      '分子与光',
      'Molecules and Light',
      '光子吸收 · 分子振动 · 光谱',
      'Photon Absorption · Vibration · Spectra',
    ],
    'reactants-products-and-leftovers': [
      '反应物、生成物与剩余物',
      'Reactants, Products and Leftovers',
      '三明治 · 分子 · 游戏',
      'Sandwiches · Molecules · Game',
    ],
    'balancing-chemical-equations': [
      '化学方程式配平',
      'Balancing Chemical Equations',
      '介绍 · 方程式 · 游戏',
      'Intro · Equations · Game',
    ],
    'states-of-matter': [
      '物质的状态',
      'States of Matter',
      '物态 · 相变 · 相互作用',
      'States · Phase Changes · Interaction',
    ],
    'concentration': [
      '浓度',
      'Concentration',
      '溶质 · 饱和 · 探针测量',
      'Solute · Saturation · Probe',
    ],
  };

  static Iterable<String> get simulationIds => _sims.keys;

  static Iterable<String> get keys sync* {
    for (final id in _sims.keys) {
      yield 'sim.$id.title';
      yield 'sim.$id.subtitle';
    }
  }

  String title(String id) {
    final row = _sims[id];
    if (row == null) {
      assert(false, 'Missing sim title for id=$id');
      return id;
    }
    return locale == KartosLocale.en ? row[1] : row[0];
  }

  String subtitle(String id) {
    final row = _sims[id];
    if (row == null) {
      assert(false, 'Missing sim subtitle for id=$id');
      return '';
    }
    return locale == KartosLocale.en ? row[3] : row[2];
  }
}
