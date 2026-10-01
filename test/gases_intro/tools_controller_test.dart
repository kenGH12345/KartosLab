import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gases_intro/model/ideal_gas_law_model.dart';
import 'package:kratos/gases_intro/view/tools_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ToolsController reset restores positions and counters', () {
    final tools = ToolsController();
    tools.stopwatchPosition = const Offset(100, 100);
    tools.collisionPosition = const Offset(50, 50);
    tools.stopwatchTimePs = 12.3;
    tools.stopwatchRunning = true;
    tools.numberOfCollisions = 9;
    tools.collisionRunning = true;
    tools.samplePeriodPs = 20;

    tools.reset();

    expect(tools.stopwatchPosition, ToolsController.stopwatchHome);
    expect(tools.collisionPosition, ToolsController.collisionHome);
    expect(tools.stopwatchTimePs, 0);
    expect(tools.stopwatchRunning, isFalse);
    expect(tools.numberOfCollisions, 0);
    expect(tools.collisionRunning, isFalse);
    expect(tools.samplePeriodPs, 10);
  });

  test('Stopwatch advances only while running on model step delta', () {
    final model =
        IdealGasLawModel(hasHoldConstantControls: false, autoTick: false);
    final tools = ToolsController();
    model.setStopwatchVisible(true);
    tools.syncFromModel(model);

    tools.setStopwatchRunning(true);
    model.stepOnce();
    tools.syncFromModel(model);

    expect(tools.stopwatchTimePs, closeTo(0.2, 1e-9));

    tools.setStopwatchRunning(false);
    model.stepOnce();
    tools.syncFromModel(model);
    expect(tools.stopwatchTimePs, closeTo(0.2, 1e-9));

    model.dispose();
  });

  test('drag clamps stopwatch inside layoutBounds', () {
    final tools = ToolsController();
    const bounds = Rect.fromLTWH(0, 0, 1008, 618);
    tools.dragStopwatch(const Offset(5000, 5000), bounds, 1.0);
    expect(
      tools.stopwatchPosition.dx,
      lessThanOrEqualTo(1008 - ToolsController.stopwatchSize.width),
    );
    expect(
      tools.stopwatchPosition.dy,
      lessThanOrEqualTo(618 - ToolsController.stopwatchSize.height),
    );
  });
}
