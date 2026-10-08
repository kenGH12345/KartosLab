/// Chart Intro 视觉常量。只放本屏用到的颜色与像素，不改 Decay [BanConstants]。
///
/// 颜色 [已确认] `BANColors.ts`；壳层间距 [已确认] `BANConstants` / `ShellModelNucleus.ts`。
library;

import 'package:flutter/material.dart';

import '../ban_constants.dart';
import '../data/decay_type.dart';

class ChartIntroVisuals {
  const ChartIntroVisuals._();

  /// [已确认] ShredConstants.NUCLEON_RADIUS / BANConstants.PARTICLE_RADIUS
  static const double nucleonRadius = BanConstants.nucleonRadius;

  static const double nucleonDiameter = nucleonRadius * 2;

  /// 座位水平间距 = 半径。[已确认] PARTICLE_X_SPACING = PARTICLE_RADIUS
  static const double particleXSpacing = nucleonRadius;

  /// 能级竖直间距 = 4 个直径。[已确认] PARTICLE_Y_SPACING = PARTICLE_DIAMETER * 4
  static const double particleYSpacing = nucleonDiameter * 4;

  /// 质子列与中子列的水平偏移。
  /// [已确认] X_DISTANCE_BETWEEN_ENERGY_LEVELS = LAYOUT_BOUNDS.width / 4
  static const double energyLevelColumnGap =
      BanConstants.screenViewLayoutWidth / 4;

  /// 能级线空层色。[已确认] zeroNucleonsEnergyLevelColorProperty = black
  static const Color emptyEnergyLevel = Color(0xFF000000);

  /// 能级满层加粗。[已确认] NucleonShellView.boldEnergyLevelWidth = 4
  static const double energyLevelBoldWidth = 4;

  /// [已确认] NucleonShellView.defaultEnergyLevelWidth = 1
  static const double energyLevelDefaultWidth = 1;

  /// 壳层核子淡入淡出时长（秒）。
  /// [已确认] ChartIntroScreenView `FADE_ANINIMATION_DURATION = 1`
  /// Chart Intro β **不是** Decay 的 0.5s 换色。
  static const double shellFadeDuration = 1.0;

  /// α 从壳层取走的质子数。[已确认] `AlphaParticle.NUMBER_OF_ALLOWED_PROTONS = 2`
  static const int alphaProtonCount = 2;

  /// α 从壳层取走的中子数。[已确认] `AlphaParticle.NUMBER_OF_ALLOWED_NEUTRONS = 2`
  static const int alphaNeutronCount = 2;

  /// Partial 图格子边长。[已确认] getChartTransform(18)
  static const double partialCellSize = 18;

  /// Zoom-in 图格子边长。[已确认] getChartTransform(30)
  static const double zoomCellSize = 30;

  /// Focused 图格子边长。[已确认] getChartTransform(10)
  static const double focusedCellSize = 10;

  /// Focused 窗外格子透明度。[已确认] `makeOpaque` `> 2 ? 0.65 : 1`
  static const double focusedDimOpacity = 0.65;

  /// 窗外判定：|Δp| 或 |Δn| 大于该值才变淡。[已确认]
  static const int focusedDimDelta = 2;

  /// Focused 高亮框线宽。[已确认] HIGHLIGHT_RECTANGLE_LINE_WIDTH = 1.5
  static const double focusedHighlightStrokeWidth = 1.5;

  /// Zoom-in clip 中心夹紧：中子 2–10，质子 2–8。
  /// [已确认] `Utils.clamp(cellX, 2, 10)` / `Utils.clamp(cellY, 2, 8)`
  static const int zoomClampNeutronMin = 2;
  static const int zoomClampNeutronMax = 10;
  static const int zoomClampProtonMin = 2;
  static const int zoomClampProtonMax = 8;

  /// 单选底色。[已确认] chartRadioButtonsBackgroundColorProperty rgb(241,250,254)
  static const Color chartRadioBackground = Color(BanConstants.panelBackgroundValue);

  /// [已确认] `mostLikelyDecayType` / `stable` / `unknown` / `percentageInParenthesesPattern`
  static const String mostLikelyDecayType = '最可能衰变类型';
  static const String stableLabel = '稳定';
  static const String unknownLabel = '未知';
  static const String unknownPercentLiteral = '未知 ';
  static const String decayButtonLabel = '衰变';

  /// DecaySymbolNode Z 色。[已确认] `PhetColorScheme.RED_COLORBLIND` rgb(255,85,0)
  static const Color decayEquationProtonNumber = Color(0xFFFF5500);

