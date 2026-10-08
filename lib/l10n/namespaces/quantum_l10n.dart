import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/localization_format.dart';

/// Quantum terminology (`quantum.*`).
class QuantumL10n {
  const QuantumL10n(this.locale);

  final KartosLocale locale;

  static const Map<String, Map<KartosLocale, String>> _table = {
    'quantum.quantum': {KartosLocale.zhCN: '量子', KartosLocale.en: 'Quantum'},
    'quantum.classical': {
      KartosLocale.zhCN: '经典',
      KartosLocale.en: 'Classical',
    },
    'quantum.photon': {KartosLocale.zhCN: '光子', KartosLocale.en: 'Photon'},
    'quantum.measurement': {
      KartosLocale.zhCN: '测量',
      KartosLocale.en: 'Measurement',
    },
    'quantum.observe': {KartosLocale.zhCN: '观测', KartosLocale.en: 'Observe'},
    'quantum.probability': {
      KartosLocale.zhCN: '概率',
      KartosLocale.en: 'Probability',
    },
    'quantum.superposition': {
      KartosLocale.zhCN: '叠加态',
      KartosLocale.en: 'Superposition',
    },
    'quantum.spin': {KartosLocale.zhCN: '自旋', KartosLocale.en: 'Spin'},
    'quantum.preparedState': {
      KartosLocale.zhCN: '制备态',
      KartosLocale.en: 'Prepared State',
    },
    'quantum.basisState': {
      KartosLocale.zhCN: '基态',
      KartosLocale.en: 'Basis State',
    },
    'quantum.experiment': {
      KartosLocale.zhCN: '实验',
      KartosLocale.en: 'Experiment',
    },
    'quantum.highIntensity': {
      KartosLocale.zhCN: '高强度',
      KartosLocale.en: 'High Intensity',
    },
    'quantum.singleParticles': {
      KartosLocale.zhCN: '单粒子',
      KartosLocale.en: 'Single Particles',
    },
    'quantum.detect': {KartosLocale.zhCN: '探测', KartosLocale.en: 'Detect'},
    'quantum.resetDetector': {
      KartosLocale.zhCN: '重置探测器',
      KartosLocale.en: 'Reset Detector',
    },
    'quantum.configuration': {
      KartosLocale.zhCN: '配置',
      KartosLocale.en: 'Configuration',
    },
    'quantum.intensity': {
      KartosLocale.zhCN: '强度',
      KartosLocale.en: 'Intensity',
    },
    'quantum.hits': {KartosLocale.zhCN: '击中', KartosLocale.en: 'Hits'},
    'quantum.coins': {KartosLocale.zhCN: '硬币', KartosLocale.en: 'Coins'},
    'quantum.photons': {KartosLocale.zhCN: '光子', KartosLocale.en: 'Photons'},
    'quantum.blochSphere': {
      KartosLocale.zhCN: '布洛赫球',
      KartosLocale.en: 'Bloch Sphere',
    },
    'quantum.heads': {KartosLocale.zhCN: '正面', KartosLocale.en: 'Heads'},
    'quantum.tails': {KartosLocale.zhCN: '反面', KartosLocale.en: 'Tails'},
    'quantum.up': {KartosLocale.zhCN: '上', KartosLocale.en: 'Up'},
    'quantum.down': {KartosLocale.zhCN: '下', KartosLocale.en: 'Down'},
    'quantum.reveal': {KartosLocale.zhCN: '揭示', KartosLocale.en: 'Reveal'},
    'quantum.hide': {KartosLocale.zhCN: '隐藏', KartosLocale.en: 'Hide'},
    'quantum.reprepare': {
      KartosLocale.zhCN: '重新制备',
      KartosLocale.en: 'Reprepare',
    },
    'quantum.flip': {KartosLocale.zhCN: '翻转', KartosLocale.en: 'Flip'},
    'quantum.newCoin': {KartosLocale.zhCN: '新硬币', KartosLocale.en: 'New Coin'},
    'quantum.snapshots': {
      KartosLocale.zhCN: '快照',
      KartosLocale.en: 'Snapshots',
    },
    'quantum.waveDisplay': {
      KartosLocale.zhCN: '波显示',
      KartosLocale.en: 'Wave Display',
    },
    'quantum.slitSeparation': {
      KartosLocale.zhCN: '缝间距',
      KartosLocale.en: 'Slit Separation',
    },
  };

  String _t(String key) {
    final row = _table[key];
    if (row == null) {
      assert(false, 'Missing localization key: $key');
      return key;
    }
    return locFormat(row[locale] ?? row[KartosLocale.zhCN] ?? key);
  }

  static Iterable<String> get keys => _table.keys;

  String get quantum => _t('quantum.quantum');
  String get classical => _t('quantum.classical');
  String get photon => _t('quantum.photon');
  String get measurement => _t('quantum.measurement');
  String get observe => _t('quantum.observe');
  String get probability => _t('quantum.probability');
  String get superposition => _t('quantum.superposition');
  String get spin => _t('quantum.spin');
  String get preparedState => _t('quantum.preparedState');
  String get basisState => _t('quantum.basisState');
  String get experiment => _t('quantum.experiment');
  String get highIntensity => _t('quantum.highIntensity');
  String get singleParticles => _t('quantum.singleParticles');
  String get detect => _t('quantum.detect');
  String get resetDetector => _t('quantum.resetDetector');
  String get configuration => _t('quantum.configuration');
  String get intensity => _t('quantum.intensity');
  String get hits => _t('quantum.hits');
  String get coins => _t('quantum.coins');
  String get photons => _t('quantum.photons');
  String get blochSphere => _t('quantum.blochSphere');
  String get heads => _t('quantum.heads');
  String get tails => _t('quantum.tails');
  String get up => _t('quantum.up');
  String get down => _t('quantum.down');
  String get reveal => _t('quantum.reveal');
  String get hide => _t('quantum.hide');
  String get reprepare => _t('quantum.reprepare');
  String get flip => _t('quantum.flip');
  String get newCoin => _t('quantum.newCoin');
  String get snapshots => _t('quantum.snapshots');
  String get waveDisplay => _t('quantum.waveDisplay');
  String get slitSeparation => _t('quantum.slitSeparation');
}
