import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/localization_format.dart';

/// Home screen chrome and category labels (`home.*` / `category.*`).
class HomeL10n {
  const HomeL10n(this.locale);

  final KartosLocale locale;

  static const Map<String, Map<KartosLocale, String>> _table = {
    'home.appTitle': {
      KartosLocale.zhCN: 'Kratos 仿真实验室',
      KartosLocale.en: 'Kratos Lab',
    },
    'home.tagline': {
      KartosLocale.zhCN: '物理 · 化学 交互式仿真实验合集 · 共 {count} 个实验',
      KartosLocale.en: 'Physics · Chemistry interactive sims · {count} total',
    },
    'home.search': {
      KartosLocale.zhCN: '搜索实验',
      KartosLocale.en: 'Search simulations',
    },
    'home.settings': {
      KartosLocale.zhCN: '设置',
      KartosLocale.en: 'Settings',
    },
    'home.empty': {
      KartosLocale.zhCN: '没有找到实验',
      KartosLocale.en: 'No simulations found',
    },
    'home.error': {
      KartosLocale.zhCN: '加载首页失败',
      KartosLocale.en: 'Failed to load home',
    },
    'home.loading': {
      KartosLocale.zhCN: '正在加载实验列表…',
      KartosLocale.en: 'Loading simulations…',
    },
    'home.unavailable': {
      KartosLocale.zhCN: '{title} 暂不可用',
      KartosLocale.en: '{title} unavailable',
    },
    'home.simCountBadge': {
      KartosLocale.zhCN: '{count} 个实验',
      KartosLocale.en: '{count} sims',
    },
    'category.physics': {
      KartosLocale.zhCN: '物理',
      KartosLocale.en: 'Physics',
    },
    'category.chemistry': {
      KartosLocale.zhCN: '化学',
      KartosLocale.en: 'Chemistry',
    },
    'category.mechanics': {
      KartosLocale.zhCN: '力学',
      KartosLocale.en: 'Mechanics',
    },
    'category.mathProbability': {
      KartosLocale.zhCN: '数学与概率',
      KartosLocale.en: 'Math & Probability',
    },
    'category.densityBuoyancy': {
      KartosLocale.zhCN: '密度与浮力',
      KartosLocale.en: 'Density & Buoyancy',
    },
    'category.electricityCircuits': {
      KartosLocale.zhCN: '电学与电路',
      KartosLocale.en: 'Electricity & Circuits',
    },
    'category.electromagnetism': {
      KartosLocale.zhCN: '电磁学',
      KartosLocale.en: 'Electromagnetism',
    },
    'category.astronomy': {
      KartosLocale.zhCN: '天体力学',
      KartosLocale.en: 'Orbital Mechanics',
    },
    'category.opticsWaves': {
      KartosLocale.zhCN: '光学与波动',
      KartosLocale.en: 'Optics & Waves',
    },
    'category.heatGases': {
      KartosLocale.zhCN: '热学与气体',
      KartosLocale.en: 'Heat & Gases',
    },
    'category.solutions': {
      KartosLocale.zhCN: '溶液与浓度',
      KartosLocale.en: 'Solutions & Concentration',
    },
    'category.nucleus': {
      KartosLocale.zhCN: '原子核',
      KartosLocale.en: 'Nucleus',
    },
    'category.atomicStructure': {
      KartosLocale.zhCN: '原子结构',
      KartosLocale.en: 'Atomic Structure',
    },
    'category.moleculeBuilding': {
      KartosLocale.zhCN: '分子搭建',
      KartosLocale.en: 'Molecule Building',
    },
    'category.moleculePolarity': {
      KartosLocale.zhCN: '分子极性',
      KartosLocale.en: 'Molecule Polarity',
    },
    'category.moleculeShapes': {
      KartosLocale.zhCN: '分子形状',
      KartosLocale.en: 'Molecule Shapes',
    },
    'category.moleculesAndLight': {
      KartosLocale.zhCN: '光与分子',
      KartosLocale.en: 'Molecules and Light',
    },
    'category.reactantsProducts': {
      KartosLocale.zhCN: '反应物与生成物',
      KartosLocale.en: 'Reactants & Products',
    },
    'category.balancingEquations': {
      KartosLocale.zhCN: '化学方程式配平',
      KartosLocale.en: 'Balancing Equations',
    },
    'category.statesOfMatter': {
      KartosLocale.zhCN: '物态',
      KartosLocale.en: 'States of Matter',
    },
  };

  String _t(String key, [Map<String, Object?>? params]) {
    final row = _table[key];
    if (row == null) {
      assert(false, 'Missing localization key: $key');
      return key;
    }
    final text = row[locale] ?? row[KartosLocale.zhCN] ?? key;
    return locFormat(text, params);
  }

  static Iterable<String> get keys => _table.keys;

  String get appTitle => _t('home.appTitle');
  String tagline(int count) => _t('home.tagline', {'count': count});
  String get search => _t('home.search');
  String get settings => _t('home.settings');
  String get empty => _t('home.empty');
  String get error => _t('home.error');
  String get loading => _t('home.loading');
  String unavailable(String title) =>
      _t('home.unavailable', {'title': title});
  String simCountBadge(int count) =>
      _t('home.simCountBadge', {'count': count});

  String get physics => _t('category.physics');
  String get chemistry => _t('category.chemistry');
  String get mechanics => _t('category.mechanics');
  String get mathProbability => _t('category.mathProbability');
  String get densityBuoyancy => _t('category.densityBuoyancy');
  String get electricityCircuits => _t('category.electricityCircuits');
  String get electromagnetism => _t('category.electromagnetism');
  String get astronomy => _t('category.astronomy');
  String get opticsWaves => _t('category.opticsWaves');
  String get heatGases => _t('category.heatGases');
  String get solutions => _t('category.solutions');
  String get nucleus => _t('category.nucleus');
  String get atomicStructure => _t('category.atomicStructure');
  String get moleculeBuilding => _t('category.moleculeBuilding');
  String get moleculePolarity => _t('category.moleculePolarity');
  String get moleculeShapes => _t('category.moleculeShapes');
  String get moleculesAndLight => _t('category.moleculesAndLight');
  String get reactantsProducts => _t('category.reactantsProducts');
  String get balancingEquations => _t('category.balancingEquations');
  String get statesOfMatter => _t('category.statesOfMatter');
}