  /// DecaySymbolNode 未缩放字号再 × scale。[已确认] `PhetFont(150)` / `PhetFont(100)` + `scale: 0.15`
  static const double decayEquationSymbolScale = 0.15;
  static const double decayEquationSymbolFontSize = 150 * decayEquationSymbolScale;
  static const double decayEquationNumberFontSize = 100 * decayEquationSymbolScale;
  static const double decayEquationNumberVSpacing = 15 * decayEquationSymbolScale;
  static const double decayEquationSymbolHSpacing = 20 * decayEquationSymbolScale;

  /// 方程行距。[已确认] `DecayEquationNode` VBox spacing 5 / HBox spacing 10
  static const double decayEquationVBoxSpacing = 5;
  static const double decayEquationHBoxSpacing = 10;
  static const double decayEquationMinHeight = 30;
  static const double decayEquationStableFontSize = 20;

  /// 方程箭头。[已确认] 长 25 + `DECAY_ARROW_OPTIONS`
  static const double decayEquationArrowLength = 25;
  static const double decayEquationArrowTailWidth = 3;
  static const Color decayEquationArrowFill = Color(0xFFFFFFFF);
  static const Color decayEquationArrowStroke = Color(0xFF000000);
  static const double decayEquationArrowStrokeWidth = 0.5;

  /// ArrowNode 默认 head。[已确认] scenery-phet `ArrowNode` headWidth/headHeight = 10
  static const double decayEquationArrowHeadWidth = 10;
  static const double decayEquationArrowHeadHeight = 10;

  /// 方程加号。[已确认] `IconFactory.createPlusNode` `Dimension2(9, 2)` + 黑色
  static const double decayEquationPlusWidth = 9;
  static const double decayEquationPlusThickness = 2;
  static const Color decayEquationPlus = Color(0xFF000000);

  /// 屏 / play 底。[已确认] `BANColors.screenBackgroundColorProperty` WHITE
  /// 只给 Chart Intro 本地 ColoredBox，不改 Theme。
  static const Color screenBackground = Color(BanConstants.screenBackgroundValue);

  /// [已确认] `BANConstants.REGULAR_FONT` PhetFont(20)
  static const double regularFontSize = 20;

  /// [已确认] `BANConstants.LEGEND_FONT` PhetFont(12)
  static const double legendFontSize = 12;

  /// [已确认] `BUTTONS_AND_LEGEND_FONT_SIZE` = 18
  static const double buttonsAndLegendFontSize = 18;

  /// 元素名。[已确认] `ElementNameText` `fill: Color.RED`
  static const Color elementNameColor = Color(0xFFFF0000);

  /// 计数面板核子图标。[已确认] `NUCLEON_PARTICLE_RADIUS = PARTICLE_RADIUS * 0.7`
  static const double nucleonNumberParticleRadius = nucleonRadius * 0.7;

  /// 计数两行最小竖距。[已确认] `MIN_VERTICAL_SPACING = 25`
  static const double nucleonNumberMinVerticalSpacing = 25;

  /// 手风琴标题。[已确认] `partialNuclideChart`
  static const String partialNuclideChartTitle = '部分核素图';

  /// [已确认] `NuclearShellModelText`
  static const String nuclearShellModelLabel = '核壳层模型';

  /// [已确认] Nuclear Shell 高亮底 rgb(189,255,255)
  static const Color nuclearShellModelFill = Color(0xFFBDFFFF);

  static const String energyAxisLabel = '能量';

  static const String magicNumbersLabel = '幻数';

  /// 图例标题。[已确认] `mostLikelyDecayType`
  static const String legendTitle = mostLikelyDecayType;

  /// 手风琴底。[已确认] `chartAccordionBoxBackgroundColorProperty` WHITE
  static const Color chartAccordionFill = Color(0xFFFFFFFF);

  /// 手风琴内容间距。[已确认] `contentVBox.spacing = 10` / `chartsHBox.spacing = 10`
  static const double accordionContentSpacing = 10;

  /// 图例色块。[已确认] `LEGEND_KEY_BOX_SIZE = 14`；Grid `xSpacing 80` `ySpacing 5`
  static const double legendKeyBoxSize = 14;
  static const double legendItemSpacing = 5;
  static const double legendGridXSpacing = 80;
  static const double legendGridYSpacing = 5;

  /// Dialog 边距。[已确认] `INFO_DIALOG_OPTIONS.topMargin = 40`；`bottomMargin: 60`
  static const double fullChartDialogTopMargin = 40;
  static const double fullChartDialogBottomMargin = 60;
  static const double fullChartDialogContentSpacing = 10;

