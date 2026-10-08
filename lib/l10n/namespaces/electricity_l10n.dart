import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/localization_format.dart';

/// Electricity / circuits / EM terminology (`electricity.*`).
///
/// Shared physics terms prefer [PhysicsL10n] (voltage, current, resistance…).
class ElectricityL10n {
  const ElectricityL10n(this.locale);

  final KartosLocale locale;

  static const Map<String, Map<KartosLocale, String>> _table = {
    'electricity.circuit': {KartosLocale.zhCN: '电路', KartosLocale.en: 'Circuit'},
    'electricity.wire': {KartosLocale.zhCN: '导线', KartosLocale.en: 'Wire'},
    'electricity.battery': {KartosLocale.zhCN: '电池', KartosLocale.en: 'Battery'},
    'electricity.lightBulb': {
      KartosLocale.zhCN: '灯泡',
      KartosLocale.en: 'Light Bulb',
    },
    'electricity.resistor': {
      KartosLocale.zhCN: '电阻器',
      KartosLocale.en: 'Resistor',
    },
    'electricity.capacitor': {
      KartosLocale.zhCN: '电容器',
      KartosLocale.en: 'Capacitor',
    },
    'electricity.capacitance': {
      KartosLocale.zhCN: '电容',
      KartosLocale.en: 'Capacitance',
    },
    'electricity.inductor': {
      KartosLocale.zhCN: '电感器',
      KartosLocale.en: 'Inductor',
    },
    'electricity.switch': {KartosLocale.zhCN: '开关', KartosLocale.en: 'Switch'},
    'electricity.fuse': {KartosLocale.zhCN: '保险丝', KartosLocale.en: 'Fuse'},
    'electricity.voltmeter': {
      KartosLocale.zhCN: '电压表',
      KartosLocale.en: 'Voltmeter',
    },
    'electricity.ammeter': {
      KartosLocale.zhCN: '电流表',
      KartosLocale.en: 'Ammeter',
    },
    'electricity.electrons': {
      KartosLocale.zhCN: '电子',
      KartosLocale.en: 'Electrons',
    },
    'electricity.conventional': {
      KartosLocale.zhCN: '常规电流',
      KartosLocale.en: 'Conventional',
    },
    'electricity.showCurrent': {
      KartosLocale.zhCN: '显示电流',
      KartosLocale.en: 'Show Current',
    },
    'electricity.labels': {KartosLocale.zhCN: '标签', KartosLocale.en: 'Labels'},
    'electricity.values': {KartosLocale.zhCN: '数值', KartosLocale.en: 'Values'},
    'electricity.acVoltage': {
      KartosLocale.zhCN: '交流电压',
      KartosLocale.en: 'AC Voltage',
    },
    'electricity.resistivity': {
      KartosLocale.zhCN: '电阻率',
      KartosLocale.en: 'Resistivity',
    },
    'electricity.length': {KartosLocale.zhCN: '长度', KartosLocale.en: 'Length'},
    'electricity.area': {KartosLocale.zhCN: '截面积', KartosLocale.en: 'Area'},
    'electricity.equipotential': {
      KartosLocale.zhCN: '等势',
      KartosLocale.en: 'Equipotential',
    },
    'electricity.directionOnly': {
      KartosLocale.zhCN: '仅方向',
      KartosLocale.en: 'Direction only',
    },
    'electricity.sensors': {KartosLocale.zhCN: '传感器', KartosLocale.en: 'Sensors'},
    'electricity.snapToGrid': {
      KartosLocale.zhCN: '对齐网格',
      KartosLocale.en: 'Snap to Grid',
    },
    'electricity.grid': {KartosLocale.zhCN: '网格', KartosLocale.en: 'Grid'},
    'electricity.magneticField': {
      KartosLocale.zhCN: '磁场',
      KartosLocale.en: 'Magnetic Field',
    },
    'electricity.fieldLines': {
      KartosLocale.zhCN: '磁场线',
      KartosLocale.en: 'Field Lines',
    },
    'electricity.flipMagnet': {
      KartosLocale.zhCN: '翻转磁铁',
      KartosLocale.en: 'Flip Magnet',
    },
    'electricity.flipPolarity': {
      KartosLocale.zhCN: '翻转极性',
      KartosLocale.en: 'Flip Polarity',
    },
    'electricity.barMagnet': {
      KartosLocale.zhCN: '条形磁铁',
      KartosLocale.en: 'Bar Magnet',
    },
    'electricity.compass': {KartosLocale.zhCN: '罗盘', KartosLocale.en: 'Compass'},
    'electricity.fieldMeter': {
      KartosLocale.zhCN: '磁场计',
      KartosLocale.en: 'Field Meter',
    },
    'electricity.strength': {KartosLocale.zhCN: '强度', KartosLocale.en: 'Strength'},
    'electricity.seeInside': {
      KartosLocale.zhCN: '查看内部',
      KartosLocale.en: 'See Inside',
    },
    'electricity.earth': {KartosLocale.zhCN: '地球', KartosLocale.en: 'Earth'},
    'electricity.circuitMode': {
      KartosLocale.zhCN: '电路模式',
      KartosLocale.en: 'Circuit Mode',
    },
    'electricity.plateCharges': {
      KartosLocale.zhCN: '极板电荷',
      KartosLocale.en: 'Plate Charges',
    },
    'electricity.barGraphs': {
      KartosLocale.zhCN: '柱状图',
      KartosLocale.en: 'Bar Graphs',
    },
    'electricity.currentDirection': {
      KartosLocale.zhCN: '电流方向',
      KartosLocale.en: 'Current Direction',
    },
    'electricity.plateArea': {
      KartosLocale.zhCN: '极板面积',
      KartosLocale.en: 'Plate Area',
    },
    'electricity.separation': {
      KartosLocale.zhCN: '间距',
      KartosLocale.en: 'Separation',
    },
    'electricity.topPlateCharge': {
      KartosLocale.zhCN: '上极板电荷',
      KartosLocale.en: 'Top Plate Charge',
    },
    'electricity.storedEnergy': {
      KartosLocale.zhCN: '储存能量',
      KartosLocale.en: 'Stored Energy',
    },
    'electricity.a11y.increaseVoltage': {
      KartosLocale.zhCN: '增大电压',
      KartosLocale.en: 'Increase Voltage',
    },
    'electricity.a11y.decreaseVoltage': {
      KartosLocale.zhCN: '减小电压',
      KartosLocale.en: 'Decrease Voltage',
    },
    'electricity.a11y.increaseResistance': {
      KartosLocale.zhCN: '增大电阻',
      KartosLocale.en: 'Increase Resistance',
    },
    'electricity.a11y.decreaseResistance': {
      KartosLocale.zhCN: '减小电阻',
      KartosLocale.en: 'Decrease Resistance',
    },
    'electricity.a11y.switchOn': {
      KartosLocale.zhCN: '闭合开关',
      KartosLocale.en: 'Turn Switch On',
    },
    'electricity.a11y.switchOff': {
      KartosLocale.zhCN: '断开开关',
      KartosLocale.en: 'Turn Switch Off',
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

  String get circuit => _t('electricity.circuit');
  String get wire => _t('electricity.wire');
  String get battery => _t('electricity.battery');
  String get lightBulb => _t('electricity.lightBulb');
  String get resistor => _t('electricity.resistor');
  String get capacitor => _t('electricity.capacitor');
  String get capacitance => _t('electricity.capacitance');
  String get inductor => _t('electricity.inductor');
  String get switchLabel => _t('electricity.switch');
  String get fuse => _t('electricity.fuse');
  String get voltmeter => _t('electricity.voltmeter');
  String get ammeter => _t('electricity.ammeter');
  String get electrons => _t('electricity.electrons');
  String get conventional => _t('electricity.conventional');
  String get showCurrent => _t('electricity.showCurrent');
  String get labels => _t('electricity.labels');
  String get values => _t('electricity.values');
  String get acVoltage => _t('electricity.acVoltage');
  String get resistivity => _t('electricity.resistivity');
  String get length => _t('electricity.length');
  String get area => _t('electricity.area');
  String get equipotential => _t('electricity.equipotential');
  String get directionOnly => _t('electricity.directionOnly');
  String get sensors => _t('electricity.sensors');
  String get snapToGrid => _t('electricity.snapToGrid');
  String get grid => _t('electricity.grid');
  String get magneticField => _t('electricity.magneticField');
  String get fieldLines => _t('electricity.fieldLines');
  String get flipMagnet => _t('electricity.flipMagnet');
  String get flipPolarity => _t('electricity.flipPolarity');
  String get barMagnet => _t('electricity.barMagnet');
  String get compass => _t('electricity.compass');
  String get fieldMeter => _t('electricity.fieldMeter');
  String get strength => _t('electricity.strength');
  String get seeInside => _t('electricity.seeInside');
  String get earth => _t('electricity.earth');
  String get circuitMode => _t('electricity.circuitMode');
  String get plateCharges => _t('electricity.plateCharges');
  String get barGraphs => _t('electricity.barGraphs');
  String get currentDirection => _t('electricity.currentDirection');
  String get plateArea => _t('electricity.plateArea');
  String get separation => _t('electricity.separation');
  String get topPlateCharge => _t('electricity.topPlateCharge');
  String get storedEnergy => _t('electricity.storedEnergy');

  String get increaseVoltage => _t('electricity.a11y.increaseVoltage');
  String get decreaseVoltage => _t('electricity.a11y.decreaseVoltage');
  String get increaseResistance => _t('electricity.a11y.increaseResistance');
  String get decreaseResistance => _t('electricity.a11y.decreaseResistance');
  String get switchOn => _t('electricity.a11y.switchOn');
  String get switchOff => _t('electricity.a11y.switchOff');
}
