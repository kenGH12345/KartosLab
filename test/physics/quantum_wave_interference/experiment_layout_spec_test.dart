import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/view/layout/experiment_layout_spec.dart';
import 'package:kratos/physics/quantum_wave_interference/view/layout/qwi_layout_primitives.dart';

void main() {
  group('ExperimentLayoutSpec formulas (LAYOUT_SPEC + clear-columns fit)', () {
    late ExperimentLayoutSpec spec;

    setUp(() {
      spec = ExperimentLayoutSpec.resolve();
    });

    test('design canvas is 768×504', () {
      expect(spec.canvas.width, 768);
      expect(spec.canvas.height, 504);
    });

    test('clear-columns fit scales slit+detector so columns do not overlap', () {
      expect(spec.frontFacingScale, lessThanOrEqualTo(1.0));
      expect(spec.frontFacingScale, greaterThan(0.5));
      // Min gap between middle slit and right detector.
      expect(spec.slitView.right, lessThanOrEqualTo(spec.detector.left - QwiSpacing.stack + 0.5));
      // Left column clears the slit band.
      expect(spec.sourcePanel.right, lessThanOrEqualTo(spec.slitView.left - QwiSpacing.stack + 0.5));
      expect(spec.slitPanel.right, lessThanOrEqualTo(spec.detector.left - QwiSpacing.stack + 0.5));
    });

    test('detector is right-anchored with snapshot column', () {
      const margin = QwiSpacing.margin;
      final expectedLeft = 768 -
          margin -
          ExperimentLayoutConstants.snapshotColumnWidth -
          QwiSpacing.snapshotGap -
          spec.detector.width;
      expect(spec.detector.left, closeTo(expectedLeft, 0.01));
      expect(
        spec.detector.height,
        closeTo(ExperimentLayoutConstants.frontFacingRowHeight * spec.frontFacingScale, 0.01),
      );
      expect(spec.detector.top, ExperimentLayoutConstants.frontFacingRowTop);
      expect(spec.snapshotColumn.left, closeTo(spec.detector.right + QwiSpacing.snapshotGap, 0.01));
    });

    test('middle column shares centerX; widths follow clear-columns scale', () {
      expect(spec.slitView.centerX, closeTo(spec.middleCenterX, 0.5));
      expect(spec.slitPanel.centerX, closeTo(spec.middleCenterX, 1.0));
      expect(
        spec.slitView.width,
        closeTo(ExperimentLayoutConstants.frontFacingSlitViewWidth * spec.frontFacingScale, 1.0),
      );
      expect(
        spec.detector.width,
        closeTo(ExperimentLayoutConstants.detectorScreenWidth * spec.frontFacingScale, 1.0),
      );
      // Uniform scale preserves PhET aspect ratios.
      expect(
        spec.slitView.height / spec.slitView.width,
        closeTo(
          ExperimentLayoutConstants.frontFacingRowHeight /
              ExperimentLayoutConstants.frontFacingSlitViewWidth,
          0.005,
        ),
      );
      expect(
        spec.detector.height / spec.detector.width,
        closeTo(
          ExperimentLayoutConstants.frontFacingRowHeight /
              ExperimentLayoutConstants.detectorScreenWidth,
          0.005,
        ),
      );
    });

    test('time controls centerX aligns with detector center', () {
      expect(spec.timeControls.centerX, closeTo(spec.detector.centerX, 0.5));
    });

    test('right column +8 chain: detector → controls → graph', () {
      expect(
        spec.screenControls.top,
        closeTo(spec.detector.bottom + ExperimentLayoutConstants.frontFacingControlsGap, 0.01),
      );
      expect(spec.graph.top, closeTo(spec.screenControls.bottom + QwiSpacing.stack, 0.01));
      expect(spec.stackGap, QwiSpacing.stack);
    });

    test('screen controls centerX = detector centerX (not left-stretched)', () {
      expect(spec.screenControls.centerX, closeTo(spec.detector.centerX, 0.5));
      expect(spec.screenControls.left, greaterThanOrEqualTo(spec.slitPanel.right - 0.5));
    });

    test('graph chart aligns to detector left / width', () {
      expect(spec.graph.left, closeTo(spec.detector.left, 0.01));
      expect(spec.graph.width, closeTo(spec.detector.width, 0.01));
    });

    test('bottom tools: time/eraser/reset share centerY; Ruler under expanded graph', () {
      expect(spec.reset.right, closeTo(768 - QwiSpacing.margin, 0.01));
      expect(spec.reset.bottom, closeTo(504 - QwiSpacing.margin, 0.01));
      expect(
        spec.rulerCheckbox.top,
        closeTo(spec.graph.bottom + ExperimentLayoutConstants.rulerUnderGraphGap, 0.01),
      );
      expect(spec.rulerCheckbox.left, closeTo(spec.graph.left, 0.01));
      expect(spec.rulerCheckbox.bottom, lessThanOrEqualTo(spec.reset.top + 0.5));
      expect(spec.timeControls.centerY, closeTo(spec.bottomToolsCenterY, 0.5));
      expect(spec.eraser.centerY, closeTo(spec.bottomToolsCenterY, 0.5));
    });

    test('root regions cover canvas vertically without gaps at seams', () {
      expect(spec.overheadBand.top, 0);
      expect(spec.overheadBand.bottom, ExperimentLayoutConstants.frontFacingRowTop);
      expect(spec.frontFacingRow.top, ExperimentLayoutConstants.frontFacingRowTop);
      expect(
        spec.frontFacingRow.height,
        closeTo(ExperimentLayoutConstants.frontFacingRowHeight * spec.frontFacingScale, 0.01),
      );
      expect(spec.belowRowControls.top, closeTo(spec.detector.bottom + ExperimentLayoutConstants.frontFacingControlsGap, 0.01));
    });

    test('source panel is content-height, not forced to front-facing row height', () {
      expect(spec.sourcePanel.height, ExperimentLayoutConstants.sourcePanelContentHeight);
      // After uniform clear-columns scale, scaled row may be ≤ source content height.
      expect(spec.sourcePanel.height, lessThanOrEqualTo(ExperimentLayoutConstants.frontFacingRowHeight));
    });

    test('source panel top ≈ FRONT_FACING_ROW_TOP', () {
      expect(spec.sourcePanel.top, ExperimentLayoutConstants.sourceControlPanelTop);
    });

    test('scene radios sit under source panel (fill blank band)', () {
      expect(spec.sceneRadios.centerX, closeTo(spec.sourcePanel.centerX, 0.5));
      expect(
        spec.sceneRadios.top,
        closeTo(spec.sourcePanel.bottom + ExperimentLayoutConstants.sceneRadiosGapBelowSource, 0.01),
      );
      expect(spec.sceneRadios.width, ExperimentLayoutConstants.sceneRadiosWidth);
      expect(
        spec.sourcePanel.left,
        QwiSpacing.margin + ExperimentLayoutConstants.baseEmitterLeft,
      );
    });

    test('slit panel stays below front-facing row with a small breathing gap', () {
      expect(
        spec.slitPanel.top,
        closeTo(
          spec.detector.bottom +
              ExperimentLayoutConstants.frontFacingControlsGap +
              ExperimentLayoutConstants.slitPanelExtraTopGap,
          0.01,
        ),
      );
      expect(spec.slitPanel.top, greaterThan(spec.slitView.bottom));
    });
  });
}
