/// Build a Nucleus 常量。
///
/// 每个常量标注原项目出处（js/common/BANConstants.ts 等），
/// 数值与原项目保持一致。
library;

import 'dart:ui' show Offset, Size;

class BanConstants {
  const BanConstants._();

  /// Decay 屏质子数上限。[已确认] BANConstants.DECAY_MAX_NUMBER_OF_PROTONS
  static const int decayMaxProtons = 94;

  /// Decay 屏中子数上限。[已确认] BANConstants.DECAY_MAX_NUMBER_OF_NEUTRONS
  static const int decayMaxNeutrons = 146;

  /// Chart Intro 屏质子数上限（Ne-22）。
  /// [已确认] BANConstants.CHART_MAX_NUMBER_OF_PROTONS = 10
  static const int chartMaxProtons = 10;

  /// Chart Intro 屏中子数上限。
  /// [已确认] BANConstants.CHART_MAX_NUMBER_OF_NEUTRONS = 12
  static const int chartMaxNeutrons = 12;

  /// Zoom-in / Focused 高亮窗边长（格子数）。
  /// [已确认] BANConstants.ZOOM_IN_CHART_SQUARE_LENGTH = 5
  static const int zoomInChartSquareLength = 5;

  /// 核素图模型原点。[已确认] BANConstants.CHART_MIN = 0
  static const int chartMin = 0;

  /// 核子捕获半径（CSS px）：松手位置距核中心小于该值则核子入核。
  /// [已确认] DecayScreenView.NUCLEON_CAPTURE_RADIUS = 100
  static const double nucleonCaptureRadius = 100.0;

  /// 「不存在核素」展示时长（秒），随后自动回退到上一个存在的核素。
  /// [已确认] BANConstants.TIME_TO_SHOW_DOES_NOT_EXIST = 1
  static const double timeToShowDoesNotExist = 1.0;

  /// 稳定核素写入 `halfLifeNumber` 的值：10^END_EXPONENT 秒。
  /// 这是 **DecayModel 为数轴准备的显示哨兵**，不是核素表里的物理半衰期。
  /// [已确认] DecayModel: `Math.pow(10, HALF_LIFE_NUMBER_LINE_END_EXPONENT)`
  static const double stableHalfLifeDisplay = 1e24;

  /// 半衰期未知时的哨兵值。[已确认] AtomInfoUtils.getNuclideHalfLife 返回 -1
  /// （表内有条目但值为 null）。不是「0 秒」。
  static const double unknownHalfLife = -1.0;

  /// 核素不存在时半衰期读数。[已确认] DecayModel.halfLifeNumberProperty 返回 0
  /// 数轴上箭头藏起，并把指针映射到指数 0（见 HalfLifeNumberLine）。
  static const double nonexistentHalfLife = 0.0;

  /// 半衰期数轴模型范围左端指数（秒的 log10）。
  /// [已确认] BANConstants.HALF_LIFE_NUMBER_LINE_START_EXPONENT = -24
  static const int halfLifeNumberLineStartExponent = -24;

  /// 半衰期数轴模型范围右端指数。
  /// [已确认] BANConstants.HALF_LIFE_NUMBER_LINE_END_EXPONENT = 24
  /// 注释：Some half-life's are greater than 10^24 → 指针钉在右端，读数仍用真值。
  static const int halfLifeNumberLineEndExponent = 24;

  /// 刻度间距（指数）。[已确认] HalfLifeNumberLineNode.tickXSpacing = 3
  static const int halfLifeNumberLineTickSpacing = 3;

  /// 核子半径（屏坐标 px，模型与视图同尺度）。
  /// [已确认] ShredConstants.NUCLEON_RADIUS = 10，BANConstants.PARTICLE_RADIUS 直接引用它
  static const double nucleonRadius = 10.0;

  /// 质子基色。[已确认] shred Particle.PARTICLE_COLORS.proton
  static const int protonColorValue = 0xFFD14600;

  /// 中子基色：灰加深 10%（128×0.9≈115）。
  /// [已确认] PARTICLE_COLORS.neutron = Color.GRAY.darkerColor(0.1)
  static const int neutronColorValue = 0xFF737373;

  /// 衰变发射 / 飞回生成器的速度（px/s）。
  /// [已确认] BANConstants.PARTICLE_ANIMATION_SPEED = 300
  static const double particleAnimationSpeed = 300.0;

  /// 箭头飞入的固定时长（秒）：速度 = 距离 / 0.6。
  /// [已确认] BANParticle.setAnimationDestination 的 ANIMATION_TIME = 0.6
  /// （createParticleFromStack 传 consistentTime: true）
  static const double flyInAnimationTime = 0.6;

