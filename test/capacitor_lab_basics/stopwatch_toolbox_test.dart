import 'dart:ui' show Offset, Rect;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/capacitor_lab_basics/clb_constants.dart';
import 'package:kratos/capacitor_lab_basics/common/model/clb_model.dart';
import 'package:kratos/capacitor_lab_basics/common/widgets/stopwatch_interaction.dart';
import 'package:kratos/capacitor_lab_basics/light_bulb/model/clb_light_bulb_model.dart';

void main() {
  group('stopwatch_toolbox_drag_test', () {
    test('placeStopwatchAt centers extract under pointer helper', () {
      final tl = ClbStopwatchLayout.topLeftCenteredOn(const Offset(200, 300));
      expect(tl.dx, 200 - ClbStopwatchLayout.width / 2);
      expect(tl.dy, 300 - ClbStopwatchLayout.height / 2);
    });

    test('placeStopwatchAt shows tool without starting timer', () {
      final m = ClbLightBulbModel(shared: ClbSharedState());
      m.placeStopwatchAt(const Offset(50, 60));
      expect(m.stopwatchVisible, isTrue);
      expect(m.stopwatchX, 50);
      expect(m.stopwatchY, 60);
      expect(m.stopwatchRunning, isFalse);
      expect(m.stopwatchTime, 0);
      m.dispose();
    });
  });

  group('stopwatch_return_bounds_test', () {
    test('full bounds ∩ toolbox returns; near-miss does not (no eroded)', () {
      final m = ClbLightBulbModel(shared: ClbSharedState());
      m.placeStopwatchAt(const Offset(100, 100));
      m.stopwatchTime = 3.5;
      m.stopwatchRunning = true;

      final miss = Rect.fromLTWH(400, 400, 50, 50);
      expect(
        maybeReturnStopwatchToToolbox(model: m, toolboxBounds: miss),
        isFalse,
      );
      expect(m.stopwatchVisible, isTrue);
      expect(m.stopwatchTime, 3.5);

      final hit = Rect.fromLTWH(80, 80, 100, 100);
      expect(
        maybeReturnStopwatchToToolbox(model: m, toolboxBounds: hit),
        isTrue,
      );
      expect(m.stopwatchVisible, isFalse);
      m.dispose();
    });
  });

  group('stopwatch_return_state_test', () {
    test('return resets time, running, visibility (Stopwatch.reset)', () {
      final m = ClbLightBulbModel(shared: ClbSharedState());
      m.placeStopwatchAt(const Offset(10, 10));
      m.stopwatchTime = 12.3;
      m.stopwatchRunning = true;
      m.returnStopwatchToToolbox();
      expect(m.stopwatchVisible, isFalse);
      expect(m.stopwatchRunning, isFalse);
      expect(m.stopwatchTime, 0);
      m.dispose();
    });
  });

  group('stopwatch_reset_test', () {
    test('screen Reset All restores stopwatch defaults', () {
      final m = ClbLightBulbModel(shared: ClbSharedState());
      m.placeStopwatchAt(const Offset(70, 90));
      m.stopwatchTime = 5;
      m.stopwatchRunning = true;
      m.reset();
      expect(m.stopwatchVisible, isFalse);
      expect(m.stopwatchRunning, isFalse);
      expect(m.stopwatchTime, 0);
      expect(m.stopwatchX, 40);
      expect(m.stopwatchY, ClbConstants.canvasHeight - 188);
      m.dispose();
    });
  });
}
