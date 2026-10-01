import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_act/balancing_act.dart';

void main() {
  group('Snap grid', () {
    late BalanceModel model;
    late Plank plank;

    setUp(() {
      model = BalanceModel();
      plank = model.plank;
    });

    test('NUM_SNAP and spacing', () {
      expect(BaGeometry.numSnapToPositions, 17);
      expect(BaGeometry.interSnapToMarkerDistance, 0.25);
      final snaps = plank.getSnapToPositions();
      expect(snaps.length, 17);
      expect(snaps.first.x, closeTo(-2.0, 1e-12));
      expect(snaps.last.x, closeTo(2.0, 1e-12));
      expect(snaps[8].x, closeTo(0.0, 1e-12));
    });

    test('center slot not available; drop at 0 snaps to +/-0.25', () {
      final open = plank.getOpenMassDroppedPosition(const BaVector2(0, 0.9));
      expect(open, isNotNull);
      expect(open!.x.abs(), closeTo(0.25, 1e-12));
    });

    test('exact 0.25 / 0.5 / -0.25 snap', () {
      for (final x in [0.25, 0.5, -0.25, -0.5, 1.0, 2.0, -2.0]) {
        final open = plank.getOpenMassDroppedPosition(BaVector2(x, 0.9));
        expect(open, isNotNull, reason: 'x=$x');
        expect(open!.x, closeTo(x, 1e-12));
      }
    });

    test('midpoint between slots snaps within 0.25', () {
      final open =
          plank.getOpenMassDroppedPosition(const BaVector2(0.125, 0.9));
      expect(open!.x, closeTo(0.25, 1e-12));
    });

    test('too far horizontally rejected', () {
      expect(
        plank.getOpenMassDroppedPosition(const BaVector2(10, 0.9)),
        isNull,
      );
    });

    test('occupied slot skipped; neighbor accepted', () {
      final a = BaMass.generic(5, const BaVector2(0, 0));
      plank.addMassToSurfaceAt(a, 0.25);
      final open = plank.getOpenMassDroppedPosition(const BaVector2(0.25, 0.9));
      expect(open!.x, closeTo(0.5, 1e-12));
      final open2 = plank.getOpenMassDroppedPosition(const BaVector2(0.5, 0.9));
      expect(open2!.x, closeTo(0.5, 1e-12));
    });

    test('addMassToSurface snaps and sets signed distance', () {
      final mass = BaMass.generic(5, const BaVector2(0.27, 0.9), height: 0.1);
      expect(plank.addMassToSurface(mass), isTrue);
      expect(mass.position.x, closeTo(0.25, 1e-12));
      expect(mass.onPlank, isTrue);
      expect(plank.getMassDistanceFromCenter(mass), closeTo(0.25, 1e-12));
    });
  });
}
