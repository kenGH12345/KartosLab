import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/model/force_solver.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_lab_model.dart';
import 'package:kratos/gravity_force_lab/render/gfl_render_builder.dart';
import 'package:kratos/gravity_force_lab/widgets/puller_image_widget.dart';

void main() {
  final builder = const GflRenderBuilder();
  final forceMin = ForceSolver.getMinForceMagnitude();
  final forceMax = ForceSolver.getMaxForce();

  group('Puller frame mapping (ISLCPullerNode)', () {
    test('frame index lower bound maps to figurePull_1', () {
      final idx = GflRenderBuilder.pullerFrameIndex(
        forceMin,
        forceMin: forceMin,
        forceMax: forceMax,
      );
      expect(idx, 0);
      expect(GflRenderBuilder.pullerFigureNumber(idx), 1);
      expect(PullerImageWidget.assetPath(idx), contains('figurePull_1.png'));
    });

    test('frame index upper bound maps to figurePull_31', () {
      final idx = GflRenderBuilder.pullerFrameIndex(
        forceMax,
        forceMin: forceMin,
        forceMax: forceMax,
      );
      expect(idx, 30);
      expect(GflRenderBuilder.pullerFigureNumber(idx), 31);
      expect(PullerImageWidget.assetPath(idx), contains('figurePull_31.png'));
    });

    test('force to frame linear mapping (no custom easing)', () {
      final mid = forceMin + (forceMax - forceMin) * 0.5;
      final idx = GflRenderBuilder.pullerFrameIndex(
        mid,
        forceMin: forceMin,
        forceMax: forceMax,
      );
      expect(idx, 15);

      var prev = -1;
      for (var t = 0.0; t <= 1.0001; t += 0.05) {
        final f = forceMin + (forceMax - forceMin) * t.clamp(0.0, 1.0);
        final i = GflRenderBuilder.pullerFrameIndex(
          f,
          forceMin: forceMin,
          forceMax: forceMax,
        );
        expect(i, inInclusiveRange(0, 30));
        expect(i >= prev, isTrue);
        prev = i;
      }
    });

    test('left and right puller bind to same force frame', () {
      final model = GravityForceLabModel();
      final r = builder.build(model);
      expect(r.puller1Frame, r.puller2Frame);
      expect(r.puller1Frame, inInclusiveRange(0, 30));
      model.dispose();
    });

    test('right puller flip and ropeLength 40', () {
      expect(PullerImageWidget.ropeLength, 40);
      const left = PullerImageWidget(
        frameIndex: 5,
        massCenter: Offset.zero,
        massRadiusView: 20,
        flipHorizontal: false,
      );
      const right = PullerImageWidget(
        frameIndex: 5,
        massCenter: Offset.zero,
        massRadiusView: 20,
        flipHorizontal: true,
      );
      expect(left.flipHorizontal, isFalse);
      expect(right.flipHorizontal, isTrue);
    });
  });

  group('Force arrow dynamic fidelity', () {
    test('arrow tip updates continuously with force', () {
      final model = GravityForceLabModel();
      final tip0 = builder.build(model).arrow1TipDx.abs();

      model.setPosition(1, -4.5);
      final tip1 = builder.build(model).arrow1TipDx.abs();
      expect(tip1, lessThan(tip0));

      model.setMassValue(1, 800);
      final tip2 = builder.build(model).arrow1TipDx.abs();
      expect(tip2, greaterThan(tip1));
      model.dispose();
    });

    test('rapid force changes stay in legal frame/arrow range', () {
      final model = GravityForceLabModel();
      model.beginDrag(1);
      for (var i = 0; i < 40; i++) {
        model.setPositionWhileDragging(1, -4.5 + (i % 5) * 0.3);
        final r = builder.build(model);
        expect(r.puller1Frame, inInclusiveRange(0, 30));
        expect(r.arrow1TipDx.isFinite, isTrue);
        expect(r.force.isFinite, isTrue);
      }
      model.endDrag(1);
      model.dispose();
    });

    test('no stale frame after reset', () {
      final expected = GravityForceLabModel();
      final expectedFrame = builder.build(expected).puller1Frame;

      final model = GravityForceLabModel();
      model.setMassValue(1, 900);
      model.setMassValue(2, 900);
      model.setPosition(1, -1.0);
      model.setPosition(2, 1.0);
      expect(builder.build(model).puller1Frame, isNot(expectedFrame));

      model.reset();
      expect(builder.build(model).puller1Frame, expectedFrame);
      model.dispose();
      expected.dispose();
    });
  });
}
