import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_skate_park/controller/intro_controller.dart';
import 'package:kratos/energy_skate_park/model/esp_vec.dart';
import 'package:kratos/energy_skate_park/model/measurement_tools.dart';
import 'package:kratos/energy_skate_park/widgets/toolbox_return.dart';

void main() {
  group('ToolboxReturn (EnergySkateParkScreenView.ts)', () {
    test('intersectsBounds — no distance threshold', () {
      const toolbox = Rect.fromLTWH(100, 100, 80, 40);
      expect(
        ToolboxReturn.shouldReturn(
          toolBounds: const Rect.fromLTWH(170, 110, 20, 20),
          toolboxBounds: toolbox,
        ),
        isTrue,
      );
      expect(
        ToolboxReturn.shouldReturn(
          toolBounds: const Rect.fromLTWH(50, 50, 20, 20),
          toolboxBounds: toolbox,
        ),
        isFalse,
      );
    });

    test('measuring tape uses base image bounds only', () {
      const base = Offset(200, 300);
      final bounds = ToolboxReturn.measuringTapeBaseBounds(baseView: base);
      expect(bounds.right, closeTo(200, 0.01));
      expect(bounds.bottom, closeTo(300, 0.01));
    });
  });

  group('MeasurementTools lifecycle', () {
    test('hiding stopwatch resets time (Stopwatch.ts)', () {
      final tools = MeasurementTools();
      tools.stopwatchVisible = true;
      tools.stopwatchTime = 12.5;
      tools.onStopwatchHidden();
      expect(tools.stopwatchTime, 0);
    });

    test('return measuring tape preserves endpoints', () {
      final tools = MeasurementTools();
      tools.placeMeasuringTapeAt(const EspVec(2, 3));
      tools.measuringTapeTip = const EspVec(5, 3);
      tools.measuringTapeVisible = false;
      expect(tools.measuringTapeBase.x, 2);
      expect(tools.measuringTapeTip.x, 5);
    });
  });

  group('EspController return-to-toolbox', () {
    test('returnStopwatchToToolbox clears visibility and time', () {
      final c = IntroController();
      c.model.tools.stopwatchVisible = true;
      c.model.tools.stopwatchTime = 8;
      c.returnStopwatchToToolbox();
      expect(c.model.stopwatchVisible, isFalse);
      expect(c.model.stopwatchTime, 0);
    });

    test('returnMeasuringTapeToToolbox clears visibility only', () {
      final c = IntroController();
      c.placeMeasuringTapeFromToolbox(const EspVec(1, 1));
      c.returnMeasuringTapeToToolbox();
      expect(c.model.measuringTapeVisible, isFalse);
      expect(c.model.measuringTapeBase.x, 1);
    });
  });
}
