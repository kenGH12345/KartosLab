import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/faradays_law/faradays_law_constants.dart';
import 'package:kratos/faradays_law/model/magnet.dart';
import 'package:kratos/faradays_law/model/magnet_orientation.dart';

void main() {
  group('Magnet', () {
    test('initial state matches source defaults', () {
      final magnet = Magnet();
      expect(magnet.position, FaradaysLawConstants.defaultMagnetPosition);
      expect(magnet.orientation, MagnetOrientation.ns);
      expect(magnet.fieldLinesVisible, isFalse);
      expect(magnet.isDragging, isFalse);
      expect(magnet.width, 140);
      expect(magnet.height, 30);
    });

    test('flipPolarity NS to SN to NS', () {
      final magnet = Magnet();
      magnet.flipPolarity();
      expect(magnet.orientation, MagnetOrientation.sn);
      magnet.flipPolarity();
      expect(magnet.orientation, MagnetOrientation.ns);
    });

    test('reset restores defaults after mutation', () {
      final magnet = Magnet()
        ..setPosition(const Offset(100, 100))
        ..orientation = MagnetOrientation.sn
        ..fieldLinesVisible = true
        ..isDragging = true;
      magnet.reset();
      expect(magnet.position, FaradaysLawConstants.defaultMagnetPosition);
      expect(magnet.orientation, MagnetOrientation.ns);
      expect(magnet.fieldLinesVisible, isFalse);
      expect(magnet.isDragging, isFalse);
    });

    test('bounds centered on position', () {
      final magnet = Magnet()..setPosition(const Offset(200, 150));
      expect(magnet.bounds.left, 200 - 70);
      expect(magnet.bounds.right, 200 + 70);
      expect(magnet.bounds.top, 150 - 15);
      expect(magnet.bounds.bottom, 150 + 15);
    });

    test('magneticFieldSign for NS and SN', () {
      expect(MagnetOrientation.ns.magneticFieldSign, -1);
      expect(MagnetOrientation.sn.magneticFieldSign, 1);
    });
  });
}
