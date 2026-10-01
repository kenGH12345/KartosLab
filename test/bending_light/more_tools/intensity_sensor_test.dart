import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/model/bl_vec2.dart';
import 'package:kratos/bending_light/model/intro_model.dart';
import 'package:kratos/bending_light/model/substance.dart';
import 'package:kratos/bending_light/physics/sensor_intersection.dart';

void main() {
  test('a ray through the sensor circle has two hits', () {
    final hits = rayCircleHits(
      origin: BlVec2.zero,
      directionAngle: 0,
      center: const BlVec2(2, 0),
      radius: 1,
    );
    expect(hits.length, 2);
    final sample = sensorSamplePoint(hits)!;
    expect(sample.x, closeTo(2, 1e-9));
  });

  test('a tangent ray has one hit and a miss has none', () {
    final tangent = rayCircleHits(
      origin: const BlVec2(0, 1),
      directionAngle: 0,
      center: const BlVec2(2, 0),
      radius: 1,
    );
    expect(tangent.length, 1);
    final miss = rayCircleHits(
      origin: const BlVec2(0, 3),
      directionAngle: 0,
      center: const BlVec2(2, 0),
      radius: 1,
    );
    expect(miss, isEmpty);
    expect(sensorSamplePoint(miss), isNull);
  });

  test('intensity readout is a hit on the beam and a miss off it', () {
    final model = IntroModel(
      bottomSubstance: Substance.water,
      horizontalPlayAreaOffset: true,
    )..setLaserOn(true);
    model.intensityMeter.enabled = true;
    model.intensityMeter.sensorPosition = const BlVec2(1e-3, 1e-3);
    model.updateModel();
    expect(model.intensityMeter.reading.isMiss, isTrue);

    final incident = model.rays.firstWhere((r) => r.rayType == 'incident');
    model.intensityMeter.sensorPosition = BlVec2(
      (incident.tail.x + incident.tip.x) / 2,
      (incident.tail.y + incident.tip.y) / 2,
    );
    model.updateModel();
    expect(model.intensityMeter.reading.isMiss, isFalse);
    expect(model.intensityMeter.reading.value, greaterThan(0));
  });
}