  /// Full Chart 按钮 / Dialog。[已确认] `FullChartTextButton` + strings
  static const String fullChartButtonLabel = '完整图表';
  static const String fullChartDialogTitle = '完整核素图';
  static const String fullChartInfoText =
      '完整、可交互的核素及衰变图表由卡尔加里大学 Energy Education Project 提供，见 https://energyeducation.ca/simulations/nuclear/nuclidechart.html。';
  static const String fullChartAsset = 'assets/images/full_nuclide_chart.png';
  static const String fullChartExternalUrl =
      'https://energyeducation.ca/simulations/nuclear/nuclidechart.html';

  /// 图最大宽。[已确认] `fullChartImage.setMaxWidth(481.5)` empirically
  static const double fullChartImageMaxWidth = 481.5;

  /// 图描边外扩。[已确认] `bounds.dilated(5)` + black stroke
  static const double fullChartImageBorderPad = 5;

  /// 源 PNG 像素。[已确认] IHDR 1948×1367
  static const double fullChartSourceWidth = 1948;
  static const double fullChartSourceHeight = 1367;

  /// Dialog 标题字号。[已确认] `BANConstants.TITLE_FONT` PhetFont(32)
  static const double fullChartTitleFontSize = 32;

  /// 说明文字。[已确认] `INFO_DIALOG_TEXT_OPTIONS` font 19, maxWidth 600
  static const double fullChartInfoFontSize = 19;
  static const double fullChartInfoMaxWidth = 600;

  /// 按钮白底黑边。[已确认] `fullChartButtonColorProperty` WHITE
  static const Color fullChartButtonFill = Color(0xFFFFFFFF);

  /// 格子描边模型宽度。[已确认] NUCLIDE_CHART_CELL_LINE_WIDTH = 0.05
  static const double cellLineWidthModel = 0.05;

  /// [已确认] nuclideChartBorderColorProperty rgb(143,143,143)
  static const Color cellBorder = Color(0xFF8F8F8F);

  /// [已确认] nuclideChartBorderMagicNumberColorProperty rgb(251,255,36)
  static const Color magicNumberBorder = Color(0xFFFBFF24);

  /// Magic numbers = n0 容量、n0+n1 容量。[已确认] MAGIC_NUMBERS = [2, 8]
  static const List<int> magicNumbers = [2, 8];

  /// [已确认] stableColorProperty rgb(27,20,100)
  static const Color stable = Color(0xFF1B1464);

  /// [已确认] unknownColorProperty = white
  static const Color unknown = Color(0xFFFFFFFF);

  /// [已确认] alphaColorProperty rgb(40,215,86)
  static const Color alpha = Color(0xFF28D756);

  /// [已确认] betaMinusColorProperty rgb(148,245,245)
  static const Color betaMinus = Color(0xFF94F5F5);

  /// [已确认] betaPlusColorProperty rgb(133,202,255)
  static const Color betaPlus = Color(0xFF85CAFF);

  /// [已确认] protonEmissionColorProperty rgb(247,2,93)
  static const Color protonEmission = Color(0xFFF7025D);

  /// [已确认] neutronEmissionColorProperty rgb(255,31,255)
  static const Color neutronEmission = Color(0xFFFF1FFF);

  static const Color proton = Color(BanConstants.protonColorValue);
  static const Color neutron = Color(BanConstants.neutronColorValue);

  /// mini-atom 整节点缩放。[已确认] ChartIntroScreenView particleAtomNode.scale(0.75)
  static const double miniAtomScale = 0.75;

  /// Partial 格标签字号。[已确认] NuclideChartAndNumberLines cellTextFontSize: 11
  static const double cellLabelFontSize = 11;

  /// Zoom-in 格标签字号。[已确认] ZoomInNuclideChartNode cellTextFontSize: 18
  static const double zoomCellLabelFontSize = 18;

  /// Focused 格标签字号。[已确认] FocusedNuclideChartNode cellTextFontSize: 6
  static const double focusedCellLabelFontSize = 6;

  /// [已确认] axis.protonNumber / axis.neutronNumber 英文字面
  static const String protonAxisLabel = '质子数';
  static const String neutronAxisLabel = '中子数';

  // —— Chart Intro 周期表（shred PeriodicTableCell / PeriodicTableNode）——

  /// 未缩放正方形边长。[已确认] `PeriodicTableCell` `length` 默认 25
  static const double periodicTableCellSize = 25;

  /// 格与格无额外 gap。[已确认] `translation = (col*25, row*25)`
  static const double periodicTableCellGap = 0;

  /// 符号字号。[已确认] `PhetFont(14 * (length/25))` → 14
  static const double periodicTableSymbolFontSize = 14;

  /// 符号最大宽。[已确认] `maxWidth = length - 5`
  static const double periodicTableSymbolMaxWidth = 20;

  /// 默认描边。[已确认] `stroke: 'black'`, `lineWidth: 1`
  static const Color periodicTableCellStroke = Color(0xFF000000);
  static const double periodicTableCellStrokeWidth = 1;

