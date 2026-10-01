import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_timer.dart';

void main() {
  group('GameTimer', () {
    test('start stop reset', () {
      final t = GameTimer();
      expect(t.isRunning, isFalse);
      expect(t.elapsedSeconds, 0);
      t.start();
      expect(t.isRunning, isTrue);
      t.tick(1.5);
      expect(t.elapsedSeconds, 1);
      t.tick(0.6);
      expect(t.elapsedSeconds, 2);
      t.stop();
      t.tick(5);
      expect(t.elapsedSeconds, 2); // no advance when stopped
      t.reset();
      expect(t.isRunning, isFalse);
      expect(t.elapsedSeconds, 0);
    });

    test('tick while not running is noop', () {
      final t = GameTimer();
      t.tick(10);
      expect(t.elapsedSeconds, 0);
    });
  });
}
