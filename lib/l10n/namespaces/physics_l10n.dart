import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/localization_format.dart';

/// Canonical physics / chemistry terminology (`physics.*`).
///
/// Conflicts (mass/weight, gravity/gravityForce, velocity/speed) are documented
/// in `requirements/localization/GLOSSARY_CONFLICTS.md`.
class PhysicsL10n {
  const PhysicsL10n(this.locale);

  final KartosLocale locale;

  static const Map<String, Map<KartosLocale, String>> _table = {
    'physics.force': {KartosLocale.zhCN: '力', KartosLocale.en: 'Force'},
    'physics.netForce': {KartosLocale.zhCN: '合力', KartosLocale.en: 'Net Force'},
    'physics.gravity': {KartosLocale.zhCN: '重力', KartosLocale.en: 'Gravity'},
    'physics.gravityForce': {
      KartosLocale.zhCN: '引力',
      KartosLocale.en: 'Gravity Force',
    },
    'physics.mass': {KartosLocale.zhCN: '质量', KartosLocale.en: 'Mass'},
    'physics.weight': {KartosLocale.zhCN: '重量', KartosLocale.en: 'Weight'},
    'physics.density': {KartosLocale.zhCN: '密度', KartosLocale.en: 'Density'},
    'physics.volume': {KartosLocale.zhCN: '体积', KartosLocale.en: 'Volume'},
    'physics.pressure': {KartosLocale.zhCN: '压强', KartosLocale.en: 'Pressure'},
    'physics.buoyancy': {KartosLocale.zhCN: '浮力', KartosLocale.en: 'Buoyancy'},
    'physics.buoyantForce': {
      KartosLocale.zhCN: '浮力',
      KartosLocale.en: 'Buoyant Force',
    },
    'physics.displacement': {
      KartosLocale.zhCN: '位移',
      KartosLocale.en: 'Displacement',
    },
    'physics.displacedVolume': {
      KartosLocale.zhCN: '排开体积',
      KartosLocale.en: 'Displaced Volume',
    },
    'physics.velocity': {KartosLocale.zhCN: '速度', KartosLocale.en: 'Velocity'},
    'physics.speed': {KartosLocale.zhCN: '速率', KartosLocale.en: 'Speed'},
    'physics.acceleration': {
      KartosLocale.zhCN: '加速度',
      KartosLocale.en: 'Acceleration',
    },
    'physics.wavelength': {
      KartosLocale.zhCN: '波长',
      KartosLocale.en: 'Wavelength',
    },
    'physics.frequency': {
      KartosLocale.zhCN: '频率',
      KartosLocale.en: 'Frequency',
    },
    'physics.amplitude': {
      KartosLocale.zhCN: '振幅',
      KartosLocale.en: 'Amplitude',
    },
    'physics.particle': {KartosLocale.zhCN: '粒子', KartosLocale.en: 'Particle'},
    'physics.particles': {
      KartosLocale.zhCN: '粒子',
      KartosLocale.en: 'Particles',
    },
    'physics.molecule': {KartosLocale.zhCN: '分子', KartosLocale.en: 'Molecule'},
    'physics.atom': {KartosLocale.zhCN: '原子', KartosLocale.en: 'Atom'},
    'physics.electricField': {
      KartosLocale.zhCN: '电场',
      KartosLocale.en: 'Electric Field',
    },
    'physics.voltage': {KartosLocale.zhCN: '电压', KartosLocale.en: 'Voltage'},
    'physics.current': {KartosLocale.zhCN: '电流', KartosLocale.en: 'Current'},
    'physics.resistance': {
      KartosLocale.zhCN: '电阻',
      KartosLocale.en: 'Resistance',
    },
    'physics.energy': {KartosLocale.zhCN: '能量', KartosLocale.en: 'Energy'},
    'physics.kineticEnergy': {
      KartosLocale.zhCN: '动能',
      KartosLocale.en: 'Kinetic Energy',
    },
    'physics.potentialEnergy': {
      KartosLocale.zhCN: '势能',
      KartosLocale.en: 'Potential Energy',
    },
    'physics.friction': {KartosLocale.zhCN: '摩擦', KartosLocale.en: 'Friction'},
    'physics.frictionForce': {
      KartosLocale.zhCN: '摩擦力',
      KartosLocale.en: 'Friction Force',
    },
    'physics.material': {KartosLocale.zhCN: '材料', KartosLocale.en: 'Material'},
    'physics.centerOfMass': {
      KartosLocale.zhCN: '质心',
      KartosLocale.en: 'Center of Mass',
    },
    'physics.massWithValue': {
      KartosLocale.zhCN: '质量: {value} kg',
      KartosLocale.en: 'Mass: {value} kg',
    },
    'physics.volumeWithValue': {
      KartosLocale.zhCN: '体积: {value} m³',
      KartosLocale.en: 'Volume: {value} m³',
    },
    'physics.densityWithValue': {
      KartosLocale.zhCN: '密度: {value} kg/m³',
      KartosLocale.en: 'Density: {value} kg/m³',
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

  String get force => _t('physics.force');
  String get netForce => _t('physics.netForce');
  String get gravity => _t('physics.gravity');
  String get gravityForce => _t('physics.gravityForce');
  String get mass => _t('physics.mass');
  String get weight => _t('physics.weight');
  String get density => _t('physics.density');
  String get volume => _t('physics.volume');
  String get pressure => _t('physics.pressure');
  String get buoyancy => _t('physics.buoyancy');
  String get buoyantForce => _t('physics.buoyantForce');
  String get displacement => _t('physics.displacement');
  String get displacedVolume => _t('physics.displacedVolume');
  String get velocity => _t('physics.velocity');
  String get speed => _t('physics.speed');
  String get acceleration => _t('physics.acceleration');
  String get wavelength => _t('physics.wavelength');
  String get frequency => _t('physics.frequency');
  String get amplitude => _t('physics.amplitude');
  String get particle => _t('physics.particle');
  String get particles => _t('physics.particles');
  String get molecule => _t('physics.molecule');
  String get atom => _t('physics.atom');
  String get electricField => _t('physics.electricField');
  String get voltage => _t('physics.voltage');
  String get current => _t('physics.current');
  String get resistance => _t('physics.resistance');
  String get energy => _t('physics.energy');
  String get kineticEnergy => _t('physics.kineticEnergy');
  String get potentialEnergy => _t('physics.potentialEnergy');
  String get friction => _t('physics.friction');
  String get frictionForce => _t('physics.frictionForce');
  String get material => _t('physics.material');
  String get centerOfMass => _t('physics.centerOfMass');

  String massWithValue(Object value) =>
      _t('physics.massWithValue', {'value': value});
  String volumeWithValue(Object value) =>
      _t('physics.volumeWithValue', {'value': value});
  String densityWithValue(Object value) =>
      _t('physics.densityWithValue', {'value': value});
}
