import 'dart:math' as math;
import 'dart:ui';

import 'high_intensity_layout_spec.dart';
import 'qwi_layout_primitives.dart';

/// Single Particles layout constants from PhET `SingleParticlesScreenView`.
///
/// Wave / detector / graph formulas match HI (source-proven identical).
/// Source panel top differs: `Y_MARGIN + 20` (not `SOURCE_CONTROL_PANEL_TOP`).
abstract final class SingleParticlesLayoutConstants {
  static const double designWidth = HighIntensityLayoutConstants.designWidth;
  static const double designHeight = HighIntensityLayoutConstants.designHeight;

  static const double waveRegionWidth = HighIntensityLayoutConstants.waveRegionWidth;
  static const double waveRegionHeight = HighIntensityLayoutConstants.waveRegionHeight;
  static const double detectorScreenWidth = HighIntensityLayoutConstants.detectorScreenWidth;
  static const double detectorOverlapFraction = HighIntensityLayoutConstants.detectorOverlapFraction;
  static const double detectorVisibleFraction = HighIntensityLayoutConstants.detectorVisibleFraction;
  static final double detectorSkew = HighIntensityLayoutConstants.detectorSkew;

  static const double contentVerticalOffset = HighIntensityLayoutConstants.contentVerticalOffset;
  static const double topRowCenterY = HighIntensityLayoutConstants.sourceBeamThumbnailCenterY;
  static const double thumbnailGap = HighIntensityLayoutConstants.thumbnailGap;
  static const double waveRegionYOffset = HighIntensityLayoutConstants.waveRegionYOffset;
  static const double waveRegionLeftGap = HighIntensityLayoutConstants.waveRegionLeftGap;
  static const double waveRegionRightGap = HighIntensityLayoutConstants.waveRegionRightGap;

  /// SP-only: `sourceControlPanel.top = Y_MARGIN + 20`.
  static const double sourceControlPanelTopExtra = 20;
  static const double sceneButtonGroupCenterY = HighIntensityLayoutConstants.sceneButtonGroupCenterY;
  static const double sceneRadiosGapBelowSource = HighIntensityLayoutConstants.sceneRadiosGapBelowSource;

  static const double rightPanelWidth = HighIntensityLayoutConstants.rightPanelWidth;
  static const double graphLeftGap = HighIntensityLayoutConstants.graphLeftGap;
  static const double leftColumnWidthEstimate = HighIntensityLayoutConstants.leftColumnWidthEstimate;
  static const double horizontalMargin = HighIntensityLayoutConstants.horizontalMargin;
  static const double verticalMargin = HighIntensityLayoutConstants.verticalMargin;

  static const double resetRadius = HighIntensityLayoutConstants.resetRadius;
  static const double graphWidthEstimate = HighIntensityLayoutConstants.graphWidthEstimate;
  static const double sourcePanelHeightEstimate = 110; // Auto-fire + wavelength
  static const double sceneRadiosHeightEstimate =
      HighIntensityLayoutConstants.sceneRadiosHeightEstimate; // 2×2 like HI
  static const double rightColumnHeightEstimate = HighIntensityLayoutConstants.designHeight - 30;
  static const double toolsPanelHeightEstimate = HighIntensityLayoutConstants.toolsPanelHeightEstimate;
  static const double screenControlsPanelHeightEstimate =
      HighIntensityLayoutConstants.screenControlsPanelHeightEstimate;
  static const double waveDisplayPanelHeightEstimate =
      HighIntensityLayoutConstants.waveDisplayPanelHeightEstimate;
  static const double rightPanelStackGap = HighIntensityLayoutConstants.rightPanelStackGap;
  static const double waveDisplayBottomGap = HighIntensityLayoutConstants.waveDisplayBottomGap;
  static const double slitRowHeightEstimate = HighIntensityLayoutConstants.slitRowHeightEstimate;
  static const double slitRowWidthEstimate = HighIntensityLayoutConstants.slitRowWidthEstimate;
  static const double clearButtonWidth = HighIntensityLayoutConstants.clearButtonWidth;
  static const double clearButtonHeight = HighIntensityLayoutConstants.clearButtonHeight;
  static const double snapshotDialogWidth = HighIntensityLayoutConstants.snapshotDialogWidth;
  static const double snapshotDialogHeight = HighIntensityLayoutConstants.snapshotDialogHeight;

