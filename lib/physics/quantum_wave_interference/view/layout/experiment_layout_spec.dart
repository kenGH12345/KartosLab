import 'dart:ui';

import 'qwi_layout_primitives.dart';

/// Experiment layout geometry resolved from LAYOUT_SPEC formulas.
///
/// Pure data — no Widgets, no Model state.
///
/// Anchors / relationships follow PhET `ExperimentScreenView`.
///
/// **Clear-columns fit (user choice 2026-09-28):** PhET ideal widths
/// (slit 204 + detector 376 + left ≥160) exceed the 768 canvas, so the
/// original formulas produce ~30px column overlap. This Spec keeps the same
/// anchors and +8 chains, but **uniformly scales** slit + detector (width AND
/// height, preserving PhET 204×155 / 376×155 aspect) so columns no longer
/// overlap (min gap [QwiSpacing.stack]).
class ExperimentLayoutSpec {
  ExperimentLayoutSpec._({
    required this.canvas,
    required this.overheadBand,
    required this.frontFacingRow,
    required this.belowRowControls,
    required this.bottomToolRow,
    required this.sourcePanel,
    required this.sceneRadios,
    required this.slitView,
    required this.slitPanel,
    required this.detector,
    required this.snapshotColumn,
    required this.screenControls,
    required this.graph,
    required this.rulerCheckbox,
    required this.timeControls,
    required this.eraser,
    required this.reset,
    required this.middleCenterX,
    required this.stackGap,
    required this.frontFacingScale,
  });

