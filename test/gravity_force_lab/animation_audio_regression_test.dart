import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/audio/gfl_audio.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_lab_model.dart';
import 'package:kratos/gravity_force_lab/render/gfl_render_builder.dart';

void main() {
  final builder = const GflRenderBuilder();

  group('Rapid animation', () {
    test('rapid mass drag keeps frames/arrows coherent', () {
      final model = GravityForceLabModel();
      model.beginDrag(1);
      for (var i = 0; i < 80; i++) {
        final x = (i.isEven) ? -4.5 : -1.5;
        model.setPositionWhileDragging(1, x);
        final r = builder.build(model);
        expect(r.puller1Frame, r.puller2Frame);
        expect(r.puller1Frame, inInclusiveRange(0, 30));
        expect(r.force.isFinite, isTrue);
        expect(r.arrow1TipDx.isFinite, isTrue);
      }
      model.endDrag(1);
      model.dispose();
    });
  });

  group('Rapid audio', () {
    test('rapid mass drag does not explode continuous instances', () async {
      final model = GravityForceLabModel();
      final audio = GflAudio(playEnabled: false)..attach(model);

      model.beginDrag(1);
      for (var i = 0; i < 60; i++) {
        model.setPositionWhileDragging(1, -4.5 + (i % 8) * 0.4);
      }
      model.endDrag(1);

      expect(audio.forceActivationCount, 1);
      expect(audio.forceUpdateCount, greaterThan(1));
      expect(audio.boundaryCount, lessThan(30));

      await audio.dispose();
      model.dispose();
    });

    test('rapid ruler drag grab/move/release stays coherent', () async {
      final model = GravityForceLabModel();
      final audio = GflAudio(playEnabled: false)..attach(model);

      for (var cycle = 0; cycle < 10; cycle++) {
        audio.onRulerGrab();
        for (var i = 0; i < 8; i++) {
          model.setRulerPosition(
            model.ruler.positionX + 0.6,
            model.ruler.positionY + (i.isEven ? 0.2 : -0.2),
          );
          audio.onRulerMove();
        }
        audio.onRulerRelease();
      }

      expect(audio.rulerGrabCount, 10);
      expect(audio.rulerReleaseCount, 10);
      expect(audio.rulerMovementCount, greaterThan(0));
      expect(audio.isRulerGrabbed, isFalse);

      await audio.dispose();
      model.dispose();
    });

    test('rapid mass slider thresholds do not unbounded-fire', () async {
      final model = GravityForceLabModel();
      final audio = GflAudio(playEnabled: false)..attach(model);
      audio.setMassSliderDraggingViaPointer(true);

      var mass = 100.0;
      for (var i = 0; i < 50; i++) {
        final next = (mass + 10).clamp(10.0, 1000.0);
        audio.onMassValueChanged(1, next, mass);
        mass = next;
      }
      expect(audio.massExtraCount, lessThanOrEqualTo(12));

      await audio.dispose();
      model.dispose();
    });
  });

  group('Re-entry regression', () {
    test('dispose + new audio + model works again', () async {
      final model1 = GravityForceLabModel();
      final audio1 = GflAudio(playEnabled: false)..attach(model1);
      model1.setPosition(1, -4.0);
      expect(audio1.forceActivationCount, 1);
      await audio1.dispose();
      model1.dispose();

      final model2 = GravityForceLabModel();
      final audio2 = GflAudio(playEnabled: false)..attach(model2);
      model2.setPosition(1, -4.0);
      expect(audio2.forceActivationCount, 1);
      expect(audio2.isDisposed, isFalse);
      await audio2.dispose();
      model2.dispose();
    });
  });
}
