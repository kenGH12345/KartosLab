import 'model/domain.dart';
import 'model/equation_form.dart';
import 'model/series_type.dart';
import 'model/waveform_kind.dart';

/// Chinese UI strings for Fourier: Making Waves.
class FmwStrings {
  FmwStrings._();

  static const String title = 'Fourier: Making Waves';

  static const String tabDiscrete = '离散';
  static const String tabWaveGame = '波形游戏';
  static const String tabWavePacket = '波包';

  static const String amplitudes = '振幅';
  static const String harmonics = '谐波';
  static const String sum = '合成';
  static const String components = '傅里叶分量';
  static const String envelope = '包络';

  static const String waveform = '波形';
  static const String harmonicsCount = '谐波数';
  static const String domain = '自变量';
  static const String seriesType = '级数类型';
  static const String infiniteHarmonics = '无限谐波';
  static const String erase = '清零';
  static const String zoomIn = '放大';
  static const String zoomOut = '缩小';
  static const String reset = '重置';
  static const String equation = '方程形式';
  static const String measurementTools = '测量工具';
  static const String wavelength = '波长 λ';
  static const String period = '周期 T';

  static const String play = '播放';
  static const String pause = '暂停';
  static const String step = '步进';

  static const String checkAnswer = '检查答案';
  static const String showAnswer = '显示答案';
  static const String newWaveform = '新波形';
  static const String backToLevels = '返回关卡';
  static const String score = '得分';
  static const String level = '关卡';
  static const String amplitudeControls = '振幅控件数';
  static const String selectLevel = '选择关卡';
  static const String matched = '匹配！';
  static const String tryAgain = '再试一次';

  static const String componentSpacing = '分量间距';
  static const String center = '中心';
  static const String width = '宽度';
  static const String standardDeviation = '标准差 σ';
  static const String conjugateWidth = '共轭宽度';
  static const String showWidthIndicators = '显示宽度指示';
  static const String showEnvelope = '显示包络';
  static const String showContinuous = '连续波形';

  static const String oopsSawtoothCos =
      '锯齿波与余弦级数不兼容，已切换为正弦级数。';

  static String waveformName(WaveformKind kind) {
    switch (kind) {
      case WaveformKind.sinusoid:
        return '正弦';
      case WaveformKind.triangle:
        return '三角';
      case WaveformKind.square:
        return '方波';
      case WaveformKind.sawtooth:
        return '锯齿';
      case WaveformKind.wavePacket:
        return '波包';
      case WaveformKind.custom:
        return '自定义';
    }
  }

  static String domainLabel(Domain domain) {
    switch (domain) {
      case Domain.space:
        return 'x';
      case Domain.time:
        return 't';
      case Domain.spaceAndTime:
        return 'x, t';
    }
  }

  static String seriesLabel(SeriesType type) {
    switch (type) {
      case SeriesType.sin:
        return 'sin';
      case SeriesType.cos:
        return 'cos';
    }
  }

  static String levelLabel(int n) => '关卡 $n';

  static String harmonicLabel(int order) => 'A$order';

  static String scoreLabel(int score) => '得分：$score';

  static String equationFormName(EquationForm form) {
    switch (form) {
      case EquationForm.hidden:
        return '隐藏';
      case EquationForm.mode:
        return '模式 n';
      case EquationForm.wavelength:
        return '波长 λ';
      case EquationForm.spatialWaveNumber:
        return '波数 k';
      case EquationForm.frequency:
        return '频率 f';
      case EquationForm.period:
        return '周期 T';
      case EquationForm.angularWaveNumber:
        return '角频率 ω';
      case EquationForm.wavelengthAndPeriod:
        return 'λ 与 T';
      case EquationForm.spatialAndAngular:
        return 'k 与 ω';
    }
  }
}
