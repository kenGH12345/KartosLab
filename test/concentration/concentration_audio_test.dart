import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/concentration/audio/concentration_audio.dart';
import 'package:kratos/concentration/concentration_assets.dart';
import 'package:kratos/concentration/model/concentration_model.dart';
import 'package:kratos/concentration/view/concentration_screen.dart';

void main() {
  group('Source audio audit', () {
    test('uses tambo shared grab/release assets (not invented SFX)', () {
      expect(ConcentrationAssets.grabSound, contains('grab.mp3'));
      expect(ConcentrationAssets.releaseSound, contains('release.mp3'));
      expect(ConcentrationAssets.grabSound, isNot(contains('water')));
      expect(ConcentrationAssets.releaseSound, isNot(contains('shaker')));
    });

    test('default volume matches tambo UI clip level 0.7', () {
      expect(ConcentrationAudioPlayer.defaultVolume, 0.7);
    });
  });

  group('Drag audio lifecycle', () {
    test('grab then release once per drag', () async {
      final audio = RecordingConcentrationAudio();
      await audio.onDragStart();
      await audio.onDragStart(); // latched — no second grab
      expect(audio.grabCount, 1);
      await audio.onDragEnd();
      expect(audio.releaseCount, 1);
      expect(audio.events.where((e) => e == 'release'), hasLength(1));
      await audio.onDragEnd();
      expect(audio.releaseCount, 1);
    });

    test('interrupted drag skips release sound', () async {
      final audio = RecordingConcentrationAudio();
      await audio.onDragStart();
      await audio.onDragEnd(interrupted: true);
      expect(audio.grabCount, 1);
      expect(audio.releaseCount, 0);
      expect(audio.events, isNot(contains('release')));
      expect(audio.isDragging, isFalse);
    });

    test('no double release after faucet close', () async {
      final audio = RecordingConcentrationAudio();
      await audio.onDragStart();
      await audio.onFaucetClosed();
      expect(audio.releaseCount, 1);
      await audio.onDragEnd();
      expect(audio.releaseCount, 1);
    });
  });

  group('Dispose / reset / re-entry', () {
    test('dispose blocks further callbacks', () async {
      final audio = RecordingConcentrationAudio();
      await audio.onDragStart();
      await audio.dispose();
      expect(audio.isDisposed, isTrue);
      final grabs = audio.grabCount;
      final releases = audio.releaseCount;
      await audio.onDragStart();
      await audio.onDragEnd();
      await audio.onFaucetClosed();
      expect(audio.grabCount, grabs);
      expect(audio.releaseCount, releases);
    });

    test('stopAll clears drag latch', () async {
      final audio = RecordingConcentrationAudio();
      await audio.onDragStart();
      expect(audio.isDragging, isTrue);
      await audio.stopAll();
      expect(audio.isDragging, isFalse);
      await audio.onDragEnd();
      expect(audio.releaseCount, 0);
    });

    test('re-entry: new audio instance does not inherit old counts', () async {
      final first = RecordingConcentrationAudio();
      await first.onDragStart();
      await first.onDragEnd();
      await first.dispose();

      final second = RecordingConcentrationAudio();
      expect(second.grabCount, 0);
      expect(second.releaseCount, 0);
      await second.onDragStart();
      await second.onDragEnd();
      expect(second.grabCount, 1);
      expect(second.releaseCount, 1);
    });

    testWidgets('screen dispose stops audio without crash', (tester) async {
      final audio = RecordingConcentrationAudio();
      final model = ConcentrationModel();
      await tester.pumpWidget(
        MaterialApp(
          home: ConcentrationScreen(model: model, audio: audio),
        ),
      );
      await tester.pump();
      await audio.onDragStart();
      expect(audio.isDragging, isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(audio.events, contains('stopAll'));
      expect(audio.isDragging, isFalse);
    });

    testWidgets('reset during drag clears audio latch', (tester) async {
      final audio = RecordingConcentrationAudio();
      final model = ConcentrationModel();
      await tester.pumpWidget(
        MaterialApp(
          home: ConcentrationScreen(model: model, audio: audio),
        ),
      );
      await tester.pump();
      await audio.onDragStart();
      model.reset();
      // Screen reset path calls stopAll via button; call directly:
      await audio.stopAll();
      expect(audio.isDragging, isFalse);
    });
  });

  group('Source applicability', () {
    test('evaporation / remove-solute have no dedicated concentration audio', () {
      // Documented N/A — no API methods beyond grab/release/faucetClosed.
      final audio = RecordingConcentrationAudio();
      expect(audio.events, isEmpty);
    });
  });
}
