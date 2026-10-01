import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/simulation_clock.dart';
import 'package:kratos/forces/model/famb_constants.dart';

void main() {
  test('SimulationClock dt matches PhET 1/60', () {
    final clock = SimulationClock(fps: 60);
    expect(clock.dt, closeTo(MotionConstants.dt, 1e-12));
  });

  test('stepForward advances totalTime by dt when paused', () {
    // Without ticker attach, stepForward still works
    final clock = SimulationClock(fps: 60);
    var ticks = 0;
    clock.onTick = (_, _) => ticks++;
    clock.stepForward();
    expect(ticks, 1);
    expect(clock.totalTime, closeTo(1 / 60, 1e-12));
    clock.stepForward();
    expect(clock.totalTime, closeTo(2 / 60, 1e-12));
  });

  test('reset clears totalTime', () {
    final clock = SimulationClock(fps: 60);
    clock.stepForward();
    clock.reset();
    expect(clock.totalTime, 0);
  });
}
