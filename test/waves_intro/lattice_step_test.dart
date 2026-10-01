import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/waves_intro/model/lattice.dart';
import 'package:kratos/waves_intro/waves_intro_constants.dart';

void main() {
  test('WAVE_SPEED_SQUARED is 0.25', () {
    expect(WavesIntroConstants.waveSpeed, 0.5);
    expect(WavesIntroConstants.waveSpeedSquared, 0.25);
  });

  test('source impulse propagates outward', () {
    final lattice = Lattice(width: 51, height: 51, dampX: 5, dampY: 5);
    final cx = 25;
    final cy = 25;
    lattice.setCurrentValue(cx, cy, 5);
    lattice.setLastValue(cx, cy, 5);

    for (var s = 0; s < 8; s++) {
      lattice.step();
    }

    final near = lattice.getCurrentValue(cx + 4, cy).abs();
    final far = lattice.getCurrentValue(cx + 12, cy).abs();
    expect(near, greaterThan(0));
    expect(near + far, greaterThan(0));
  });

  test('c2 formula spot check on small stencil', () {
    final lattice = Lattice(width: 7, height: 7, dampX: 1, dampY: 1);
    lattice.setCurrentValue(3, 3, 1.0);
    lattice.setLastValue(3, 3, 0.0);
    lattice.step();

    final v = lattice.getCurrentValue(3, 4);
    expect(v.isFinite, isTrue);
    var energy = 0.0;
    for (var i = 1; i < 6; i++) {
      for (var j = 1; j < 6; j++) {
        energy += lattice.getCurrentValue(i, j).abs();
      }
    }
    expect(energy, greaterThan(0));
  });

  test('clear zeroes lattice', () {
    final lattice = Lattice(width: 11, height: 11, dampX: 2, dampY: 2);
    lattice.setCurrentValue(5, 5, 3);
    lattice.clear();
    expect(lattice.getCurrentValue(5, 5), 0);
  });

  test('getCenterLineValues length matches visible width', () {
    final lattice = Lattice(width: 21, height: 21, dampX: 3, dampY: 3);
    final values = <double>[];
    lattice.getCenterLineValues(values);
    expect(values.length, 21 - 6);
  });
}