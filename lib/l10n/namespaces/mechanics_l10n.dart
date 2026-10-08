import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/localization_format.dart';

/// Mechanics / gravity / vector terminology + sim-specific PHASE 2 keys.
///
/// Shared physics terms prefer [PhysicsL10n] / [CommonL10n]; this namespace
/// holds mechanics-domain and sim-specific UI copy.
class MechanicsL10n {
  const MechanicsL10n(this.locale);

  final KartosLocale locale;

  static const Map<String, Map<KartosLocale, String>> _table = {
    // Shared mechanics
    'mechanics.momentum': {
      KartosLocale.zhCN: '动量',
      KartosLocale.en: 'Momentum',
    },
    'mechanics.elasticity': {
      KartosLocale.zhCN: '弹性',
      KartosLocale.en: 'Elasticity',
    },
    'mechanics.inelastic': {
      KartosLocale.zhCN: '非弹性',
      KartosLocale.en: 'Inelastic',
    },
    'mechanics.position': {
      KartosLocale.zhCN: '位置',
      KartosLocale.en: 'Position',
    },
    'mechanics.angle': {
      KartosLocale.zhCN: '角度',
      KartosLocale.en: 'Angle',
    },
    'mechanics.distance': {
      KartosLocale.zhCN: '距离',
      KartosLocale.en: 'Distance',
    },
    'mechanics.radius': {
      KartosLocale.zhCN: '半径',
      KartosLocale.en: 'Radius',
    },
    'mechanics.height': {
      KartosLocale.zhCN: '高度',
      KartosLocale.en: 'Height',
    },
    'mechanics.length': {
      KartosLocale.zhCN: '长度',
      KartosLocale.en: 'Length',
    },
    'mechanics.period': {
      KartosLocale.zhCN: '周期',
      KartosLocale.en: 'Period',
    },
    'mechanics.work': {
      KartosLocale.zhCN: '功',
      KartosLocale.en: 'Work',
    },
    'mechanics.power': {
      KartosLocale.zhCN: '功率',
      KartosLocale.en: 'Power',
    },
    'mechanics.normalForce': {
      KartosLocale.zhCN: '支持力',
      KartosLocale.en: 'Normal Force',
    },
    'mechanics.tension': {
      KartosLocale.zhCN: '张力',
      KartosLocale.en: 'Tension',
    },
    'mechanics.magnitude': {
      KartosLocale.zhCN: '大小',
      KartosLocale.en: 'Magnitude',
    },
    'mechanics.component': {
      KartosLocale.zhCN: '分量',
      KartosLocale.en: 'Component',
    },
    'mechanics.components': {
      KartosLocale.zhCN: '分量',
      KartosLocale.en: 'Components',
    },
    'mechanics.vector': {
      KartosLocale.zhCN: '矢量',
      KartosLocale.en: 'Vector',
    },
    'mechanics.sum': {
      KartosLocale.zhCN: '和',
      KartosLocale.en: 'Sum',
    },
    'mechanics.orbit': {
      KartosLocale.zhCN: '轨道',
      KartosLocale.en: 'Orbit',
    },
    'mechanics.projectile': {
      KartosLocale.zhCN: '抛体',
      KartosLocale.en: 'Projectile',
    },
    'mechanics.meters': {
      KartosLocale.zhCN: '米',
      KartosLocale.en: 'meters',
    },
    'mechanics.billionKg': {
      KartosLocale.zhCN: '十亿千克',
      KartosLocale.en: 'billion kg',
    },
    'mechanics.forceValues': {
      KartosLocale.zhCN: '力的数值',
      KartosLocale.en: 'Force Values',
    },
    'mechanics.constantSize': {
      KartosLocale.zhCN: '恒定大小',
      KartosLocale.en: 'Constant Size',
    },
    'mechanics.airResistance': {
      KartosLocale.zhCN: '空气阻力',
      KartosLocale.en: 'Air Resistance',
    },
    'mechanics.initialSpeed': {
      KartosLocale.zhCN: '初速率',
      KartosLocale.en: 'Initial Speed',
    },
    'mechanics.explore1d': {
      KartosLocale.zhCN: '探索 1D',
      KartosLocale.en: 'Explore 1D',
    },
    'mechanics.explore2d': {
      KartosLocale.zhCN: '探索 2D',
      KartosLocale.en: 'Explore 2D',
    },
    'mechanics.go': {
      KartosLocale.zhCN: '开始!',
      KartosLocale.en: 'Go!',
    },
    'mechanics.return': {
      KartosLocale.zhCN: '返回',
      KartosLocale.en: 'Return',
    },
    // Planets / bodies
    'mechanics.earth': {KartosLocale.zhCN: '地球', KartosLocale.en: 'Earth'},
    'mechanics.moon': {KartosLocale.zhCN: '月球', KartosLocale.en: 'Moon'},
    'mechanics.jupiter': {KartosLocale.zhCN: '木星', KartosLocale.en: 'Jupiter'},
    'mechanics.planetX': {KartosLocale.zhCN: '行星 X', KartosLocale.en: 'Planet X'},
    'mechanics.mars': {KartosLocale.zhCN: '火星', KartosLocale.en: 'Mars'},
    'mechanics.mercury': {KartosLocale.zhCN: '水星', KartosLocale.en: 'Mercury'},
    'mechanics.venus': {KartosLocale.zhCN: '金星', KartosLocale.en: 'Venus'},
    'mechanics.ourSun': {KartosLocale.zhCN: '太阳', KartosLocale.en: 'Our Sun'},
    'mechanics.ourMoon': {KartosLocale.zhCN: '月球', KartosLocale.en: 'Our Moon'},
    'mechanics.spaceStation': {
      KartosLocale.zhCN: '空间站',
      KartosLocale.en: 'Space Station',
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

  String get momentum => _t('mechanics.momentum');
  String get elasticity => _t('mechanics.elasticity');
  String get inelastic => _t('mechanics.inelastic');
  String get position => _t('mechanics.position');
  String get angle => _t('mechanics.angle');
  String get distance => _t('mechanics.distance');
  String get radius => _t('mechanics.radius');
  String get height => _t('mechanics.height');
  String get length => _t('mechanics.length');
  String get period => _t('mechanics.period');
  String get work => _t('mechanics.work');
  String get power => _t('mechanics.power');
  String get normalForce => _t('mechanics.normalForce');
  String get tension => _t('mechanics.tension');
  String get magnitude => _t('mechanics.magnitude');
  String get component => _t('mechanics.component');
  String get components => _t('mechanics.components');
  String get vector => _t('mechanics.vector');
  String get sum => _t('mechanics.sum');
  String get orbit => _t('mechanics.orbit');
  String get projectile => _t('mechanics.projectile');
  String get meters => _t('mechanics.meters');
  String get billionKg => _t('mechanics.billionKg');
  String get forceValues => _t('mechanics.forceValues');
  String get constantSize => _t('mechanics.constantSize');
  String get airResistance => _t('mechanics.airResistance');
  String get initialSpeed => _t('mechanics.initialSpeed');
  String get explore1d => _t('mechanics.explore1d');
  String get explore2d => _t('mechanics.explore2d');
  String get go => _t('mechanics.go');
  String get returnLabel => _t('mechanics.return');
  String get earth => _t('mechanics.earth');
  String get moon => _t('mechanics.moon');
  String get jupiter => _t('mechanics.jupiter');
  String get planetX => _t('mechanics.planetX');
  String get mars => _t('mechanics.mars');
  String get mercury => _t('mechanics.mercury');
  String get venus => _t('mechanics.venus');
  String get ourSun => _t('mechanics.ourSun');
  String get ourMoon => _t('mechanics.ourMoon');
  String get spaceStation => _t('mechanics.spaceStation');
}