  /// Chart Intro 全表 disabled 填色。[已确认] `disabledPeriodicTableCellColorProperty` WHITE
  /// shred 默认是 `#EEEEEE`；本屏覆盖为白。
  static const Color periodicTableDisabledFill = Color(0xFFFFFFFF);

  /// 当前元素填/描边。[已确认] `selectedPeriodicTableCellFillAndStrokeColorProperty` BLACK
  static const Color periodicTableHighlightFill = Color(0xFF000000);
  static const Color periodicTableHighlightStroke = Color(0xFF000000);

  /// 高亮描边宽。[已确认] Chart Intro `strokeHighlightWidth: 1`
  /// （shred cell 默认是 2，本屏覆盖为 1）
  static const double periodicTableHighlightStrokeWidth = 1;

  /// 高亮标签。[已确认] `selectedPeriodicTableCellLabelTextColorProperty` WHITE
  static const Color periodicTableHighlightLabel = Color(0xFFFFFFFF);

  /// 未高亮标签。[已确认] `setHighlighted(false)` → `fill: 'black'`
  static const Color periodicTableLabel = Color(0xFF000000);

  /// 整表缩放。[已确认] `PeriodicTableAndIsotopeSymbol` `periodicTable.scale(0.75)`
  static const double periodicTableScale = 0.75;

  /// SymbolNode 未缩放盒。[已确认] `SYMBOL_BOX_WIDTH/HEIGHT = 275 / 325`
  static const double isotopeSymbolBoxWidth = 275;
  static const double isotopeSymbolBoxHeight = 325;

  /// [已确认] `SymbolNode` options `scale: 0.15`
  static const double isotopeSymbolScale = 0.15;

  /// [已确认] `PhetFont(150)` 符号 / `PhetFont(70)` 数字 / `NUMBER_INSET = 20`
  static const double isotopeSymbolFontSize = 150;
  static const double isotopeNumberFontSize = 70;
  static const double isotopeNumberInset = 20;

  /// 符号盒描边。[已确认] `stroke: 'black'`, `lineWidth: 2`, `fill: 'white'`
  static const Color isotopeSymbolBoxFill = Color(0xFFFFFFFF);
  static const Color isotopeSymbolBoxStroke = Color(0xFF000000);
  static const double isotopeSymbolBoxStrokeWidth = 2;

  /// 左下 Z 数字色。[已确认] `ShredColors.positiveColorProperty` `#D14600`
  static const Color isotopeProtonNumber = Color(BanConstants.protonColorValue);

  /// 面板。[已确认] `BANConstants.PANEL_OPTIONS` + `BANColors`
  static const Color panelBackground = Color(BanConstants.panelBackgroundValue);
  static const Color panelStroke = Color(0xFF808080); // Color.GRAY
  static const double panelCornerRadius = 6;
  static const double panelXMargin = 10;

  /// sun `Panel` 默认 yMargin；BAN 只覆盖了 xMargin。[已确认] sun `yMargin: 5`
  static const double panelYMargin = 5;

  /// 原版父矩形经验尺寸。[已确认] `Rectangle(0,0,150,100)`
  /// 不是格子逻辑尺寸，也不裁切子节点。[待确认] 与截图像素对齐
  static const double periodicTableEmpiricalWidth = 150;
  static const double periodicTableEmpiricalHeight = 100;

  /// 符号水平对准第 8 列中心。[已确认] `centerX = (7.5/18)*table.width`
  static const double isotopeSymbolCenterColumn = 7.5;

  /// 表上移，让符号落入上方空洞。[已确认] `top = symbol.bottom - height/7*2.5`
  static const double periodicTableSymbolOverlapRows = 2.5;

  static Color colorForDecay(NucleusDecayType? type, {required bool isStable}) {
    if (isStable) return stable;
    if (type == null) return unknown;
    switch (type) {
      case NucleusDecayType.alphaDecay:
        return alpha;
      case NucleusDecayType.betaMinusDecay:
        return betaMinus;
      case NucleusDecayType.betaPlusDecay:
        return betaPlus;
      case NucleusDecayType.protonEmission:
        return protonEmission;
      case NucleusDecayType.neutronEmission:
        return neutronEmission;
    }
  }

  /// 标签明暗。[已确认] NuclideChartNode.getCellLabelFill
  static Color labelFillFor({
    required bool isStable,
    required NucleusDecayType? decayType,
  }) {
    if (decayType == NucleusDecayType.alphaDecay ||
        decayType == NucleusDecayType.betaMinusDecay ||
        (decayType == null && !isStable)) {
      return const Color(0xFF000000);
    }
    return const Color(0xFFFFFFFF);
  }
}
