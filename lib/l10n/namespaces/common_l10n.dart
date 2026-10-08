import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/localization_format.dart';

/// `common.*` — cross-sim UI chrome and generic controls.
class CommonL10n {
  const CommonL10n(this.locale);

  final KartosLocale locale;

  static const Map<String, Map<KartosLocale, String>> _table = {
    'common.resetAll': {
      KartosLocale.zhCN: '全部重置',
      KartosLocale.en: 'Reset All',
    },
    'common.reset': {
      KartosLocale.zhCN: '重置',
      KartosLocale.en: 'Reset',
    },
    'common.play': {
      KartosLocale.zhCN: '播放',
      KartosLocale.en: 'Play',
    },
    'common.pause': {
      KartosLocale.zhCN: '暂停',
      KartosLocale.en: 'Pause',
    },
    'common.step': {
      KartosLocale.zhCN: '步进',
      KartosLocale.en: 'Step',
    },
    'common.stepForward': {
      KartosLocale.zhCN: '前进一帧',
      KartosLocale.en: 'Step Forward',
    },
    'common.restart': {
      KartosLocale.zhCN: '重新开始',
      KartosLocale.en: 'Restart',
    },
    'common.back': {
      KartosLocale.zhCN: '返回',
      KartosLocale.en: 'Back',
    },
    'common.close': {
      KartosLocale.zhCN: '关闭',
      KartosLocale.en: 'Close',
    },
    'common.ok': {
      KartosLocale.zhCN: '确定',
      KartosLocale.en: 'OK',
    },
    'common.cancel': {
      KartosLocale.zhCN: '取消',
      KartosLocale.en: 'Cancel',
    },
    'common.next': {
      KartosLocale.zhCN: '下一步',
      KartosLocale.en: 'Next',
    },
    'common.tryAgain': {
      KartosLocale.zhCN: '再试一次',
      KartosLocale.en: 'Try Again',
    },
    'common.showAnswer': {
      KartosLocale.zhCN: '显示答案',
      KartosLocale.en: 'Show Answer',
    },
    'common.normal': {
      KartosLocale.zhCN: '正常',
      KartosLocale.en: 'Normal',
    },
    'common.slow': {
      KartosLocale.zhCN: '慢速',
      KartosLocale.en: 'Slow',
    },
    'common.fast': {
      KartosLocale.zhCN: '快速',
      KartosLocale.en: 'Fast',
    },
    'common.fastForward': {
      KartosLocale.zhCN: '快进',
      KartosLocale.en: 'Fast Forward',
    },
    'common.stopwatch': {
      KartosLocale.zhCN: '秒表',
      KartosLocale.en: 'Stopwatch',
    },
    'common.options': {
      KartosLocale.zhCN: '选项',
      KartosLocale.en: 'Options',
    },
    'common.values': {
      KartosLocale.zhCN: '数值',
      KartosLocale.en: 'Values',
    },
    'common.none': {
      KartosLocale.zhCN: '无',
      KartosLocale.en: 'None',
    },
    'common.lots': {
      KartosLocale.zhCN: '很多',
      KartosLocale.en: 'Lots',
    },
    'common.custom': {
      KartosLocale.zhCN: '自定义',
      KartosLocale.en: 'Custom',
    },
    'common.intro': {
      KartosLocale.zhCN: '介绍',
      KartosLocale.en: 'Intro',
    },
    'common.lab': {
      KartosLocale.zhCN: '实验室',
      KartosLocale.en: 'Lab',
    },
    'common.explore': {
      KartosLocale.zhCN: '探索',
      KartosLocale.en: 'Explore',
    },
    'common.compare': {
      KartosLocale.zhCN: '比较',
      KartosLocale.en: 'Compare',
    },
    'common.game': {
      KartosLocale.zhCN: '游戏',
      KartosLocale.en: 'Game',
    },
    'common.grid': {
      KartosLocale.zhCN: '网格',
      KartosLocale.en: 'Grid',
    },
    'common.path': {
      KartosLocale.zhCN: '轨迹',
      KartosLocale.en: 'Path',
    },
    'common.graph': {
      KartosLocale.zhCN: '图像',
      KartosLocale.en: 'Graph',
    },
    'common.view': {
      KartosLocale.zhCN: '视图',
      KartosLocale.en: 'View',
    },
    'common.ruler': {
      KartosLocale.zhCN: '尺子',
      KartosLocale.en: 'Ruler',
    },
    'common.measuringTape': {
      KartosLocale.zhCN: '卷尺',
      KartosLocale.en: 'Measuring Tape',
    },
    'common.refresh': {
      KartosLocale.zhCN: '刷新',
      KartosLocale.en: 'Refresh',
    },
    'common.export': {
      KartosLocale.zhCN: '导出',
      KartosLocale.en: 'Export',
    },
    'common.clearAll': {
      KartosLocale.zhCN: '清空全部',
      KartosLocale.en: 'Clear All',
    },
    'common.deleteRow': {
      KartosLocale.zhCN: '删除该行',
      KartosLocale.en: 'Delete Row',
    },
    'common.loading': {
      KartosLocale.zhCN: '加载中…',
      KartosLocale.en: 'Loading…',
    },
    'common.error': {
      KartosLocale.zhCN: '出错了',
      KartosLocale.en: 'Something went wrong',
    },
    'common.empty': {
      KartosLocale.zhCN: '暂无内容',
      KartosLocale.en: 'Nothing here yet',
    },
    'common.unavailable': {
      KartosLocale.zhCN: '暂不可用',
      KartosLocale.en: 'Unavailable',
    },
    'common.simCount': {
      KartosLocale.zhCN: '{count} 个实验',
      KartosLocale.en: '{count} simulations',
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

  /// All keys owned by this namespace (for integrity tests).
  static Iterable<String> get keys => _table.keys;

  String get resetAll => _t('common.resetAll');
  String get reset => _t('common.reset');
  String get play => _t('common.play');
  String get pause => _t('common.pause');
  String get step => _t('common.step');
  String get stepForward => _t('common.stepForward');
  String get restart => _t('common.restart');
  String get back => _t('common.back');
  String get close => _t('common.close');
  String get ok => _t('common.ok');
  String get cancel => _t('common.cancel');
  String get next => _t('common.next');
  String get tryAgain => _t('common.tryAgain');
  String get showAnswer => _t('common.showAnswer');
  String get normal => _t('common.normal');
  String get slow => _t('common.slow');
  String get fast => _t('common.fast');
  String get fastForward => _t('common.fastForward');
  String get stopwatch => _t('common.stopwatch');
  String get options => _t('common.options');
  String get values => _t('common.values');
  String get none => _t('common.none');
  String get lots => _t('common.lots');
  String get custom => _t('common.custom');
  String get intro => _t('common.intro');
  String get lab => _t('common.lab');
  String get explore => _t('common.explore');
  String get compare => _t('common.compare');
  String get game => _t('common.game');
  String get grid => _t('common.grid');
  String get path => _t('common.path');
  String get graph => _t('common.graph');
  String get view => _t('common.view');
  String get ruler => _t('common.ruler');
  String get measuringTape => _t('common.measuringTape');
  String get refresh => _t('common.refresh');
  String get export => _t('common.export');
  String get clearAll => _t('common.clearAll');
  String get deleteRow => _t('common.deleteRow');
  String get loading => _t('common.loading');
  String get error => _t('common.error');
  String get empty => _t('common.empty');
  String get unavailable => _t('common.unavailable');

  String simCount(int count) => _t('common.simCount', {'count': count});
}
