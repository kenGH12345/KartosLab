import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/localization_format.dart';

/// Fluids / density / buoyancy / gases terminology (`fluids.*`).
///
/// Shared physics terms prefer [PhysicsL10n] / [CommonL10n].
class FluidsL10n {
  const FluidsL10n(this.locale);

  final KartosLocale locale;

  static const Map<String, Map<KartosLocale, String>> _table = {
    'fluids.fluid': {KartosLocale.zhCN: '流体', KartosLocale.en: 'Fluid'},
    'fluids.liquid': {KartosLocale.zhCN: '液体', KartosLocale.en: 'Liquid'},
    'fluids.gas': {KartosLocale.zhCN: '气体', KartosLocale.en: 'Gas'},
    'fluids.atmosphere': {
      KartosLocale.zhCN: '大气',
      KartosLocale.en: 'Atmosphere',
    },
    'fluids.atmosphericPressure': {
      KartosLocale.zhCN: '大气压',
      KartosLocale.en: 'Atmospheric Pressure',
    },
    'fluids.temperature': {
      KartosLocale.zhCN: '温度',
      KartosLocale.en: 'Temperature',
    },
    'fluids.container': {
      KartosLocale.zhCN: '容器',
      KartosLocale.en: 'Container',
    },
    'fluids.piston': {KartosLocale.zhCN: '活塞', KartosLocale.en: 'Piston'},
    'fluids.pump': {KartosLocale.zhCN: '泵', KartosLocale.en: 'Pump'},
    'fluids.fluidDensity': {
      KartosLocale.zhCN: '流体密度',
      KartosLocale.en: 'Fluid Density',
    },
    'fluids.fluidDisplaced': {
      KartosLocale.zhCN: '排开的流体',
      KartosLocale.en: 'Fluid Displaced',
    },
    'fluids.objectDensity': {
      KartosLocale.zhCN: '物体密度',
      KartosLocale.en: 'Object Density',
    },
    'fluids.percentSubmerged': {
      KartosLocale.zhCN: '浸没百分比',
      KartosLocale.en: '% Submerged',
    },
    'fluids.holdConstant': {
      KartosLocale.zhCN: '保持恒定',
      KartosLocale.en: 'Hold Constant',
    },
    'fluids.returnLid': {
      KartosLocale.zhCN: '放回盖子',
      KartosLocale.en: 'Return Lid',
    },
    'fluids.heavy': {KartosLocale.zhCN: '重粒子', KartosLocale.en: 'Heavy'},
    'fluids.light': {KartosLocale.zhCN: '轻粒子', KartosLocale.en: 'Light'},
    'fluids.contactForce': {
      KartosLocale.zhCN: '接触力',
      KartosLocale.en: 'Contact',
    },
    'fluids.forceValues': {
      KartosLocale.zhCN: '力数值',
      KartosLocale.en: 'Force Values',
    },
    'fluids.massValues': {
      KartosLocale.zhCN: '质量数值',
      KartosLocale.en: 'Mass Values',
    },
    'fluids.depthLines': {
      KartosLocale.zhCN: '深度线',
      KartosLocale.en: 'Depth Lines',
    },
    'fluids.vectorZoom': {
      KartosLocale.zhCN: '矢量缩放',
      KartosLocale.en: 'Vector Zoom',
    },
    'fluids.blocks': {KartosLocale.zhCN: '物块', KartosLocale.en: 'Blocks'},
    'fluids.shape': {KartosLocale.zhCN: '形状', KartosLocale.en: 'Shape'},
    'fluids.width': {KartosLocale.zhCN: '宽度', KartosLocale.en: 'Width'},
    'fluids.height': {KartosLocale.zhCN: '高度', KartosLocale.en: 'Height'},
    'fluids.ruler': {KartosLocale.zhCN: '直尺', KartosLocale.en: 'Ruler'},
    'fluids.grid': {KartosLocale.zhCN: '网格', KartosLocale.en: 'Grid'},
    'fluids.on': {KartosLocale.zhCN: '开', KartosLocale.en: 'On'},
    'fluids.off': {KartosLocale.zhCN: '关', KartosLocale.en: 'Off'},
    'fluids.units': {KartosLocale.zhCN: '单位', KartosLocale.en: 'Units'},
    'fluids.metric': {KartosLocale.zhCN: '公制', KartosLocale.en: 'Metric'},
    'fluids.atmospheres': {
      KartosLocale.zhCN: '大气压',
      KartosLocale.en: 'Atmospheres',
    },
    'fluids.englishUnits': {
      KartosLocale.zhCN: '英制',
      KartosLocale.en: 'English',
    },
    'fluids.stopwatch': {
      KartosLocale.zhCN: '秒表',
      KartosLocale.en: 'Stopwatch',
    },
    'fluids.collisions': {
      KartosLocale.zhCN: '碰撞',
      KartosLocale.en: 'Collisions',
    },
    'fluids.collisionCounter': {
      KartosLocale.zhCN: '碰撞计数器',
      KartosLocale.en: 'Collision Counter',
    },
    'fluids.nothing': {KartosLocale.zhCN: '无', KartosLocale.en: 'Nothing'},
    'fluids.removeDivider': {
      KartosLocale.zhCN: '移除隔板',
      KartosLocale.en: 'Remove Divider',
    },
    'fluids.resetDivider': {
      KartosLocale.zhCN: '重置隔板',
      KartosLocale.en: 'Reset Divider',
    },
    'fluids.particleFlowRate': {
      KartosLocale.zhCN: '粒子流率',
      KartosLocale.en: 'Particle Flow Rate',
    },
    'fluids.normal': {KartosLocale.zhCN: '正常', KartosLocale.en: 'Normal'},
    'fluids.slow': {KartosLocale.zhCN: '慢速', KartosLocale.en: 'Slow'},
    'fluids.heat': {KartosLocale.zhCN: '加热', KartosLocale.en: 'Heat'},
    'fluids.cool': {KartosLocale.zhCN: '冷却', KartosLocale.en: 'Cool'},
    'fluids.injectionTemperature': {
      KartosLocale.zhCN: '注入温度',
      KartosLocale.en: 'Injection Temperature',
    },
    'fluids.matchContainer': {
      KartosLocale.zhCN: '匹配容器',
      KartosLocale.en: 'Match Container',
    },
    'fluids.averageSpeed': {
      KartosLocale.zhCN: '平均速率',
      KartosLocale.en: 'Average Speed',
    },
    'fluids.wallVelocity': {
      KartosLocale.zhCN: '壁速',
      KartosLocale.en: 'Wall Velocity',
    },
    'fluids.wallCollisions': {
      KartosLocale.zhCN: '壁碰撞',
      KartosLocale.en: 'Wall Collisions',
    },
    'fluids.samplePeriod': {
      KartosLocale.zhCN: '采样周期',
      KartosLocale.en: 'Sample Period',
    },
    'fluids.left': {KartosLocale.zhCN: '左侧', KartosLocale.en: 'Left'},
    'fluids.right': {KartosLocale.zhCN: '右侧', KartosLocale.en: 'Right'},
    'fluids.outside': {KartosLocale.zhCN: '外侧', KartosLocale.en: 'Outside'},
    'fluids.inside': {KartosLocale.zhCN: '内侧', KartosLocale.en: 'Inside'},
    'fluids.solutes': {KartosLocale.zhCN: '溶质', KartosLocale.en: 'Solutes'},
    'fluids.soluteConcentrations': {
      KartosLocale.zhCN: '溶质浓度',
      KartosLocale.en: 'Solute Concentrations',
    },
    'fluids.charges': {KartosLocale.zhCN: '电荷', KartosLocale.en: 'Charges'},
    'fluids.membranePotential': {
      KartosLocale.zhCN: '膜电位 (mV)',
      KartosLocale.en: 'Membrane Potential (mV)',
    },
    'fluids.addLigands': {
      KartosLocale.zhCN: '添加配体',
      KartosLocale.en: 'Add Ligands',
    },
    'fluids.removeLigands': {
      KartosLocale.zhCN: '移除配体',
      KartosLocale.en: 'Remove Ligands',
    },
    'fluids.crossingHighlights': {
      KartosLocale.zhCN: '穿越高亮',
      KartosLocale.en: 'Crossing Highlights',
    },
    'fluids.crossingSounds': {
      KartosLocale.zhCN: '穿越音效',
      KartosLocale.en: 'Crossing Sounds',
    },
    'fluids.mysteryFluid': {
      KartosLocale.zhCN: '神秘流体',
      KartosLocale.en: 'Mystery Fluid',
    },
    'fluids.mysteryPlanet': {
      KartosLocale.zhCN: '神秘行星',
      KartosLocale.en: 'Mystery Planet',
    },
    'fluids.sameMass': {
      KartosLocale.zhCN: '相同质量',
      KartosLocale.en: 'Same Mass',
    },
    'fluids.sameVolume': {
      KartosLocale.zhCN: '相同体积',
      KartosLocale.en: 'Same Volume',
    },
    'fluids.sameDensity': {
      KartosLocale.zhCN: '相同密度',
      KartosLocale.en: 'Same Density',
    },
    'fluids.densityComparison': {
      KartosLocale.zhCN: '密度比较',
      KartosLocale.en: 'Density Comparison',
    },
    'fluids.custom': {KartosLocale.zhCN: '自定义', KartosLocale.en: 'Custom'},
    // Materials (shared density/buoyancy)
    'fluids.material.wood': {KartosLocale.zhCN: '木材', KartosLocale.en: 'Wood'},
    'fluids.material.ice': {KartosLocale.zhCN: '冰', KartosLocale.en: 'Ice'},
    'fluids.material.brick': {KartosLocale.zhCN: '砖', KartosLocale.en: 'Brick'},
    'fluids.material.aluminum': {
      KartosLocale.zhCN: '铝',
      KartosLocale.en: 'Aluminum',
    },
    'fluids.material.water': {KartosLocale.zhCN: '水', KartosLocale.en: 'Water'},
    'fluids.material.seawater': {
      KartosLocale.zhCN: '海水',
      KartosLocale.en: 'Seawater',
    },
    'fluids.material.oil': {KartosLocale.zhCN: '油', KartosLocale.en: 'Oil'},
    'fluids.material.gasoline': {
      KartosLocale.zhCN: '汽油',
      KartosLocale.en: 'Gasoline',
    },
    'fluids.material.honey': {KartosLocale.zhCN: '蜂蜜', KartosLocale.en: 'Honey'},
    'fluids.material.mercury': {
      KartosLocale.zhCN: '汞',
      KartosLocale.en: 'Mercury',
    },
    'fluids.material.styrofoam': {
      KartosLocale.zhCN: '泡沫塑料',
      KartosLocale.en: 'Styrofoam',
    },
    'fluids.material.pvc': {KartosLocale.zhCN: 'PVC', KartosLocale.en: 'PVC'},
    'fluids.material.steel': {KartosLocale.zhCN: '钢', KartosLocale.en: 'Steel'},
    'fluids.material.copper': {
      KartosLocale.zhCN: '铜',
      KartosLocale.en: 'Copper',
    },
    'fluids.material.lead': {KartosLocale.zhCN: '铅', KartosLocale.en: 'Lead'},
    'fluids.material.gold': {KartosLocale.zhCN: '金', KartosLocale.en: 'Gold'},
    'fluids.material.glass': {KartosLocale.zhCN: '玻璃', KartosLocale.en: 'Glass'},
    'fluids.material.diamond': {
      KartosLocale.zhCN: '金刚石',
      KartosLocale.en: 'Diamond',
    },
    'fluids.material.titanium': {
      KartosLocale.zhCN: '钛',
      KartosLocale.en: 'Titanium',
    },
    'fluids.a11y.increasePressure': {
      KartosLocale.zhCN: '增大压强',
      KartosLocale.en: 'Increase Pressure',
    },
    'fluids.a11y.decreasePressure': {
      KartosLocale.zhCN: '减小压强',
      KartosLocale.en: 'Decrease Pressure',
    },
    'fluids.a11y.increaseTemperature': {
      KartosLocale.zhCN: '升高温度',
      KartosLocale.en: 'Increase Temperature',
    },
    'fluids.a11y.decreaseTemperature': {
      KartosLocale.zhCN: '降低温度',
      KartosLocale.en: 'Decrease Temperature',
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

  String get fluid => _t('fluids.fluid');
  String get liquid => _t('fluids.liquid');
  String get gas => _t('fluids.gas');
  String get atmosphere => _t('fluids.atmosphere');
  String get atmosphericPressure => _t('fluids.atmosphericPressure');
  String get temperature => _t('fluids.temperature');
  String get container => _t('fluids.container');
  String get piston => _t('fluids.piston');
  String get pump => _t('fluids.pump');
  String get fluidDensity => _t('fluids.fluidDensity');
  String get fluidDisplaced => _t('fluids.fluidDisplaced');
  String get objectDensity => _t('fluids.objectDensity');
  String get percentSubmerged => _t('fluids.percentSubmerged');
  String get holdConstant => _t('fluids.holdConstant');
  String get returnLid => _t('fluids.returnLid');
  String get heavy => _t('fluids.heavy');
  String get light => _t('fluids.light');
  String get contactForce => _t('fluids.contactForce');
  String get forceValues => _t('fluids.forceValues');
  String get massValues => _t('fluids.massValues');
  String get depthLines => _t('fluids.depthLines');
  String get vectorZoom => _t('fluids.vectorZoom');
  String get blocks => _t('fluids.blocks');
  String get shape => _t('fluids.shape');
  String get width => _t('fluids.width');
  String get height => _t('fluids.height');
  String get ruler => _t('fluids.ruler');
  String get grid => _t('fluids.grid');
  String get on => _t('fluids.on');
  String get off => _t('fluids.off');
  String get units => _t('fluids.units');
  String get metric => _t('fluids.metric');
  String get atmospheres => _t('fluids.atmospheres');
  String get englishUnits => _t('fluids.englishUnits');
  String get stopwatch => _t('fluids.stopwatch');
  String get collisions => _t('fluids.collisions');
  String get collisionCounter => _t('fluids.collisionCounter');
  String get nothing => _t('fluids.nothing');
  String get removeDivider => _t('fluids.removeDivider');
  String get resetDivider => _t('fluids.resetDivider');
  String get particleFlowRate => _t('fluids.particleFlowRate');
  String get normal => _t('fluids.normal');
  String get slow => _t('fluids.slow');
  String get heat => _t('fluids.heat');
  String get cool => _t('fluids.cool');
  String get injectionTemperature => _t('fluids.injectionTemperature');
  String get matchContainer => _t('fluids.matchContainer');
  String get averageSpeed => _t('fluids.averageSpeed');
  String get wallVelocity => _t('fluids.wallVelocity');
  String get wallCollisions => _t('fluids.wallCollisions');
  String get samplePeriod => _t('fluids.samplePeriod');
  String get left => _t('fluids.left');
  String get right => _t('fluids.right');
  String get outside => _t('fluids.outside');
  String get inside => _t('fluids.inside');
  String get solutes => _t('fluids.solutes');
  String get soluteConcentrations => _t('fluids.soluteConcentrations');
  String get charges => _t('fluids.charges');
  String get membranePotential => _t('fluids.membranePotential');
  String get addLigands => _t('fluids.addLigands');
  String get removeLigands => _t('fluids.removeLigands');
  String get crossingHighlights => _t('fluids.crossingHighlights');
  String get crossingSounds => _t('fluids.crossingSounds');
  String get mysteryFluid => _t('fluids.mysteryFluid');
  String get mysteryPlanet => _t('fluids.mysteryPlanet');
  String get sameMass => _t('fluids.sameMass');
  String get sameVolume => _t('fluids.sameVolume');
  String get sameDensity => _t('fluids.sameDensity');
  String get densityComparison => _t('fluids.densityComparison');
  String get custom => _t('fluids.custom');

  String get increasePressure => _t('fluids.a11y.increasePressure');
  String get decreasePressure => _t('fluids.a11y.decreasePressure');
  String get increaseTemperature => _t('fluids.a11y.increaseTemperature');
  String get decreaseTemperature => _t('fluids.a11y.decreaseTemperature');

  String material(String id) {
    final key = 'fluids.material.$id';
    if (_table.containsKey(key)) return _t(key);
    return id;
  }
}
