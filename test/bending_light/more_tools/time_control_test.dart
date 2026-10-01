import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/model/enums.dart';
import 'package:kratos/bending_light/model/more_tools_model.dart';
import 'package:kratos/bending_light/model/wave_chart.dart';
import 'package:kratos/bending_light/physics/wave_math.dart';

void main() {
  test('play, pause, resume and reset drive model time', () {
    final model = MoreToolsModel()..setLaserOn(true);
    model.setLaserView(LaserViewEnum.wave);
    final t0 = model.time;
    model.step();
    expect(model.time, greaterThan(t0));
    final t1 = model.time;
    model.togglePlaying();
    model.step();
    expect(model.time, t1);
    model.togglePlaying();
    model.step();
    expect(model.time, greaterThan(t1));
    model.reset();
    expect(model.time, 0);
    expect(model.isPlaying, isTrue);
  });

  test('slow speed steps less than normal', () {
    final normal = MoreToolsModel()..setSpeed(TimeSpeed.normal);
    normal.step();
    final slow = MoreToolsModel()..setSpeed(TimeSpeed.slow);
    slow.step();
    expect(slow.time, lessThan(normal.time));
    expect(WaveMath.dtForSpeed(normal: false), lessThan(WaveMath.dtForSpeed(normal: true)));
  });

  test('chart window matches ChartNode', () {
    expect(WaveChartWindow.timeWidth, 72e-16);
    expect(WaveChartWindow.yMin, -1);
    expect(WaveChartWindow.yMax, 1);
    expect(WaveChartWindow.verticalSpacing(), 72e-16 / 4);
  });
}