  /// 卡位归位速度（px/s）。[已确认] ShredConstants.DEFAULT_PARTICLE_SPEED = 200
  /// （BANParticle 构造不覆盖该默认值）
  static const double repositionSpeed = 200.0;

  /// β 衰变核子换色动画时长（秒，线性）。
  /// [已确认] ParticleAtom.changeNucleonType：Animation duration 0.5 + Easing.LINEAR
  static const double betaColorAnimationTime = 0.5;

  /// info 按钮相对数轴左端的缩进。[已确认] BANConstants.INFO_BUTTON_INDENT_DISTANCE
  static const double infoButtonIndentDistance = 124;

  /// info 按钮最大高度。[已确认] BANConstants.INFO_BUTTON_MAX_HEIGHT
  static const double infoButtonMaxHeight = 30;

  /// sun Dialog CloseButton 叉长。[已确认] `Dialog.ts` `closeButtonLength: 18.2`
  static const double closeIconSize = 18.2;

  /// 读数条在 info 按钮右侧的间隙。
  /// [已确认] halfLifeDisplayNode.left = indent + maxHeight + 10
  static const double infoButtonReadoutGap = 10;

  static double get halfLifeReadoutLeftInset =>
      infoButtonIndentDistance + infoButtonMaxHeight + infoButtonReadoutGap;

  /// [已确认] BANColors.infoButtonColorProperty default rgb(255,153,255)
  static const int infoButtonColorValue = 0xFFFF99FF;

  /// [已确认] BANColors.infoDialogBackgroundColorProperty default rgb(255,254,244)
  static const int infoDialogBackgroundValue = 0xFFFFFEF4;

  /// [已确认] BANColors.legendArrowColorProperty default rgb(4,4,255)
  static const int legendArrowColorValue = 0xFF0404FF;

  /// 电子基色。[已确认] shred `PARTICLE_COLORS.electron = Color.BLUE`
  /// （scenery/CSS named `blue` = #0000FF）；BANColors.electronColorProperty 默认引用它。
  static const int electronColorValue = 0xFF0000FF;

  /// 电子云半径压缩后映射到视图的倍率。
  /// [已确认] BANScreenView：`updateCloudSize(protonNumber, 0.27, 10, 20)` 的 factor
  static const double electronCloudSizeFactor = 0.27;

  /// [已确认] 同上调用的 minChangedRadius / maxChangedRadius
  static const double electronCloudMinChangedRadius = 10;
  static const double electronCloudMaxChangedRadius = 20;

  /// 原版 ScreenView 布局宽。atomCenter.x = width/3。
  /// [已确认] `BANConstants.LAYOUT_BOUNDS = ScreenView.DEFAULT_LAYOUT_BOUNDS`
  /// （joist `Bounds2(0,0,1024,618)`）与 `SCREEN_VIEW_ATOM_CENTER_X`
  static const double screenViewLayoutWidth = 1024;

  static double get screenViewAtomCenterX =>
      atomCenterXForLayout(screenViewLayoutWidth);

  /// 原版核中心 X。[已确认] `SCREEN_VIEW_ATOM_CENTER_X = LAYOUT_BOUNDS.width / 3`
  /// 用当前 play / layout 宽，不要写死 341.3。
  static double atomCenterXForLayout(double layoutWidth) => layoutWidth / 3;

  /// [已确认] `BANConstants.SCREEN_VIEW_X_MARGIN`
  static const double screenViewXMargin = 15;

  /// [已确认] `BANConstants.SCREEN_VIEW_Y_MARGIN`
  /// 生成器：`nucleonCreatorsNode.bottom = layoutBounds.maxY - SCREEN_VIEW_Y_MARGIN`
  static const double screenViewYMargin = 15;

  /// [已确认] `NucleonCreatorsNode` HBox `spacing`
  static const double nucleonCreatorsHBoxSpacing = 5;

  /// [已确认] `CREATOR_NODE_VBOX_OPTIONS.layoutOptions.minContentWidth` / `MAX_TEXT_WIDTH`
  static const double nucleonCreatorsMinContentWidth = 150;

  /// [已确认] `ARROW_BUTTON_VBOX_SPACING`
  static const double nucleonArrowVBoxSpacing = 7;

  /// [已确认] `ARROW_BUTTON_OPTIONS.arrowWidth/arrowHeight`
  static const double nucleonArrowGlyphSize = 14;

  /// [已确认] `DoubleArrowButton` 默认 `xMargin: 7`，两枚 14 箭头并排。
  static const double nucleonDoubleArrowButtonWidth =
      nucleonArrowGlyphSize * 2 + 7 * 2;

