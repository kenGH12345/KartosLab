import 'dart:math' as math;
import 'dart:ui';

import 'qwi_layout_primitives.dart';

/// High Intensity layout constants from PhET `HighIntensityScreenView` /
/// `QuantumWaveInterferenceConstants`.
abstract final class HighIntensityLayoutConstants {
  static const double designWidth = 768;
  static const double designHeight = 504;

  /// Display wave size — leave room for slit row below and right rail beside.
  static const double waveRegionWidth = 360;
  static const double waveRegionHeight = 330;
  static const double detectorScreenWidth = 66;
  static const double detectorOverlapFraction = 0.33;
  static const double detectorVisibleFraction = 0.67;
  static const double detectorAngleDegrees = 20;

  /// `66 * tan(20°)`.
  static final double detectorSkew =
      detectorScreenWidth * math.tan(detectorAngleDegrees * math.pi / 180);

  static const double contentVerticalOffset = 12;
  static const double sourceBeamThumbnailCenterY = 40 + contentVerticalOffset; // 52
  static const double thumbnailGap = 55;
  static const double waveRegionYOffset = -30;
  static const double waveRegionLeftGap = 12;
  /// Solid gap between wave and right control rail (no overlap).
  static const double waveRegionRightGap = 14;

  static const double sourceControlPanelTop = 178;
  /// PhET authored centerY; Flutter places radios under the source panel instead.
  static const double sceneButtonGroupCenterY = 470;
  static const double sceneRadiosGapBelowSource = 10;

  /// PhET `RIGHT_PANEL_WIDTH`.
  static const double rightPanelWidth = 180;
  static const double graphLeftGap = 2; // DETECTOR_PATTERN_GRAPH_LEFT_GAP

  static const double leftColumnWidthEstimate = 128;

  /// PhET `SCREEN_VIEW_X_MARGIN` / `SCREEN_VIEW_Y_MARGIN`.
  static const double horizontalMargin = 15;
  static const double verticalMargin = 15;

  static const double resetRadius = 20.5;
  static const double graphWidthEstimate = 90;
  static const double sceneRadiosHeightEstimate = 130;
  static const double sourcePanelHeightEstimate = 110;
  /// Original HI right rail (top → bottom): Wave Display → Screen → Tools.
  static const double rightWaveDisplayShare = 0.32;
  static const double rightScreenShare = 0.40;
  static const double rightToolsShare = 0.28;
  static const double waveDisplayPanelHeightEstimate = 150;
  static const double screenControlsPanelHeightEstimate = 160;
  static const double toolsPanelHeightEstimate = 120;
  /// Gap between stacked right panels.
  static const double rightPanelStackGap = 10;
  /// Gap between tools panel bottom and Reset row top.
  static const double waveDisplayBottomGap = 12;
  static const double emitterCenterY = 52;
  static const double emitterScale = 1.15;
  static const double emitterWidth = (88 + 16) * emitterScale;
  static const double emitterHeight = 40 * emitterScale;
  /// Gap between wave bottom and Configuration / Slit Separation row.
  static const double slitRowGapBelowWave = 8;
  static const double slitRowHeightEstimate = 56;
  static const double slitRowWidthEstimate = 360;
  static const double tapeCheckboxWidth = 140;
  static const double tapeCheckboxHeight = 36;
  static const double clearButtonWidth = 36;
  static const double clearButtonHeight = 28;
  static const double snapshotDialogWidth = 360;
  static const double snapshotDialogHeight = 220;
}