  /// Resolve all Experiment module bounds in design coordinates.
  factory ExperimentLayoutSpec.resolve({
    double leftColumnWidth = ExperimentLayoutConstants.sourcePanelMinWidth,
    double snapshotColumnWidth = ExperimentLayoutConstants.snapshotColumnWidth,
    double screenControlsHeight = ExperimentLayoutConstants.screenControlsHeightEstimate,
    double resetRadius = ExperimentLayoutConstants.resetRadius,
  }) {
    const canvas = Size(
      ExperimentLayoutConstants.designWidth,
      ExperimentLayoutConstants.designHeight,
    );
    const margin = QwiSpacing.margin;
    const stack = QwiSpacing.stack;
    const rowTop = ExperimentLayoutConstants.frontFacingRowTop;
    const rowH = ExperimentLayoutConstants.frontFacingRowHeight;
    const idealDetW = ExperimentLayoutConstants.detectorScreenWidth;
    const idealSlitW = ExperimentLayoutConstants.frontFacingSlitViewWidth;
    const midShift = ExperimentLayoutConstants.middleColumnLeftShift;
    final snapshotGap = QwiSpacing.snapshotGap;

    // --- Left column (content-driven; PhET emitter-linked left) ---
    final sourceLeft = margin + ExperimentLayoutConstants.baseEmitterLeft;
    final sourcePanel = QwiRect(
      sourceLeft,
      ExperimentLayoutConstants.sourceControlPanelTop,
      leftColumnWidth,
      ExperimentLayoutConstants.sourcePanelContentHeight,
    );

    const radiosW = ExperimentLayoutConstants.sceneRadiosWidth;
    const radiosH = ExperimentLayoutConstants.sceneRadiosHeight;
    // Sit in the blank under the source panel (not PhET bottom-anchored 470 —
    // that leaves a large empty band after front-facing row was raised).
    final sceneRadiosTop = sourcePanel.bottom + ExperimentLayoutConstants.sceneRadiosGapBelowSource;
    final sceneRadios = QwiRect(
      sourcePanel.centerX - radiosW / 2,
      sceneRadiosTop,
      radiosW,
      radiosH,
    );

    final leftColumnRight =
        sourcePanel.right > sceneRadios.right ? sourcePanel.right : sceneRadios.right;

    // --- Clear-columns fit: uniform scale slit+detector into remaining width ---
    // Keep PhET aspect (204×155 / 376×155). Width-only scale made boxes look too tall.
    // [leftCol][gap][slit][gap][det][snapGap][snap][margin]
    final rightBudget = canvas.width - margin;
    final availableForSlitDet =
        rightBudget - snapshotColumnWidth - snapshotGap - leftColumnRight - 2 * stack;
    final idealSum = idealSlitW + idealDetW;
    final frontFacingScale =
        availableForSlitDet < idealSum ? (availableForSlitDet / idealSum).clamp(0.5, 1.0) : 1.0;
    final detW = idealDetW * frontFacingScale;
    final slitW = idealSlitW * frontFacingScale;
    final rowHScaled = rowH * frontFacingScale;
    // Panel stays ~20px wider than slit (PhET 224 vs 204), but never wider than middle band.
    final slitPanelPrefW =
        (ExperimentLayoutConstants.slitControlPanelWidth * frontFacingScale).clamp(slitW, slitW + 20);

    // --- Right column: top-right anchor (scaled detector) ---
    final detectorLeft = rightBudget - snapshotColumnWidth - snapshotGap - detW;
    final detector = QwiRect(detectorLeft, rowTop, detW, rowHScaled);
    final snapshotColumn = QwiRect(
      detector.right + snapshotGap,
      rowTop,
      snapshotColumnWidth,
      rowHScaled,
    );

    // --- Middle column: centered in the clear band between L and R ---
    final middleBandLeft = leftColumnRight + stack;
    final middleBandRight = detector.left - stack;
    final middleBandW = (middleBandRight - middleBandLeft).clamp(80.0, canvas.width);
    final placedSlitW = slitW <= middleBandW ? slitW : middleBandW;
    // Prefer PhET middleCenterX formula; then clamp slit fully inside the band.
    var middleCenterX = (leftColumnRight + detector.left) / 2 - midShift;
    var slitLeft = middleCenterX - placedSlitW / 2;
    if (slitLeft < middleBandLeft) {
      slitLeft = middleBandLeft;
      middleCenterX = slitLeft + placedSlitW / 2;
    }
    if (slitLeft + placedSlitW > middleBandRight) {
      slitLeft = middleBandRight - placedSlitW;
      middleCenterX = slitLeft + placedSlitW / 2;
    }
    final slitView = QwiRect(slitLeft, rowTop, placedSlitW, rowHScaled);
    final controlsTop = rowTop + rowHScaled + ExperimentLayoutConstants.frontFacingControlsGap;

    // Bottom tools shared centerY (Reset bottom-right).
    final resetCenterY = canvas.height - margin - resetRadius;
    final reset = QwiRect(
      canvas.width - margin - resetRadius * 2,
      resetCenterY - resetRadius,
      resetRadius * 2,
      resetRadius * 2,
    );

    // Slit panel: slight extra gap under front-facing slit so it does not kiss the plate.
    final slitPanelMaxBottom = resetCenterY +
        ExperimentLayoutConstants.rulerCheckboxHalfH * 2 +
        QwiSpacing.s2 / 2 +
        ExperimentLayoutConstants.slitControlPanelBottomMargin;
    final slitPanelTop =
        controlsTop + ExperimentLayoutConstants.slitPanelExtraTopGap;
    final slitPanelH = (slitPanelMaxBottom - slitPanelTop).clamp(100.0, 160.0);
    var slitPanelW = slitPanelPrefW <= middleBandW ? slitPanelPrefW : middleBandW;
    var slitPanelLeft = middleCenterX - slitPanelW / 2;
    if (slitPanelLeft < middleBandLeft) slitPanelLeft = middleBandLeft;
    if (slitPanelLeft + slitPanelW > middleBandRight) {
      slitPanelLeft = middleBandRight - slitPanelW;
    }
    final slitPanel = QwiRect(slitPanelLeft, slitPanelTop, slitPanelW, slitPanelH);

    // ScreenControls: content-sized, centerX = detector.centerX, clamped to detector.
    final screenControlsW = ExperimentLayoutConstants.screenControlsContentWidth
        .clamp(120.0, detW)
        .toDouble();
    final screenControls = QwiRect(
      detector.centerX - screenControlsW / 2,
      controlsTop,
      screenControlsW,
      screenControlsHeight,
    );

    // Graph uses PhET expanded content height (title + chart); Ruler follows under it.
    // Composer places Ruler in the same Column so collapse/expand keeps it below the box.
    const rulerH = ExperimentLayoutConstants.rulerCheckboxHeight;
    const rulerUnderGraphGap = ExperimentLayoutConstants.rulerUnderGraphGap;
    final graphTop = screenControls.bottom + stack;
    final graphContentH = ExperimentLayoutConstants.graphExpandedContentHeight;
    final graphMaxH =
        (reset.top - QwiSpacing.s3 - graphTop - rulerH - rulerUnderGraphGap).clamp(24.0, 200.0);
    final graphH = graphContentH <= graphMaxH ? graphContentH : graphMaxH;
    final graph = QwiRect(detector.left, graphTop, detW, graphH);

    // Spec anchor for Ruler (composer uses Column; Y matches expanded graph).
    final rulerCheckbox = QwiRect(
      detector.left,
      graph.bottom + rulerUnderGraphGap,
      ExperimentLayoutConstants.rulerCheckboxWidth,
      rulerH,
    );
    final eraser = QwiRect(
      reset.left - QwiSpacing.margin - ExperimentLayoutConstants.eraserWidth,
      resetCenterY - ExperimentLayoutConstants.eraserHeight / 2,
      ExperimentLayoutConstants.eraserWidth,
      ExperimentLayoutConstants.eraserHeight,
    );
    final timeW = ExperimentLayoutConstants.timeControlsWidth;
    final timeControls = QwiRect(
      detector.centerX - timeW / 2,
      resetCenterY - ExperimentLayoutConstants.timeControlsHeight / 2,
      timeW,
      ExperimentLayoutConstants.timeControlsHeight,
    );

    final overheadBand = QwiRect(0, 0, canvas.width, rowTop);
    final frontFacingRow = QwiRect(0, rowTop, canvas.width, rowHScaled);
    final belowRowControls = QwiRect(0, controlsTop, canvas.width, reset.top - controlsTop);
    final bottomToolRow = QwiRect(0, reset.top - 4, canvas.width, canvas.height - (reset.top - 4));

    return ExperimentLayoutSpec._(
      canvas: canvas,
      overheadBand: overheadBand,
      frontFacingRow: frontFacingRow,
      belowRowControls: belowRowControls,
      bottomToolRow: bottomToolRow,
      sourcePanel: sourcePanel,
      sceneRadios: sceneRadios,
      slitView: slitView,
      slitPanel: slitPanel,
      detector: detector,
      snapshotColumn: snapshotColumn,
      screenControls: screenControls,
      graph: graph,
      rulerCheckbox: rulerCheckbox,
      timeControls: timeControls,
      eraser: eraser,
      reset: reset,
      middleCenterX: middleCenterX,
      stackGap: stack,
      frontFacingScale: frontFacingScale,
    );
  }