  /// Probe panel extension below wave (Flutter port estimate).
  static const double probePanelExtraHeight = 80;
  static const double emitterOverlap = 12;
  /// Scaled down so gun + left radios coexist without clipping.
  static const double emitterScale = 0.88;
  static const double emitterHeight = 153 * emitterScale;
  static const double emitterWidth = 220 * emitterScale / 1.5; // ~aspect of gun SVG
  static const double emitterButtonRadius = 23 * emitterScale;
}

/// Single Particles layout geometry — pure data.
///
/// Spec: `requirements/req-quantum-wave-interference/SINGLE_PARTICLES_LAYOUT_SPEC.md`
class SingleParticlesLayoutSpec {
  SingleParticlesLayoutSpec._({
    required this.canvas,
    required this.leftColumn,
    required this.waveBand,
    required this.rightColumn,
    required this.bottomSlitRow,
    required this.bottomToolRow,
    required this.sourcePanel,
    required this.sceneRadios,
    required this.waveRegion,
    required this.detector,
    required this.graph,
    required this.probeLayer,
    required this.rightControls,
    required this.screenControlsPanel,
    required this.toolsPanel,
    required this.waveDisplayPanel,
    required this.emitter,
    required this.slitControls,
    required this.measuringTapeCheckbox,
    required this.clearButton,
    required this.reset,
    required this.snapshotDialog,
    required this.leftColumnWidth,
    required this.bottomToolsCenterY,
    required this.sourcePanelTop,
  });

  final Size canvas;
  final QwiRect leftColumn;
  final QwiRect waveBand;
  final QwiRect rightColumn;
  final QwiRect bottomSlitRow;
  final QwiRect bottomToolRow;

  final QwiRect sourcePanel;
  final QwiRect sceneRadios;
  final QwiRect waveRegion;
  final QwiRect detector;
  final QwiRect graph;
  final QwiRect probeLayer;
  final QwiRect rightControls;
  final QwiRect screenControlsPanel;
  final QwiRect toolsPanel;
  final QwiRect waveDisplayPanel;
  final QwiRect emitter;
  final QwiRect slitControls;
  final QwiRect measuringTapeCheckbox;
  final QwiRect clearButton;
  final QwiRect reset;
  final QwiRect snapshotDialog;

  final double leftColumnWidth;
  final double bottomToolsCenterY;
  final double sourcePanelTop;

