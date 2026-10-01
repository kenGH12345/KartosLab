import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/friction/friction_constants.dart';
import 'package:kratos/friction/model/friction_model.dart';

void main() {
  group('FrictionModel', () {
    late FrictionModel model;

    setUp(() {
      model = FrictionModel(random: math.Random(42));
    });

    test('initial amplitude is min', () {
      expect(model.vibrationAmplitude, FrictionConstants.vibrationAmplitudeMin);
      expect(model.contact, isFalse);
      expect(model.hint, isTrue);
      expect(model.numberOfAtomsShearedOff, 0);
    });

    test('atom counts match PhET structure', () {
      // Top: 30 + 29 + 29 + 24 + 9 = 121; Bottom: 29 + 28 + 29 = 86 → 207
      expect(model.atoms.length, 207);
      expect(FrictionModel.numberOfShearableAtoms, 29 + 29 + 24 + 9);
      expect(model.shearableAtomsByRow.length, 4);
    });

    test('heating requires contact and horizontal motion', () {
      // Drop book onto physics book
      model.setTopBookPosition(const Offset(0, 30));
      expect(model.contact, isTrue);
      final before = model.vibrationAmplitude;

      model.moveTopBookBy(const Offset(100, 0));
      expect(model.vibrationAmplitude, greaterThan(before));
      expect(
        model.vibrationAmplitude,
        closeTo(
          before + 100 * FrictionConstants.heatingMultiplier,
          1e-9,
        ),
      );
    });

    test('macro-style heating can use amplified distance without large motion', () {
      model.setTopBookPosition(const Offset(0, 30));
      final xBefore = model.topBookPosition.dx;
      // Small position delta, large heating distance (book-drag pattern)
      model.moveTopBookBy(const Offset(10, 0), heatingDistanceX: 10 / 0.025);
      expect(model.topBookPosition.dx - xBefore, closeTo(10, 1e-9));
      expect(
        model.vibrationAmplitude,
        closeTo(
          FrictionConstants.vibrationAmplitudeMin +
              400 * FrictionConstants.heatingMultiplier,
          1e-9,
        ),
      );
    });

    test('cooling reduces amplitude over time', () {
      model.setTopBookPosition(const Offset(0, 30));
      model.moveTopBookBy(const Offset(400, 0));
      final hot = model.vibrationAmplitude;
      expect(hot, greaterThan(FrictionConstants.vibrationAmplitudeMin));

      for (var i = 0; i < 60; i++) {
        model.step(1 / 60);
      }
      expect(model.vibrationAmplitude, lessThan(hot));
    });

    test('shear off continues each step while amplitude stays hot', () {
      model.setTopBookPosition(const Offset(0, 30));
      for (var i = 0; i < 4; i++) {
        model.moveTopBookBy(Offset(i.isEven ? 600.0 : -600.0, 0));
      }
      expect(model.vibrationAmplitude, greaterThan(FrictionConstants.amplitudeShearOff));
      final before = model.numberOfAtomsShearedOff;

      // While hot, each step peels another atom (PhET amplitude link).
      for (var i = 0; i < 10; i++) {
        model.step(1 / 60);
      }
      expect(model.numberOfAtomsShearedOff, greaterThan(before));
      expect(model.atoms.where((a) => a.isShearedOff).length, greaterThan(before));
    });

    test('reset restores defaults', () {
      model.setTopBookPosition(const Offset(0, 30));
      model.moveTopBookBy(const Offset(200, 0));
      model.step(0.1);
      model.reset();

      expect(model.topBookPosition, Offset.zero);
      expect(model.vibrationAmplitude, FrictionConstants.vibrationAmplitudeMin);
      expect(model.distanceBetweenBooks, FrictionConstants.initialAtomSpacingYBooks);
      expect(model.numberOfAtomsShearedOff, 0);
      expect(model.hint, isTrue);
      expect(model.atoms.every((a) => !a.isShearedOff), isTrue);
    });

    test('drag bounds clamp X', () {
      model.setTopBookPosition(const Offset(9999, 0));
      expect(model.topBookPosition.dx, FrictionConstants.maxXDisplacement);
    });

    test('thermometer fraction in [0,1]', () {
      expect(model.thermometerFraction, inInclusiveRange(0.0, 1.0));
      model.setTopBookPosition(const Offset(0, 30));
      model.moveTopBookBy(const Offset(1000, 0));
      expect(model.thermometerFraction, inInclusiveRange(0.0, 1.0));
    });
  });
}
