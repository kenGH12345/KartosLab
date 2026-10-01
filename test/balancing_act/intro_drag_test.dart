import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_act/balancing_act.dart';

void main() {
  test('Intro controller drag continuous then snap on release', () {
    final c = BaIntroController();
    final mass = c.model.fireExtinguisher1;
    final start = c.mvt.modelToView(mass.position);
    c.beginDrag(mass, start);
    expect(mass.userControlled, isTrue);

    final mid = c.mvt.modelToView(const BaVector2(0.37, 1.0));
    c.updateDrag(mid);
    expect(mass.position.x, closeTo(0.37, 0.05)); // continuous-ish
    expect(mass.onPlank, isFalse);

    final overSlot = c.mvt.modelToView(const BaVector2(1.0, 0.9));
    c.updateDrag(overSlot);
    c.endDrag();
    expect(mass.onPlank, isTrue);
    expect(mass.position.x, closeTo(1.0, 1e-9));
    c.dispose();
  });

  test('Occupied slot uses model filtering', () {
    final c = BaIntroController();
    final a = c.model.fireExtinguisher1;
    final b = c.model.fireExtinguisher2;

    c.beginDrag(a, c.mvt.modelToView(a.position));
    c.updateDrag(c.mvt.modelToView(const BaVector2(0.25, 0.9)));
    c.endDrag();
    expect(a.onPlank, isTrue);

    c.beginDrag(b, c.mvt.modelToView(b.position));
    c.updateDrag(c.mvt.modelToView(const BaVector2(0.25, 0.9)));
    c.endDrag();
    // Occupied → neighbor 0.5 or miss to ground
    if (b.onPlank) {
      expect(b.position.x, isNot(closeTo(0.25, 1e-9)));
    } else {
      expect(b.position.y, 0);
    }
    c.dispose();
  });

  test('Supports off allows plank tilt from imbalance', () {
    final c = BaIntroController();
    final mass = c.model.fireExtinguisher1;
    c.beginDrag(mass, c.mvt.modelToView(mass.position));
    c.updateDrag(c.mvt.modelToView(const BaVector2(1.5, 0.9)));
    c.endDrag();
    c.setSupportsEnabled(false);
    for (var i = 0; i < 30; i++) {
      c.model.step(1 / 60);
    }
    expect(c.model.plank.tiltAngle.abs(), greaterThan(0));
    expect(c.model.plank.isBalanced(), isFalse);
    c.dispose();
  });
}
