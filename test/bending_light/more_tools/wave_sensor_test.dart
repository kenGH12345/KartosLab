import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/model/bl_vec2.dart';
import 'package:kratos/bending_light/model/enums.dart';
import 'package:kratos/bending_light/model/more_tools_model.dart';
import 'package:kratos/bending_light/model/sensors.dart';
import 'package:kratos/bending_light/model/wave_particle.dart';
import 'package:kratos/bending_light/physics/wave_math.dart';

MoreToolsModel _probing() {
  final model = MoreToolsModel()..setLaserOn(true);
  model.setLaserView(LaserViewEnum.wave);
  model.waveSensor.enabled = true;
  final incident = model.rays.firstWhere((r) => r.rayType == 'incident');
  final mid = BlVec2(
    (incident.tail.x + incident.tip.x) / 2,
    (incident.tail.y + incident.tip.y) / 2,
  );
  model.waveSensor.probe1.position = mid;
  model.updateModel();
  return model;
}

void main() {
  test('samples follow the wave model and stop while paused', () {
    final model = _probing();
    final before = model.waveSensor.probe1.series.length;
    model.step();
    expect(model.waveSensor.probe1.series.length, greaterThan(before));
    final sample = model.waveSensor.probe1.series.last;
    final ray = model.rays.firstWhere((r) => r.rayType == 'incident');
    final along = ray.getUnitVector().dot(model.waveSensor.probe1.position - ray.tail);
    final expected = WaveMath.waveMagnitude(
      powerFraction: ray.powerFraction,
      cosArgument: ray.getCosArg(along),
    );
    expect(sample.magnitude, closeTo(expected, 1e-6));
    expect(sample.time, model.time);

    model.togglePlaying();
    final frozen = model.waveSensor.probe1.series.length;
    model.step();
    expect(model.waveSensor.probe1.series.length, frozen);
  });

  test('series length is capped', () {
    final model = _probing();
    for (var i = 0; i < Probe.maxSamples + 30; i++) {
      model.stepOnce();
    }
    expect(model.waveSensor.probe1.series.length, lessThanOrEqualTo(Probe.maxSamples));
  });

  test('wavelength and medium change the particle spacing', () {
    final model = _probing();
    final first = waveParticlesFor(model.rays.first, incident: true);
    expect(first, isNotEmpty);
    final atZero = first.first.position;
    model.step();
    final moved = waveParticlesFor(model.rays.first, incident: true).first.position;
    expect(moved.distance(atZero), greaterThan(0));

    model.setWavelength(450e-9);
    final shorter = waveParticlesFor(model.rays.first, incident: true);
    expect(shorter.first.height, isNot(closeTo(first.first.height, 1e-12)));
  });
}
