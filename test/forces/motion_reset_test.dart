import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/forces/model/motion_model.dart';

void main() {
  test('motion reset restores stack and dynamics', () {
    final m = MotionModel(MotionScreenStyle.motion);
    m.addToStack(m.catalog.firstWhere((i) => i.id == 'fridge'));
    m.setAppliedForce(200);
    m.step(1);
    m.reset();
    expect(m.stack.single.id, 'crate1');
    expect(m.sim.position, 0);
    expect(m.sim.velocity, 0);
    expect(m.sim.appliedForce, 0);
    expect(m.isPlaying, isTrue);
  });

  test('friction reset restores μ=0.25', () {
    final m = MotionModel(MotionScreenStyle.friction);
    m.setFriction(0.5);
    m.reset();
    expect(m.sim.frictionCoeff, 0.25);
  });

  test('acceleration reset keeps bucket in catalog', () {
    final m = MotionModel(MotionScreenStyle.acceleration);
    m.addToStack(m.catalog.firstWhere((i) => i.id == 'bucket'));
    m.reset();
    expect(m.catalog.any((i) => i.id == 'bucket'), isTrue);
    expect(m.stack.single.id, 'crate1');
  });
}
