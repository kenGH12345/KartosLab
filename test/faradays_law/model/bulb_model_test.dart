import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/faradays_law/faradays_law_constants.dart';
import 'package:kratos/faradays_law/model/bulb_model.dart';

void main() {
  group('BulbModel', () {
    test('voltage 0 yields brightness 0, halo hidden', () {
      final bulb = BulbModel(voltageGetter: () => 0);
      expect(bulb.haloScale, 0);
      expect(bulb.haloVisible, isFalse);
      expect(bulb.brightness, 0);
    });

    test('positive and negative voltage same brightness', () {
      final pos = BulbModel(voltageGetter: () => 0.5);
      final neg = BulbModel(voltageGetter: () => -0.5);
      expect(pos.haloScale, neg.haloScale);
      expect(pos.brightness, neg.brightness);
      expect(pos.haloVisible, isTrue);
      expect(neg.haloVisible, isTrue);
    });

    test('haloScale = 20 * abs(voltage)', () {
      final bulb = BulbModel(voltageGetter: () => 0.25);
      expect(bulb.haloScale, closeTo(20 * 0.25, 1e-12));
    });

    test('below visibility threshold halo hidden', () {
      final bulb = BulbModel(voltageGetter: () => 0.004);
      expect(
        bulb.haloScale,
        lessThan(FaradaysLawConstants.bulbHaloVisibilityThreshold),
      );
      expect(bulb.haloVisible, isFalse);
      expect(bulb.brightness, 0);
    });

    test('larger abs(voltage) yields larger brightness', () {
      final small = BulbModel(voltageGetter: () => 0.2);
      final large = BulbModel(voltageGetter: () => 1.0);
      expect(large.brightness, greaterThan(small.brightness));
    });
  });
}
