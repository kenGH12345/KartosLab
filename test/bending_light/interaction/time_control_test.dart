import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/model/enums.dart';
import 'package:kratos/bending_light/model/more_tools_model.dart';

void main() {
  test('play advances model time and pause stops it', () {
    final model = MoreToolsModel()..setLaserOn(true);
    model.waveSensor.enabled = true;
    expect(model.isPlaying, isTrue);
    final t0 = model.time;
    model.step();
    final t1 = model.time;
    expect(t1, greaterThan(t0));

    model.togglePlaying();
    expect(model.isPlaying, isFalse);
    model.step();
    expect(model.time, t1);

    model.stepOnce();
    expect(model.time, greaterThan(t1));
  });

  test('slow speed uses a smaller step than normal', () {
    final normal = MoreToolsModel()..setLaserOn(true);
    normal.setSpeed(TimeSpeed.normal);
    normal.step();
    final slow = MoreToolsModel()..setLaserOn(true);
    slow.setSpeed(TimeSpeed.slow);
    slow.step();
    expect(slow.time, lessThan(normal.time));
  });
}
