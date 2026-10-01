import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/view/layout/high_intensity_layout_spec.dart';

void main() {
  group('HighIntensityLayoutSpec formulas (HIGH_INTENSITY_LAYOUT_SPEC)', () {
    late HighIntensityLayoutSpec spec;

    setUp(() {
      spec = HighIntensityLayoutSpec.resolve();
    });

    test('design canvas is 768×504', () {
      expect(spec.canvas.width, 768);
      expect(spec.canvas.height, 504);
    });

    test('waveRegionTop == 92 (thumbnail + gap + Y offset)', () {
      expect(spec.waveRegion.top, closeTo(92, 0.01));
    });

    test('waveRegionLeft == xMargin + leftColumnWidth + waveRegionLeftGap', () {
      const xMargin = HighIntensityLayoutConstants.horizontalMargin;
      final expected = xMargin +
          HighIntensityLayoutConstants.leftColumnWidthEstimate +
          HighIntensityLayoutConstants.waveRegionLeftGap;
      expect(spec.waveRegion.left, closeTo(expected, 0.01));
    });

    test('wave is capped so right rail stays clear (≤360×330)', () {
      expect(spec.waveRegion.height, HighIntensityLayoutConstants.waveRegionHeight);
      expect(spec.waveRegion.width, lessThanOrEqualTo(HighIntensityLayoutConstants.waveRegionWidth));
      expect(
        spec.waveRegion.right + HighIntensityLayoutConstants.waveRegionRightGap,
        lessThanOrEqualTo(spec.screenControlsPanel.left + 0.5),
      );
      expect(
        spec.screenControlsPanel.left - spec.waveRegion.right,
        greaterThanOrEqualTo(10),
      );
    });

    test('left column and right rail do not overlap wave', () {
      expect(spec.leftColumn.right, lessThanOrEqualTo(spec.waveRegion.left));
      expect(spec.waveDisplayPanel.left, greaterThanOrEqualTo(spec.waveRegion.right));
    });

    test('PhET-style margins and right panel width', () {
      expect(HighIntensityLayoutConstants.horizontalMargin, 15);
      expect(HighIntensityLayoutConstants.verticalMargin, 15);
      expect(HighIntensityLayoutConstants.rightPanelWidth, 180);
      expect(HighIntensityLayoutConstants.waveRegionWidth, 360);
    });

    test('detector left == waveRight − 66·0.33', () {
      final expected = spec.waveRegion.right -
          HighIntensityLayoutConstants.detectorScreenWidth *
              HighIntensityLayoutConstants.detectorOverlapFraction;
      expect(spec.detector.left, closeTo(expected, 0.01));
      expect(spec.detector.width, HighIntensityLayoutConstants.detectorScreenWidth);
    });

    test('graph left == waveRight + 2; top == waveTop', () {
      expect(spec.graph.left, closeTo(spec.waveRegion.right + HighIntensityLayoutConstants.graphLeftGap, 0.01));
      expect(spec.graph.top, closeTo(spec.waveRegion.top, 0.01));
    });

    test('source panel top == 178; scene radios sit in left bottom blank', () {
      expect(spec.sourcePanel.top, HighIntensityLayoutConstants.sourceControlPanelTop);
      expect(
        spec.sceneRadios.top,
        greaterThanOrEqualTo(
          spec.sourcePanel.bottom + HighIntensityLayoutConstants.sceneRadiosGapBelowSource,
        ),
      );
      expect(
        spec.sceneRadios.bottom,
        closeTo(504 - HighIntensityLayoutConstants.verticalMargin, 0.5),
      );
      expect(spec.sceneRadios.width, closeTo(spec.leftColumnWidth, 0.01));
    });

    test('right panel: Wave Display → Screen → Tools (original order)', () {
      expect(
        spec.waveDisplayPanel.right,
        closeTo(768 - HighIntensityLayoutConstants.horizontalMargin, 0.01),
      );
      expect(spec.waveDisplayPanel.top, HighIntensityLayoutConstants.verticalMargin);
      expect(spec.waveDisplayPanel.width, HighIntensityLayoutConstants.rightPanelWidth);
      expect(
        spec.screenControlsPanel.top,
        closeTo(spec.waveDisplayPanel.bottom + HighIntensityLayoutConstants.rightPanelStackGap, 0.01),
      );
      expect(
        spec.toolsPanel.top,
        closeTo(spec.screenControlsPanel.bottom + HighIntensityLayoutConstants.rightPanelStackGap, 0.01),
      );
      expect(spec.toolsPanel.bottom, lessThanOrEqualTo(spec.reset.top));
    });

    test('tools panel is under screen controls; Measuring Tape not bottom-left', () {
      expect(spec.toolsPanel.left, closeTo(spec.screenControlsPanel.left, 0.01));
      expect(spec.measuringTapeCheckbox.left, greaterThan(spec.leftColumn.right));
    });

    test('HI emitter sits in left column thumbnail band', () {
      expect(spec.emitter.centerX, closeTo(spec.sourcePanel.centerX, 0.5));
      expect(spec.emitter.centerY, closeTo(HighIntensityLayoutConstants.emitterCenterY, 0.5));
      expect(spec.emitter.bottom, lessThanOrEqualTo(spec.sourcePanel.top + 0.5));
    });

    test('bottom tools share Reset centerY; Reset is bottom-right', () {
      expect(
        spec.reset.right,
        closeTo(768 - HighIntensityLayoutConstants.horizontalMargin, 0.01),
      );
      expect(
        spec.reset.bottom,
        closeTo(504 - HighIntensityLayoutConstants.verticalMargin, 0.01),
      );
      expect(spec.clearButton.centerY, closeTo(spec.bottomToolsCenterY, 0.5));
    });

    test('slit controls sit under the wave', () {
      expect(spec.slitControls.left, closeTo(spec.waveRegion.left, 0.01));
      expect(spec.slitControls.width, closeTo(spec.waveRegion.width, 0.01));
      expect(
        spec.slitControls.top,
        closeTo(
          spec.waveRegion.bottom + HighIntensityLayoutConstants.slitRowGapBelowWave,
          0.5,
        ),
      );
      expect(spec.slitControls.bottom, lessThanOrEqualTo(504 - HighIntensityLayoutConstants.verticalMargin + 0.5));
    });
  });
}
