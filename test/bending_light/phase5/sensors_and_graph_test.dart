import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/bending_light_constants.dart';
import 'package:kratos/bending_light/model/bl_vec2.dart';
import 'package:kratos/bending_light/model/more_tools_model.dart';
import 'package:kratos/bending_light/model/prism.dart';
import 'package:kratos/bending_light/model/prisms_model.dart';
import 'package:kratos/bending_light/model/substance.dart';
import 'package:kratos/bending_light/model/wave_chart.dart';
import 'package:kratos/bending_light/components/velocity_arrow.dart';
import 'package:kratos/bending_light/interaction/protractor_rotation.dart';
import 'package:kratos/bending_light/physics/vector_snell.dart';
import 'package:kratos/bending_light/transform/bl_mvt.dart';

void main() {
  test('prism rotation retraces rays', () {
    final model = PrismsModel()..setLaserOn(true);
    final square = model.getPrismPrototypes().firstWhere((e) => e.$2 == 'square');
    final prism = Prism(square.$1, square.$2).copy();
    model.addPrism(prism);
    final before = model.rays.map((r) => r.tip.x + r.tip.y).fold<double>(0, (a, b) => a + b);
    prism.rotate(0.35);
    model.updateModel();
    final after = model.rays.map((r) => r.tip.x + r.tip.y).fold<double>(0, (a, b) => a + b);
    expect(after, isNot(closeTo(before, 1e-12)));
  });

  test('recursive tracing stays under the step cap', () {
    final model = PrismsModel()..setLaserOn(true);
    model.setShowReflections(true);
    final tri = model.getPrismPrototypes().firstWhere((e) => e.$2 == 'triangle');
    model.addPrism(Prism(tri.$1, tri.$2).copy());
    expect(model.rays.length, lessThan(BendingLightConstants.maxLightRaySteps * 4));
  });

  test('chart window and grid phase follow ChartNode', () {
    expect(WaveChartWindow.timeWidth, 72e-16);
    expect(WaveChartWindow.yMin, -1);
    expect(WaveChartWindow.yMax, 1);
    expect(WaveChartWindow.gridPhase(0), 0);
    final later = WaveChartWindow.gridPhase(WaveChartWindow.timeWidth);
    expect(later, closeTo(0, 1e-30));
    final mid = WaveChartWindow.gridPhase(WaveChartWindow.verticalSpacing() / 2);
    expect(mid, closeTo(WaveChartWindow.verticalSpacing() / 2, 1e-30));
  });

  test('velocity arrow follows model direction and hides at zero', () {
    final mvt = BlMvt.moreTools();
    final right = velocityArrowViewDelta(mvt, const BlVec2(BendingLightConstants.speedOfLight, 0));
    expect(right.dx, greaterThan(0));
    expect(right.dy.abs(), lessThan(1e-6));
    final up = velocityArrowViewDelta(mvt, const BlVec2(0, BendingLightConstants.speedOfLight));
    expect(up.dy, lessThan(0));
    expect(velocityReadout(BlVec2.zero), '?');
    expect(velocityReadout(const BlVec2(BendingLightConstants.speedOfLight, 0)), '1.00 c');
    expect(protractorOuterRing(const Offset(0, 0), const Offset(10, 0), 10), isTrue);
    expect(protractorOuterRing(const Offset(0, 0), const Offset(5, 0), 10), isFalse);
  });

  test('probe on a ray reads intensity and off-ray is a miss', () {
    final model = MoreToolsModel()..setLaserOn(true);
    model.intensityMeter.enabled = true;
    model.intensityMeter.sensorPosition = const BlVec2(1, 1);
    model.updateModel();
    expect(model.intensityMeter.reading.isMiss, isTrue);
    final incident = model.rays.firstWhere((r) => r.rayType == 'incident');
    model.intensityMeter.sensorPosition = BlVec2(
      (incident.tail.x + incident.tip.x) / 2,
      (incident.tail.y + incident.tip.y) / 2,
    );
    model.updateModel();
    expect(model.intensityMeter.reading.isMiss, isFalse);
    model.setBottomSubstance(Substance.glass);
    expect(model.intensityMeter.reading.value, greaterThanOrEqualTo(0));
  });

  test('vector Snell reports total internal reflection', () {
    final result = VectorSnell.compute(
      L: const BlVec2(0.9, -0.1).normalize(),
      n: const BlVec2(0, 1),
      n1: 1.5,
      n2: 1.0,
    );
    expect(result.totalInternalReflection, isTrue);
    expect(result.transmittedPower, 0);
  });
}
