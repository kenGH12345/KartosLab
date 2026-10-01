import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/model/enums.dart';
import 'package:kratos/bending_light/model/more_tools_model.dart';
import 'package:kratos/bending_light/model/wave_particle.dart';

void main() {
  test('particle positions come from phase, not a fixed offset', () {
    final model = MoreToolsModel()
      ..setLaserOn(true)
      ..setLaserView(LaserViewEnum.wave);
    final ray = model.rays.first;
    final a = waveParticlesFor(ray, incident: true).first.position;
    model.step();
    final b = waveParticlesFor(model.rays.first, incident: true).first.position;
    expect(b.x, isNot(a.x));
    expect(waveParticlesFor(model.rays.first, incident: true).length, lessThanOrEqualTo(151));
  });
}