  /// [已确认] 单箭头：glyph 14 + 两侧约 7。
  static const double nucleonArrowButtonWidth = nucleonArrowGlyphSize + 7 * 2;

  /// [已确认] `DoubleArrowButton` `yMargin: 5` + glyph 14
  static const double nucleonArrowButtonHeight = nucleonArrowGlyphSize + 5 * 2;

  /// [已确认] `DecayScreenView`: `halfLifeInformationNode.left = minX + X_MARGIN + 30`
  static const double halfLifeInformationExtraLeft = 30;

  /// [已确认] `HalfLifeInformationNode` `numberLineWidth: 550`
  /// 只用于冻结块中心公式；Flutter 数轴绘制仍用容器宽，不在此改宽度。
  static const double halfLifeNumberLineWidth = 550;

  /// 半衰期信息块中心 X（layout / play 空间）。
  /// [已确认] `halfLifeInformationNodeCenterX = node.centerX` 在创建时冻结，
  /// 因箭头移动会改 bounds。info 按钮在块内，不移动该中心。
  /// 不等于 `atomCenterX`（width/3），也不等于读数文字盒中心。
  /// PhET 的 LAYOUT_BOUNDS 宽固定，窗口缩放整体变换；Flutter play 宽随视口，
  /// 按 `layoutWidth / LAYOUT_BOUNDS.width` 比例映射，不写死 320。
  static double halfLifeInformationCenterXForLayout(double layoutWidth) {
    final designCenter = screenViewXMargin +
        halfLifeInformationExtraLeft +
        halfLifeNumberLineWidth / 2;
    return designCenter * (layoutWidth / screenViewLayoutWidth);
  }

  /// 中心格局部 X。中心格水平居中于 play。
  static double halfLifeInformationCenterXInColumn({
    required double layoutWidth,
    required double columnWidth,
  }) {
    final columnLeft = (layoutWidth - columnWidth) / 2;
    return halfLifeInformationCenterXForLayout(layoutWidth) - columnLeft;
  }

  /// 原版核中心 Y 比例。[已确认] `SCREEN_VIEW_ATOM_CENTER_Y = height * 0.55`
  /// Flutter 画布矮于 play（上有半衰期），Y 仍用 **画布高** × 0.55。
  static const double atomCenterYFactor = 0.55;

  /// 把 layout 坐标换成 NineGrid 中心格局部 X。
  /// 中心格水平居中：`canvasLeft = (layoutW - canvasW) / 2`。
  static double atomCenterXForCanvas({
    required double layoutWidth,
    required double canvasWidth,
  }) {
    final canvasLeft = (layoutWidth - canvasWidth) / 2;
    return atomCenterXForLayout(layoutWidth) - canvasLeft;
  }

  /// 画布局部核原点。Y 仍为画布高 × 0.55。
  static Offset atomOriginInCanvas({
    required double layoutWidth,
    required Size canvasSize,
  }) =>
      Offset(
        atomCenterXForCanvas(
          layoutWidth: layoutWidth,
          canvasWidth: canvasSize.width,
        ),
        canvasSize.height * atomCenterYFactor,
      );

  /// 屏 / play 底。[已确认] BANColors.screenBackgroundColorProperty = Color.WHITE
  /// 只给 BAN Decay 本地 ColoredBox / Scaffold，不改 Theme。
  static const int screenBackgroundValue = 0xFFFFFFFF;

  /// 衰变按钮底色。[已确认] BANColors.decayButtonColorProperty rgb(251,178,64)
  static const int decayButtonColorValue = 0xFFFBB240;

  /// 面板背景。[已确认] BANColors.panelBackgroundColorProperty rgb(241,250,254)
  static const int panelBackgroundValue = 0xFFF1FAFE;

  /// Available Decays 面板填充。[已确认] availableDecaysPanelBackground rgb(242,242,242)
  static const int availableDecaysPanelBackgroundValue = 0xFFF2F2F2;

  /// 面板描边。[已确认] BANColors.panelStrokeColorProperty = Color.GRAY
  static const int panelStrokeValue = 0xFF808080;

  /// [已确认] BANConstants.PANEL_CORNER_RADIUS
  static const double panelCornerRadius = 6;

  /// [已确认] AvailableDecaysPanel SPACING
  static const double availableDecaysSpacing = 10;

  /// [已确认] AvailableDecaysPanel BUTTON_HEIGHT
  static const double availableDecaysButtonHeight = 35;

  /// [已确认] BUTTON_CONTENT_WIDTH；边格装不下，只作上限参考。
  static const double availableDecaysButtonContentWidth = 145;

  /// 矮视口按钮高下限，保持可点、符号可辨。
  static const double availableDecaysButtonMinHeight = 20;
}
