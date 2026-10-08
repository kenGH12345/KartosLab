import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/localization_format.dart';

/// Optics + waves terminology (`optics.*` / `waves.*`).
class OpticsWavesL10n {
  const OpticsWavesL10n(this.locale);

  final KartosLocale locale;

  static const Map<String, Map<KartosLocale, String>> _table = {
    'optics.light': {KartosLocale.zhCN: '光', KartosLocale.en: 'Light'},
    'optics.ray': {KartosLocale.zhCN: '光线', KartosLocale.en: 'Ray'},
    'optics.beam': {KartosLocale.zhCN: '光束', KartosLocale.en: 'Beam'},
    'optics.reflection': {
      KartosLocale.zhCN: '反射',
      KartosLocale.en: 'Reflection',
    },
    'optics.refraction': {
      KartosLocale.zhCN: '折射',
      KartosLocale.en: 'Refraction',
    },
    'optics.normal': {KartosLocale.zhCN: '法线', KartosLocale.en: 'Normal'},
    'optics.indexOfRefraction': {
      KartosLocale.zhCN: '折射率 (n)',
      KartosLocale.en: 'Index of Refraction (n)',
    },
    'optics.angles': {KartosLocale.zhCN: '角度', KartosLocale.en: 'Angles'},
    'optics.prisms': {KartosLocale.zhCN: '棱镜', KartosLocale.en: 'Prisms'},
    'optics.moreTools': {
      KartosLocale.zhCN: '更多工具',
      KartosLocale.en: 'More Tools',
    },
    'optics.wave': {KartosLocale.zhCN: '波', KartosLocale.en: 'Wave'},
    'optics.whatIsN': {KartosLocale.zhCN: 'n 是什么？', KartosLocale.en: 'What is n?'},
    'optics.custom': {KartosLocale.zhCN: '自定义', KartosLocale.en: 'Custom'},
    'waves.graph': {KartosLocale.zhCN: '图像', KartosLocale.en: 'Graph'},
    'waves.screen': {KartosLocale.zhCN: '屏幕', KartosLocale.en: 'Screen'},
    'waves.playTone': {KartosLocale.zhCN: '播放音调', KartosLocale.en: 'Play Tone'},
    'waves.soundEffect': {
      KartosLocale.zhCN: '音效',
      KartosLocale.en: 'Sound Effect',
    },
    'waves.continuous': {
      KartosLocale.zhCN: '连续',
      KartosLocale.en: 'Continuous',
    },
    'waves.pulse': {KartosLocale.zhCN: '脉冲', KartosLocale.en: 'Pulse'},
    'waves.topView': {KartosLocale.zhCN: '俯视图', KartosLocale.en: 'Top View'},
    'waves.sideView': {KartosLocale.zhCN: '侧视图', KartosLocale.en: 'Side View'},
    'waves.water': {KartosLocale.zhCN: '水波', KartosLocale.en: 'Water'},
    'waves.sound': {KartosLocale.zhCN: '声波', KartosLocale.en: 'Sound'},
    'waves.both': {KartosLocale.zhCN: '两者', KartosLocale.en: 'Both'},
    'waves.level': {KartosLocale.zhCN: '水位', KartosLocale.en: 'Level'},
    'waves.viewpoint': {KartosLocale.zhCN: '视角', KartosLocale.en: 'Viewpoint'},
    'waves.normalModes': {
      KartosLocale.zhCN: '简正模式',
      KartosLocale.en: 'Normal Modes',
    },
    'waves.showPhases': {
      KartosLocale.zhCN: '显示相位',
      KartosLocale.en: 'Show Phases',
    },
    'waves.showSprings': {
      KartosLocale.zhCN: '显示弹簧',
      KartosLocale.en: 'Show Springs',
    },
    'waves.oneDimension': {
      KartosLocale.zhCN: '一维',
      KartosLocale.en: 'One Dimension',
    },
    'waves.twoDimensions': {
      KartosLocale.zhCN: '二维',
      KartosLocale.en: 'Two Dimensions',
    },
    'waves.period': {KartosLocale.zhCN: '周期', KartosLocale.en: 'Period'},
    'waves.phase': {KartosLocale.zhCN: '相位', KartosLocale.en: 'Phase'},
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

  String get light => _t('optics.light');
  String get ray => _t('optics.ray');
  String get beam => _t('optics.beam');
  String get reflection => _t('optics.reflection');
  String get refraction => _t('optics.refraction');
  String get normal => _t('optics.normal');
  String get indexOfRefraction => _t('optics.indexOfRefraction');
  String get angles => _t('optics.angles');
  String get prisms => _t('optics.prisms');
  String get moreTools => _t('optics.moreTools');
  String get wave => _t('optics.wave');
  String get whatIsN => _t('optics.whatIsN');
  String get custom => _t('optics.custom');
  String get graph => _t('waves.graph');
  String get screen => _t('waves.screen');
  String get playTone => _t('waves.playTone');
  String get soundEffect => _t('waves.soundEffect');
  String get continuous => _t('waves.continuous');
  String get pulse => _t('waves.pulse');
  String get topView => _t('waves.topView');
  String get sideView => _t('waves.sideView');
  String get water => _t('waves.water');
  String get sound => _t('waves.sound');
  String get both => _t('waves.both');
  String get level => _t('waves.level');
  String get viewpoint => _t('waves.viewpoint');
  String get normalModes => _t('waves.normalModes');
  String get showPhases => _t('waves.showPhases');
  String get showSprings => _t('waves.showSprings');
  String get oneDimension => _t('waves.oneDimension');
  String get twoDimensions => _t('waves.twoDimensions');
  String get period => _t('waves.period');
  String get phase => _t('waves.phase');
}
