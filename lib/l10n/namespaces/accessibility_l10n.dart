import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/localization_format.dart';

/// User-perceivable accessibility strings (`accessibility.*`).
///
/// Automation / test / registry IDs are NOT localized here.
class AccessibilityL10n {
  const AccessibilityL10n(this.locale);

  final KartosLocale locale;

  static const Map<String, Map<KartosLocale, String>> _table = {
    'accessibility.resetAll': {
      KartosLocale.zhCN: '全部重置',
      KartosLocale.en: 'Reset All',
    },
    'accessibility.play': {
      KartosLocale.zhCN: '播放',
      KartosLocale.en: 'Play',
    },
    'accessibility.pause': {
      KartosLocale.zhCN: '暂停',
      KartosLocale.en: 'Pause',
    },
    'accessibility.stepForward': {
      KartosLocale.zhCN: '前进一帧',
      KartosLocale.en: 'Step Forward',
    },
    'accessibility.restart': {
      KartosLocale.zhCN: '重新开始',
      KartosLocale.en: 'Restart',
    },
    'accessibility.increaseMass': {
      KartosLocale.zhCN: '增加质量',
      KartosLocale.en: 'Increase Mass',
    },
    'accessibility.decreaseMass': {
      KartosLocale.zhCN: '减小质量',
      KartosLocale.en: 'Decrease Mass',
    },
    'accessibility.increaseVolume': {
      KartosLocale.zhCN: '增加体积',
      KartosLocale.en: 'Increase Volume',
    },
    'accessibility.decreaseVolume': {
      KartosLocale.zhCN: '减小体积',
      KartosLocale.en: 'Decrease Volume',
    },
    'accessibility.openSimulation': {
      KartosLocale.zhCN: '打开实验：{title}',
      KartosLocale.en: 'Open simulation: {title}',
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

  String get resetAll => _t('accessibility.resetAll');
  String get play => _t('accessibility.play');
  String get pause => _t('accessibility.pause');
  String get stepForward => _t('accessibility.stepForward');
  String get restart => _t('accessibility.restart');
  String get increaseMass => _t('accessibility.increaseMass');
  String get decreaseMass => _t('accessibility.decreaseMass');
  String get increaseVolume => _t('accessibility.increaseVolume');
  String get decreaseVolume => _t('accessibility.decreaseVolume');

  String openSimulation(String title) =>
      _t('accessibility.openSimulation', {'title': title});
}