  final Size canvas;
  final QwiRect overheadBand;
  final QwiRect frontFacingRow;
  final QwiRect belowRowControls;
  final QwiRect bottomToolRow;
  final QwiRect sourcePanel;
  final QwiRect sceneRadios;
  final QwiRect slitView;
  final QwiRect slitPanel;
  final QwiRect detector;
  final QwiRect snapshotColumn;
  final QwiRect screenControls;
  final QwiRect graph;
  final QwiRect rulerCheckbox;
  final QwiRect timeControls;
  final QwiRect eraser;
  final QwiRect reset;
  final double middleCenterX;
  final double stackGap;

  /// 1.0 = PhET ideal widths; &lt;1 when clear-columns fit scales slit+detector.
  final double frontFacingScale;

  double get bottomToolsCenterY => reset.centerY;
}

/// PhET ExperimentConstants + QuantumWaveInterferenceConstants used by Spec.
abstract final class ExperimentLayoutConstants {
  static const double designWidth = 768;
  static const double designHeight = 504;

  /// PhET ideal (may be scaled down by [ExperimentLayoutSpec.frontFacingScale]).
  static const double frontFacingSlitViewWidth = 204;
  static const double frontFacingRowHeight = 155;
  static const double frontFacingRowTop = 160;
  static const double detectorScreenWidth = 376;
  static const double slitControlPanelWidth = 224;
  static const double overheadElementScale = 1.2;
  static const double overheadSkewScale = 0.5;

  /// Fraction of overhead-band height for emitter / slit / detector centerY.
  /// Lower = higher on screen (PhET ~0.45–0.50 of band above front-facing row).
  static const double overheadBeamYFraction = 0.48;
  static const double detectorScaleBarBand = 14;
  /// Gap under front-facing slit/detector before Slit Separation / ScreenControls.
  /// Tighter than [QwiSpacing.stack] so controls sit closer without covering
  /// the in-box scale labels (250 μm / bottom of black plates).
  static const double frontFacingControlsGap = 2;
  static const double sourceControlPanelTop = 158;
  /// PhET authored centerY (kept for reference); Experiment places radios under source.
  static const double sceneButtonGroupCenterY = 470;
  static const double sceneRadiosGapBelowSource = 16;
  /// Extra gap between front-facing slit plate and Slit Separation panel.
  static const double slitPanelExtraTopGap = 10;
  static const double middleColumnLeftShift = 3;

  /// OverheadEmitterNode BASE_EMITTER_LEFT — source panel left tracks emitter.
  static const double baseEmitterLeft = 20;

  static const double sourcePanelMinWidth = 160;
  static const double sourcePanelContentHeight = 128;
  static const double snapshotColumnWidth = 40;
  static const double screenControlsContentWidth = 300;
  static const double screenBrightnessColumnWidth = 160;
  static const double screenControlsHeightEstimate = 52;
  static const double resetRadius = 18;

  /// SceneRadioButtonGroup ≈ 2×50 buttons + 12 spacing (PhET BUTTON_SIDE_LENGTH).
  static const double sceneRadiosWidth = 112;
  static const double sceneRadiosHeight = 120;
  static const double sceneRadioCellWidth = 50;
  static const double sceneRadioCellHeight = 54;
  static const double sceneRadioSpacing = 12;
  static const double slitControlPanelBottomMargin = 2;
  static const double rulerCheckboxHalfH = 12;
  static const double rulerCheckboxHeight = 32;
  static const double rulerCheckboxWidth = 110;
  static const double rulerUnderGraphGap = 4;
  /// ExperimentGraphAccordion expanded: title 24 + chart 103 + pad 12.
  static const double graphExpandedContentHeight = 24 + 103 + 12;
  static const double eraserWidth = 32;
  static const double eraserHeight = 26;
  static const double timeControlsWidth = 88;
  static const double timeControlsHeight = 40;

  static const double graphChartWidth = 376;
  static const double graphChartHeight = 103;
}
