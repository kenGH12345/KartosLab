import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/faradays_law/faradays_law_constants.dart';
import 'package:kratos/faradays_law/model/magnetic_field.dart';
import 'package:kratos/faradays_law/model/magnet_orientation.dart';

void main() {
  group('magneticFieldAtCoil', () {
    const coil = FaradaysLawConstants.bottomCoilPosition;

    test('default magnet position - NS regression B', () {
      final b = magneticFieldAtCoil(
        coilPosition: coil,
        magnetPosition: FaradaysLawConstants.defaultMagnetPosition,
        orientation: MagnetOrientation.ns,
      );
      expect(b, closeTo(-0.06275922714109236, 1e-12));
    });

    test('SN flips sign at same position', () {
      final ns = magneticFieldAtCoil(
        coilPosition: coil,
        magnetPosition: FaradaysLawConstants.defaultMagnetPosition,
        orientation: MagnetOrientation.ns,
      );
      final sn = magneticFieldAtCoil(
        coilPosition: coil,
        magnetPosition: FaradaysLawConstants.defaultMagnetPosition,
        orientation: MagnetOrientation.sn,
      );
      expect(sn, closeTo(-ns, 1e-12));
      expect(sn, greaterThan(0));
    });

    test('near-field saturation |B| = 2 at coil center', () {
      final b = magneticFieldAtCoil(
        coilPosition: coil,
        magnetPosition: coil,
        orientation: MagnetOrientation.ns,
      );
      expect(b, -2);
    });

    test('near-field for SN at coil center', () {
      final b = magneticFieldAtCoil(
        coilPosition: coil,
        magnetPosition: coil,
        orientation: MagnetOrientation.sn,
      );
      expect(b, 2);
    });

    test('just outside near field uses power law', () {
      final magnet = Offset(coil.dx + 50.1, coil.dy);
      final b = magneticFieldAtCoil(
        coilPosition: coil,
        magnetPosition: magnet,
        orientation: MagnetOrientation.ns,
      );
      expect(b.abs(), lessThan(2));
      expect(b, isNot(0));
    });

    test('farther magnet has smaller |B|', () {
      final near = magneticFieldAtCoil(
        coilPosition: coil,
        magnetPosition: const Offset(500, 310),
        orientation: MagnetOrientation.ns,
      );
      final far = magneticFieldAtCoil(
        coilPosition: coil,
        magnetPosition: const Offset(700, 310),
        orientation: MagnetOrientation.ns,
      );
      expect(near.abs(), greaterThan(far.abs()));
    });
  });
}
