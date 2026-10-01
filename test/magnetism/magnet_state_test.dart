import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/magnetism/magnet_and_compass/model/magnet_state.dart';

/// B `initState` 默认值（位置在首帧 layout 前为 Offset.zero）。
MagnetState bInitDefaults() => MagnetState(
      magnetPos: Offset.zero,
      magnetAngle: 0,
      strength: 0.75,
      flipped: false,
      showField: true,
      seeInside: false,
      earthField: false,
      showCompass: true,
      showFieldMeter: false,
      compassPos: Offset.zero,
      compassAngle: 0,
      fieldMeterPos: Offset.zero,
    );

void main() {
  group('MagnetState defaults', () {
    test('matches B initState field values', () {
      final s = bInitDefaults();
      expect(s.magnetPos, Offset.zero);
      expect(s.magnetAngle, 0);
      expect(s.strength, 0.75);
      expect(s.flipped, isFalse);
      expect(s.showField, isTrue);
      expect(s.seeInside, isFalse);
      expect(s.earthField, isFalse);
      expect(s.showCompass, isTrue);
      expect(s.showFieldMeter, isFalse);
      expect(s.compassPos, Offset.zero);
      expect(s.compassAngle, 0);
      expect(s.fieldMeterPos, Offset.zero);
    });
  });

  group('MagnetState copyWith', () {
    test('single-field replace does not pollute other fields', () {
      final original = bInitDefaults();
      final next = original.copyWith(strength: 0.2);

      expect(next.strength, 0.2);
      expect(original.strength, 0.75);
      expect(next.magnetPos, original.magnetPos);
      expect(next.magnetAngle, original.magnetAngle);
      expect(next.flipped, original.flipped);
      expect(next.showField, original.showField);
      expect(next.seeInside, original.seeInside);
      expect(next.earthField, original.earthField);
      expect(next.showCompass, original.showCompass);
      expect(next.showFieldMeter, original.showFieldMeter);
      expect(next.compassPos, original.compassPos);
      expect(next.compassAngle, original.compassAngle);
      expect(next.fieldMeterPos, original.fieldMeterPos);
    });

    test('multi-field replace', () {
      final next = bInitDefaults().copyWith(
        magnetPos: const Offset(10, 20),
        magnetAngle: 0.5,
        compassAngle: 1.2,
        earthField: true,
        flipped: true,
      );
      expect(next.magnetPos, const Offset(10, 20));
      expect(next.magnetAngle, 0.5);
      expect(next.compassAngle, 1.2);
      expect(next.earthField, isTrue);
      expect(next.flipped, isTrue);
      expect(next.strength, 0.75);
      expect(next.showCompass, isTrue);
    });
  });

  group('MagnetState mutation', () {
    test('public fields are mutable in place', () {
      final s = bInitDefaults();
      s.magnetPos = const Offset(42, 84);
      s.magnetAngle = 1.1;
      s.compassAngle = -0.3;
      s.earthField = true;
      s.strength = 0.4;
      s.flipped = true;
      s.showField = false;
      s.seeInside = true;
      s.showCompass = false;
      s.showFieldMeter = true;
      s.compassPos = const Offset(3, 4);
      s.fieldMeterPos = const Offset(5, 6);

      expect(s.magnetPos, const Offset(42, 84));
      expect(s.magnetAngle, 1.1);
      expect(s.compassAngle, -0.3);
      expect(s.earthField, isTrue);
      expect(s.strength, 0.4);
      expect(s.flipped, isTrue);
      expect(s.showField, isFalse);
      expect(s.seeInside, isTrue);
      expect(s.showCompass, isFalse);
      expect(s.showFieldMeter, isTrue);
      expect(s.compassPos, const Offset(3, 4));
      expect(s.fieldMeterPos, const Offset(5, 6));
    });
  });
}
