import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/audio/gfl_audio.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_lab_model.dart';
import 'package:kratos/gravity_force_lab/screens/gfl_screen_body.dart';
import 'package:kratos/gravity_force_lab/screens/gravity_force_lab_screen.dart';

void main() {
  group('Reset audio lifecycle', () {
    test('reset stops continuous force and clears ruler grab', () async {
      final model = GravityForceLabModel();
      final audio = GflAudio(playEnabled: false)..attach(model);

      model.setPosition(1, -4.0);
      expect(audio.isForcePlaying, isTrue);

      audio.onRulerGrab();
      expect(audio.isRulerGrabbed, isTrue);

      audio.beginReset();
      model.reset();
      audio.endReset();

      expect(audio.isForcePlaying, isFalse);
      expect(audio.isRulerGrabbed, isFalse);
      expect(audio.forceStopCount, greaterThanOrEqualTo(1));

      model.setPosition(2, 2.0);
      expect(audio.isForcePlaying, isTrue);

      await audio.dispose();
      model.dispose();
    });
  });

  group('Dispose audio lifecycle', () {
    test('dispose detaches listeners and ignores further events', () async {
      final model = GravityForceLabModel();
      final audio = GflAudio(playEnabled: false)..attach(model);
      expect(audio.attachCount, 1);

      await audio.dispose();
      expect(audio.isDisposed, isTrue);

      model.setPosition(1, -4.5);
      expect(audio.forceActivationCount, 0);
      audio.onRulerGrab();
      expect(audio.rulerGrabCount, 0);

      model.dispose();
    });

    test('no duplicate listener on re-attach same model', () async {
      final model = GravityForceLabModel();
      final audio = GflAudio(playEnabled: false)..attach(model);
      audio.attach(model);
      expect(audio.attachCount, 1);

      model.setPosition(1, -4.0);
      expect(audio.forceActivationCount, 1);

      await audio.dispose();
      model.dispose();
    });
  });

  group('Screen dispose / re-entry', () {
    testWidgets('leave and re-enter does not duplicate audio attach',
        (tester) async {
      final audio = GflAudio(playEnabled: false);

      await tester.pumpWidget(
        MaterialApp(
          home: GravityForceLabScreen(audio: audio),
        ),
      );
      expect(audio.attachCount, 1);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();

      await tester.pumpWidget(
        MaterialApp(
          home: GravityForceLabScreen(audio: audio),
        ),
      );
      expect(audio.attachCount, lessThanOrEqualTo(2));
      expect(audio.isDisposed, isFalse);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await audio.dispose();
    });

    testWidgets('GflScreenBody ticker dispose detaches injected audio',
        (tester) async {
      final model = GravityForceLabModel();
      final audio = GflAudio(playEnabled: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GflScreenBody(model: model, audio: audio),
          ),
        ),
      );

      model.setPosition(1, -4.2);
      expect(audio.isForcePlaying, isTrue);

      await tester.pump(const Duration(milliseconds: 500));
      expect(audio.isDisposed, isFalse);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
      expect(audio.isDisposed, isFalse);
      final activations = audio.forceActivationCount;
      model.setPosition(2, 3.0);
      expect(audio.forceActivationCount, activations);

      await audio.dispose();
      model.dispose();
    });
  });
}