  factory SingleParticlesLayoutSpec.resolve({
    double leftColumnWidth = SingleParticlesLayoutConstants.leftColumnWidthEstimate,
    double resetRadius = SingleParticlesLayoutConstants.resetRadius,
  }) {
    const canvas = Size(
      SingleParticlesLayoutConstants.designWidth,
      SingleParticlesLayoutConstants.designHeight,
    );
    const xMargin = SingleParticlesLayoutConstants.horizontalMargin;
    const yMargin = SingleParticlesLayoutConstants.verticalMargin;

    final leftColumnCenterX = xMargin + leftColumnWidth / 2;

    // Right rail first; wave fills remaining mid band (same as HI).
    final rightLeft =
        canvas.width - xMargin - SingleParticlesLayoutConstants.rightPanelWidth;
    final waveLeft = xMargin +
        leftColumnWidth +
        SingleParticlesLayoutConstants.waveRegionLeftGap;
    final maxWaveRight =
        rightLeft - SingleParticlesLayoutConstants.waveRegionRightGap;
    final waveWidth = math
        .min(
          SingleParticlesLayoutConstants.waveRegionWidth,
          maxWaveRight - waveLeft,
        )
        .clamp(260.0, SingleParticlesLayoutConstants.waveRegionWidth);

    // Wave — identical formula to HI (SingleParticlesScreenView locals).
    final baseWaveTop = yMargin +
        SingleParticlesLayoutConstants.topRowCenterY +
        SingleParticlesLayoutConstants.thumbnailGap;
    final waveTop = baseWaveTop + SingleParticlesLayoutConstants.waveRegionYOffset;
    final wave = QwiRect(
      waveLeft,
      waveTop,
      waveWidth,
      SingleParticlesLayoutConstants.waveRegionHeight,
    );
    final waveRight = wave.right;

    final detLeft = waveRight -
        SingleParticlesLayoutConstants.detectorScreenWidth *
            SingleParticlesLayoutConstants.detectorOverlapFraction;
    final detTop = waveTop -
        SingleParticlesLayoutConstants.detectorSkew *
            SingleParticlesLayoutConstants.detectorVisibleFraction;
    final detector = QwiRect(
      detLeft,
      detTop,
      SingleParticlesLayoutConstants.detectorScreenWidth,
      SingleParticlesLayoutConstants.waveRegionHeight,
    );

    final graphLeft = waveRight + SingleParticlesLayoutConstants.graphLeftGap;
    final graphWidth = math
        .min(
          SingleParticlesLayoutConstants.graphWidthEstimate,
          rightLeft - graphLeft,
        )
        .clamp(0.0, SingleParticlesLayoutConstants.graphWidthEstimate);
    final graph = QwiRect(
      graphLeft,
      waveTop,
      graphWidth,
      SingleParticlesLayoutConstants.waveRegionHeight,
    );

    // SP source top = Y_MARGIN + 20 (≠ HI 178).
    final sourceTop = yMargin + SingleParticlesLayoutConstants.sourceControlPanelTopExtra;
    final sourcePanel = QwiRect(
      leftColumnCenterX - leftColumnWidth / 2,
      sourceTop,
      leftColumnWidth,
      SingleParticlesLayoutConstants.sourcePanelHeightEstimate,
    );
    // 2×2 particle radios in left-column bottom blank (same as HI).
    final radiosH = SingleParticlesLayoutConstants.sceneRadiosHeightEstimate;
    final radiosMinTop =
        sourcePanel.bottom + SingleParticlesLayoutConstants.sceneRadiosGapBelowSource;
    final radiosPreferredTop = canvas.height - yMargin - radiosH;
    final sceneRadios = QwiRect(
      leftColumnCenterX - leftColumnWidth / 2,
      math.max(radiosMinTop, radiosPreferredTop),
      leftColumnWidth,
      radiosH,
    );

    const panelGap = SingleParticlesLayoutConstants.rightPanelStackGap;

    final resetCenterY = canvas.height - yMargin - resetRadius;
    final reset = QwiRect(
      canvas.width - xMargin - resetRadius * 2,
      resetCenterY - resetRadius,
      resetRadius * 2,
      resetRadius * 2,
    );

    // Original HI/SP: Wave Display → Screen → Tools (top → bottom).
    final rightStackTop = yMargin;
    final rightStackBottom =
        reset.top - SingleParticlesLayoutConstants.waveDisplayBottomGap;
    final rightStackH = (rightStackBottom - rightStackTop).clamp(200.0, 500.0);
    final usableH = rightStackH - 2 * panelGap;
    final waveDisplayH = usableH * HighIntensityLayoutConstants.rightWaveDisplayShare;
    final screenH = usableH * HighIntensityLayoutConstants.rightScreenShare;
    final toolsH = usableH * HighIntensityLayoutConstants.rightToolsShare;
    final waveDisplayPanel = QwiRect(
      rightLeft,
      rightStackTop,
      SingleParticlesLayoutConstants.rightPanelWidth,
      waveDisplayH,
    );
    final screenControlsPanel = QwiRect(
      rightLeft,
      waveDisplayPanel.bottom + panelGap,
      SingleParticlesLayoutConstants.rightPanelWidth,
      screenH,
    );
    final toolsPanel = QwiRect(
      rightLeft,
      screenControlsPanel.bottom + panelGap,
      SingleParticlesLayoutConstants.rightPanelWidth,
      toolsH,
    );
    final rightControls = QwiRect(
      rightLeft,
      yMargin,
      SingleParticlesLayoutConstants.rightPanelWidth,
      rightStackBottom - yMargin,
    );

    final measuringTapeCheckbox = QwiRect(
      toolsPanel.left + 8,
      toolsPanel.top + 8,
      160,
      36,
    );
    final clearButton = QwiRect(
      reset.left - QwiSpacing.s4 - SingleParticlesLayoutConstants.clearButtonWidth,
      resetCenterY - SingleParticlesLayoutConstants.clearButtonHeight / 2,
      SingleParticlesLayoutConstants.clearButtonWidth,
      SingleParticlesLayoutConstants.clearButtonHeight,
    );

    // SP gun: right edge into wave; sit at wave midline above bottom radios.
    final leftColumnRight = xMargin + leftColumnWidth;
    final emitterRight =
        wave.left + SingleParticlesLayoutConstants.emitterOverlap;
    final naturalW = SingleParticlesLayoutConstants.emitterWidth;
    final naturalH = SingleParticlesLayoutConstants.emitterHeight;
    final emitterLeft = math.max(emitterRight - naturalW, leftColumnRight - 20);
    final emitterW = emitterRight - emitterLeft;
    final emitterH = naturalH * (emitterW / naturalW).clamp(0.35, 1.0);
    final emitterTopCentered = wave.top +
        (SingleParticlesLayoutConstants.waveRegionHeight - emitterH) * 0.45;
    final emitterTopMax = sceneRadios.top - 4 - emitterH;
    final emitterTop = math
        .min(emitterTopCentered, emitterTopMax)
        .clamp(sourcePanel.bottom + 4, emitterTopMax);
    final emitter = QwiRect(emitterLeft, emitterTop, emitterW, emitterH);

    final slitH = SingleParticlesLayoutConstants.slitRowHeightEstimate;
    final slitTop = wave.bottom + HighIntensityLayoutConstants.slitRowGapBelowWave;
    final slitMaxBottom = canvas.height - yMargin;
    final slitControls = QwiRect(
      wave.left,
      slitTop,
      wave.width,
      math.min(slitH, math.max(36.0, slitMaxBottom - slitTop)),
    );

    final probeLayer = QwiRect(
      wave.left,
      wave.top,
      wave.width,
      wave.height + SingleParticlesLayoutConstants.probePanelExtraHeight,
    );

    final snapshotDialog = QwiRect(
      (canvas.width - SingleParticlesLayoutConstants.snapshotDialogWidth) / 2,
      (canvas.height - SingleParticlesLayoutConstants.snapshotDialogHeight) / 2,
      SingleParticlesLayoutConstants.snapshotDialogWidth,
      SingleParticlesLayoutConstants.snapshotDialogHeight,
    );

    final leftColumn = QwiRect(xMargin, 0, leftColumnWidth, canvas.height);
    final waveBand = QwiRect(
      math.min(wave.left, detector.left),
      math.min(wave.top, detector.top),
      math.max(wave.right, detector.right) - math.min(wave.left, detector.left),
      math.max(wave.bottom, detector.bottom) - math.min(wave.top, detector.top),
    );
    final rightColumn = rightControls;
    final bottomSlitRow = QwiRect(wave.left, slitControls.top, wave.width, slitControls.height);
    final bottomToolRow = QwiRect(xMargin, reset.top, canvas.width - 2 * xMargin, reset.height);

    return SingleParticlesLayoutSpec._(
      canvas: canvas,
      leftColumn: leftColumn,
      waveBand: waveBand,
      rightColumn: rightColumn,
      bottomSlitRow: bottomSlitRow,
      bottomToolRow: bottomToolRow,
      sourcePanel: sourcePanel,
      sceneRadios: sceneRadios,
      waveRegion: wave,
      detector: detector,
      graph: graph,
      probeLayer: probeLayer,
      rightControls: rightControls,
      screenControlsPanel: screenControlsPanel,
      toolsPanel: toolsPanel,
      waveDisplayPanel: waveDisplayPanel,
      emitter: emitter,
      slitControls: slitControls,
      measuringTapeCheckbox: measuringTapeCheckbox,
      clearButton: clearButton,
      reset: reset,
      snapshotDialog: snapshotDialog,
      leftColumnWidth: leftColumnWidth,
      bottomToolsCenterY: resetCenterY,
      sourcePanelTop: sourceTop,
    );
  }
}
