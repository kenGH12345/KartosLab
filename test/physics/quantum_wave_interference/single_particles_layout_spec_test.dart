import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/view/layout/high_intensity_layout_spec.dart';
import 'package:kratos/physics/quantum_wave_interference/view/layout/single_particles_layout_spec.dart';

void main() {
  group('SingleParticlesLayoutSpec formulas (SINGLE_PARTICLES_LAYOUT_SPEC)', () {
    late SingleParticlesLayoutSpec spec;
    late HighIntensityLayoutSpec hi;

    setUp(() {
      spec = SingleParticlesLayoutSpec.resolve();
      hi = HighIntensityLayoutSpec.resolve();
    });

    test('design canvas is 768×504', () {
      expect(spec.canvas.width, 768);
      expect(spec.canvas.height, 504);
    });

    test('wave region matches HI (source-proven shared formula)', () {
      expect(spec.waveRegion.left, closeTo(hi.waveRegion.left, 0.01));
      expect(spec.waveRegion.top, closeTo(hi.waveRegion.top, 0.01));
      expect(spec.waveRegion.width, hi.waveRegion.width);
      expect(spec.waveRegion.height, hi.waveRegion.height);
      expect(spec.waveRegion.top, closeTo(92, 0.01));
    });

    test('detector / graph formulas match HI', () {
      expect(spec.detector.left, closeTo(hi.detector.left, 0.01));
      expect(spec.graph.left, closeTo(hi.graph.left, 0.01));
      expect(spec.graph.top, closeTo(spec.waveRegion.top, 0.01));
    });

    test('source panel top == Y_MARGIN + 20 (≠ HI 178)', () {
      expect(
        spec.sourcePanelTop,
        closeTo(SingleParticlesLayoutConstants.verticalMargin + 20, 0.01),
      );
      expect(spec.sourcePanel.top, isNot(HighIntensityLayoutConstants.sourceControlPanelTop));
    });

    test('scene radios sit in left bottom blank (like HI)', () {
      expect(
        spec.sceneRadios.top,
        greaterThanOrEqualTo(
          spec.sourcePanel.bottom + SingleParticlesLayoutConstants.sceneRadiosGapBelowSource,
        ),
      );
      expect(
        spec.sceneRadios.bottom,
        closeTo(504 - SingleParticlesLayoutConstants.verticalMargin, 0.5),
      );
    });

    test('right panel: Wave Display → Screen → Tools (original order)', () {
      expect(
        spec.rightControls.right,
        closeTo(768 - SingleParticlesLayoutConstants.horizontalMargin, 0.01),
      );
      expect(spec.waveDisplayPanel.top, SingleParticlesLayoutConstants.verticalMargin);
      expect(
        spec.screenControlsPanel.top,
        closeTo(spec.waveDisplayPanel.bottom + SingleParticlesLayoutConstants.rightPanelStackGap, 0.01),
      );
      expect(
        spec.toolsPanel.top,
        closeTo(spec.screenControlsPanel.bottom + SingleParticlesLayoutConstants.rightPanelStackGap, 0.01),
      );
      expect(spec.leftColumn.right, lessThanOrEqualTo(spec.waveRegion.left));
      expect(spec.waveDisplayPanel.left, greaterThanOrEqualTo(spec.waveRegion.right));
    });

    test('SP emitter right edge meets wave left; sits above bottom radios', () {
      expect(
        spec.emitter.right,
        closeTo(spec.waveRegion.left + SingleParticlesLayoutConstants.emitterOverlap, 0.5),
      );
      expect(spec.emitter.bottom, lessThanOrEqualTo(spec.sceneRadios.top + 0.5));
      expect(spec.emitter.bottom, lessThanOrEqualTo(spec.waveRegion.bottom + 1));
      expect(spec.emitter.left, greaterThanOrEqualTo(spec.leftColumn.right - 20.5));
    });

    test('bottom tools share Reset centerY', () {
      expect(
        spec.reset.right,
        closeTo(768 - SingleParticlesLayoutConstants.horizontalMargin, 0.01),
      );
      expect(
        spec.reset.bottom,
        closeTo(504 - SingleParticlesLayoutConstants.verticalMargin, 0.01),
      );
      expect(spec.clearButton.centerY, closeTo(spec.bottomToolsCenterY, 0.5));
    });

    test('probe layer covers wave + panel extension', () {
      expect(spec.probeLayer.left, closeTo(spec.waveRegion.left, 0.01));
      expect(spec.probeLayer.top, closeTo(spec.waveRegion.top, 0.01));
      expect(spec.probeLayer.width, closeTo(spec.waveRegion.width, 0.01));
      expect(
        spec.probeLayer.height,
        closeTo(
          spec.waveRegion.height + SingleParticlesLayoutConstants.probePanelExtraHeight,
          0.01,
        ),
      );
    });

    test('slit controls sit under the wave', () {
      expect(spec.slitControls.left, closeTo(spec.waveRegion.left, 0.01));
      expect(
        spec.slitControls.top,
        closeTo(
          spec.waveRegion.bottom + HighIntensityLayoutConstants.slitRowGapBelowWave,
          0.5,
        ),
      );
    });
  });
}