/// High Intensity layout geometry — pure data, no Widgets / Model.
///
/// Spec: `requirements/req-quantum-wave-interference/HIGH_INTENSITY_LAYOUT_SPEC.md`
class HighIntensityLayoutSpec {
  HighIntensityLayoutSpec._({
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
    required this.waveDisplayPanel,
    required this.screenControlsPanel,
    required this.toolsPanel,
    required this.emitter,
    required this.slitControls,
    required this.measuringTapeCheckbox,
    required this.clearButton,
    required this.reset,
    required this.snapshotDialog,
    required this.leftColumnWidth,
    required this.bottomToolsCenterY,
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
  final QwiRect waveDisplayPanel;
  final QwiRect screenControlsPanel;
  final QwiRect toolsPanel;
  final QwiRect emitter;
  final QwiRect slitControls;
  final QwiRect measuringTapeCheckbox;
  final QwiRect clearButton;
  final QwiRect reset;
  final QwiRect snapshotDialog;

  final double leftColumnWidth;
  final double bottomToolsCenterY;

  /// Resolve all HI module bounds in design coordinates.
  factory HighIntensityLayoutSpec.resolve({
    double leftColumnWidth = HighIntensityLayoutConstants.leftColumnWidthEstimate,
    double resetRadius = HighIntensityLayoutConstants.resetRadius,
  }) {
    const canvas = Size(
      HighIntensityLayoutConstants.designWidth,
      HighIntensityLayoutConstants.designHeight,
    );
    const xMargin = HighIntensityLayoutConstants.horizontalMargin;
    const yMargin = HighIntensityLayoutConstants.verticalMargin;

    final leftColumnCenterX = xMargin + leftColumnWidth / 2;

    // Right rail right-aligned; wave capped so a clear gap remains.
    final rightLeft =
        canvas.width - xMargin - HighIntensityLayoutConstants.rightPanelWidth;
    final waveLeft =
        xMargin + leftColumnWidth + HighIntensityLayoutConstants.waveRegionLeftGap;
    final maxWaveRight =
        rightLeft - HighIntensityLayoutConstants.waveRegionRightGap;
    final waveWidth = math
        .min(
          HighIntensityLayoutConstants.waveRegionWidth,
          maxWaveRight - waveLeft,
        )
        .clamp(260.0, HighIntensityLayoutConstants.waveRegionWidth);

    final baseWaveTop = yMargin +
        HighIntensityLayoutConstants.sourceBeamThumbnailCenterY +
        HighIntensityLayoutConstants.thumbnailGap;
    final waveTop = baseWaveTop + HighIntensityLayoutConstants.waveRegionYOffset;
    final wave = QwiRect(
      waveLeft,
      waveTop,
      waveWidth,
      HighIntensityLayoutConstants.waveRegionHeight,
    );
    final waveRight = wave.right;

    final detLeft = waveRight -
        HighIntensityLayoutConstants.detectorScreenWidth *
            HighIntensityLayoutConstants.detectorOverlapFraction;
    final detTop = waveTop -
        HighIntensityLayoutConstants.detectorSkew *
            HighIntensityLayoutConstants.detectorVisibleFraction;
    final detector = QwiRect(
      detLeft,
      detTop,
      HighIntensityLayoutConstants.detectorScreenWidth,
      HighIntensityLayoutConstants.waveRegionHeight,
    );

    final graphLeft = waveRight + HighIntensityLayoutConstants.graphLeftGap;
    final graphWidth = math
        .min(
          HighIntensityLayoutConstants.graphWidthEstimate,
          math.max(0.0, rightLeft - graphLeft),
        )
        .clamp(0.0, HighIntensityLayoutConstants.graphWidthEstimate);
    final graph = QwiRect(
      graphLeft,
      waveTop,
      graphWidth,
      HighIntensityLayoutConstants.waveRegionHeight,
    );

    final sourcePanel = QwiRect(
      leftColumnCenterX - leftColumnWidth / 2,
      HighIntensityLayoutConstants.sourceControlPanelTop,
      leftColumnWidth,
      HighIntensityLayoutConstants.sourcePanelHeightEstimate,
    );
    // 2×2 particle radios in left-column bottom blank (PhET SceneRadioButtonGroup).
    final radiosH = HighIntensityLayoutConstants.sceneRadiosHeightEstimate;
    final radiosMinTop =
        sourcePanel.bottom + HighIntensityLayoutConstants.sceneRadiosGapBelowSource;
    final radiosPreferredTop = canvas.height - yMargin - radiosH;
    final sceneRadios = QwiRect(
      leftColumnCenterX - leftColumnWidth / 2,
      math.max(radiosMinTop, radiosPreferredTop),
      leftColumnWidth,
      radiosH,
    );

    const panelGap = HighIntensityLayoutConstants.rightPanelStackGap;

    final resetCenterY = canvas.height - yMargin - resetRadius;
    final reset = QwiRect(
      canvas.width - xMargin - resetRadius * 2,
      resetCenterY - resetRadius,
      resetRadius * 2,
      resetRadius * 2,
    );

    // Original HI: Wave Display → Screen → Tools (top → bottom), then Reset.
    final rightStackTop = yMargin;
    final rightStackBottom =
        reset.top - HighIntensityLayoutConstants.waveDisplayBottomGap;
    final rightStackH = (rightStackBottom - rightStackTop).clamp(200.0, 500.0);
    final usableH = rightStackH - 2 * panelGap;
    final waveDisplayH = usableH * HighIntensityLayoutConstants.rightWaveDisplayShare;
    final screenH = usableH * HighIntensityLayoutConstants.rightScreenShare;
    final toolsH = usableH * HighIntensityLayoutConstants.rightToolsShare;

    final waveDisplayPanel = QwiRect(
      rightLeft,
      rightStackTop,
      HighIntensityLayoutConstants.rightPanelWidth,
      waveDisplayH,
    );
    final screenControlsPanel = QwiRect(
      rightLeft,
      waveDisplayPanel.bottom + panelGap,
      HighIntensityLayoutConstants.rightPanelWidth,
      screenH,
    );
    final toolsPanel = QwiRect(
      rightLeft,
      screenControlsPanel.bottom + panelGap,
      HighIntensityLayoutConstants.rightPanelWidth,
      toolsH,
    );

    final measuringTapeCheckbox = QwiRect(
      toolsPanel.left + 8,
      toolsPanel.top + 8,
      HighIntensityLayoutConstants.tapeCheckboxWidth,
      HighIntensityLayoutConstants.tapeCheckboxHeight,
    );

    final emitter = QwiRect(
      leftColumnCenterX - HighIntensityLayoutConstants.emitterWidth / 2,
      HighIntensityLayoutConstants.emitterCenterY - HighIntensityLayoutConstants.emitterHeight / 2,
      HighIntensityLayoutConstants.emitterWidth,
      HighIntensityLayoutConstants.emitterHeight,
    );

    final clearButton = QwiRect(
      reset.left - QwiSpacing.s4 - HighIntensityLayoutConstants.clearButtonWidth,
      resetCenterY - HighIntensityLayoutConstants.clearButtonHeight / 2,
      HighIntensityLayoutConstants.clearButtonWidth,
      HighIntensityLayoutConstants.clearButtonHeight,
    );

    // Configuration + Slit Separation sit flush under the wave (original).
    final slitH = HighIntensityLayoutConstants.slitRowHeightEstimate;
    final slitTop = wave.bottom + HighIntensityLayoutConstants.slitRowGapBelowWave;
    final slitMaxBottom = canvas.height - yMargin;
    final slitControls = QwiRect(
      wave.left,
      slitTop,
      wave.width,
      math.min(slitH, math.max(36.0, slitMaxBottom - slitTop)),
    );

    final snapshotDialog = QwiRect(
      (canvas.width - HighIntensityLayoutConstants.snapshotDialogWidth) / 2,
      (canvas.height - HighIntensityLayoutConstants.snapshotDialogHeight) / 2,
      HighIntensityLayoutConstants.snapshotDialogWidth,
      HighIntensityLayoutConstants.snapshotDialogHeight,
    );

    final leftColumn = QwiRect(xMargin, 0, leftColumnWidth, canvas.height);
    final waveBand = QwiRect(
      math.min(wave.left, detector.left),
      math.min(wave.top, detector.top),
      math.max(wave.right, detector.right) - math.min(wave.left, detector.left),
      math.max(wave.bottom, detector.bottom) - math.min(wave.top, detector.top),
    );
    final rightColumn = QwiRect(
      rightLeft,
      yMargin,
      HighIntensityLayoutConstants.rightPanelWidth,
      canvas.height - 2 * yMargin,
    );
    final bottomSlitRow = QwiRect(wave.left, slitControls.top, wave.width, slitControls.height);
    final bottomToolRow = QwiRect(
      xMargin,
      reset.top,
      canvas.width - 2 * xMargin,
      reset.height,
    );

    return HighIntensityLayoutSpec._(
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
      waveDisplayPanel: waveDisplayPanel,
      screenControlsPanel: screenControlsPanel,
      toolsPanel: toolsPanel,
      emitter: emitter,
      slitControls: slitControls,
      measuringTapeCheckbox: measuringTapeCheckbox,
      clearButton: clearButton,
      reset: reset,
      snapshotDialog: snapshotDialog,
      leftColumnWidth: leftColumnWidth,
      bottomToolsCenterY: resetCenterY,
    );
  }
}
