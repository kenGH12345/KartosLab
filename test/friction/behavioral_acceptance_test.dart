import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/friction/friction_constants.dart';
import 'package:kratos/friction/model/friction_model.dart';

/// Phase 6 behavioral acceptance (model-level black-box).
void main() {
  group('Behavioral acceptance', () {
    late FrictionModel model;

    setUp(() {
      model = FrictionModel(random: math.Random(1));
    });

    test('cold start', () {
      expect(model.vibrationAmplitude, FrictionConstants.vibrationAmplitudeMin);
      expect(model.contact, isFalse);
      expect(model.hint, isTrue);
      expect(model.thermometerFraction, lessThan(0.2));
    });

    test('grab and rub left/right heats and cools', () {
      model.setTopBookPosition(const Offset(0, 30));
      expect(model.contact, isTrue);

      model.moveTopBookBy(const Offset(-200, 0));
      model.moveTopBookBy(const Offset(400, 0));
      model.moveTopBookBy(const Offset(-400, 0));
      final hot = model.vibrationAmplitude;
      expect(hot, greaterThan(2));

      for (var i = 0; i < 120; i++) {
        model.step(1 / 60);
      }
      expect(model.vibrationAmplitude, lessThan(hot));
    });

    test('fast rubbing can shear atoms', () {
      model.setTopBookPosition(const Offset(0, 30));
      for (var i = 0; i < 8; i++) {
        model.moveTopBookBy(Offset(i.isEven ? 600.0 : -600.0, 0));
      }
      expect(model.numberOfAtomsShearedOff, greaterThan(0));
      expect(model.atoms.any((a) => a.isShearedOff), isTrue);
    });

    test('reset after rubbing matches cold start', () {
      model.setTopBookPosition(const Offset(0, 30));
      model.moveTopBookBy(const Offset(500, 0));
      model.step(0.5);
      model.reset();

      expect(model.topBookPosition, Offset.zero);
      expect(model.vibrationAmplitude, FrictionConstants.vibrationAmplitudeMin);
      expect(model.distanceBetweenBooks, FrictionConstants.initialAtomSpacingYBooks);
      expect(model.numberOfAtomsShearedOff, 0);
      expect(model.hint, isTrue);
      expect(model.atoms.every((a) => !a.isShearedOff), isTrue);
      expect(
        model.atoms.every((a) => a.centerPosition == a.initialPosition),
        isTrue,
      );
    });

    test('particles vibrate with amplitude', () {
      model.setTopBookPosition(const Offset(0, 30));
      model.moveTopBookBy(const Offset(300, 0));
      final before = model.atoms.first.position;
      model.step(1 / 60);
      // With amplitude > 1, position almost always differs (random)
      // Allow rare equality by checking multiple atoms
      final moved = model.atoms.take(20).any((a) {
        model.step(1 / 60);
        return a.position != a.centerPosition;
      });
      expect(moved || before != model.atoms.first.position, isTrue);
    });
  });
}
