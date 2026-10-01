
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/capacitor_lab_basics/clb_constants.dart';
import 'package:kratos/capacitor_lab_basics/common/model/capacitor.dart';
import 'package:kratos/capacitor_lab_basics/common/model/capacitor_physics.dart';
import 'package:kratos/capacitor_lab_basics/common/transform/plate_separation_drag_handler.dart';
import 'package:kratos/capacitor_lab_basics/common/transform/yaw_pitch_mvt.dart';

void main() {
  group('plate_distance_click_offset_test', () {
    test('grab center / above / below — no jump at pan start', () {
      final mvt = YawPitchMvt();
      const sep0 = ClbConstants.plateSeparationDefault;
      final pOrigin = mvt.modelToViewXYZ(0, -(sep0 / 2), 0);

      // Three grab points: center, above, below relative to virtual origin.
      for (final grabDy in [0.0, -25.0, 25.0]) {
        final pMouse = Offset(100, pOrigin.dy + grabDy);
        final h = PlateSeparationDragHandler(mvt: mvt)
          ..start(pMouse: pMouse, plateSeparation: sep0);
        // Same pointer as start → separation unchanged (no teleport).
        expect(
          h.separationAt(pMouse),
          closeTo(
            CapacitorPhysics.quantizeSeparation(sep0),
            1e-12,
          ),
          reason: 'grabDy=$grabDy must preserve sep at pointer-down',
        );
      }
    });

    test('absolute Y mapping moves separation without delta accumulate', () {
      final mvt = YawPitchMvt();
      const sep0 = 0.006;
      final h = PlateSeparationDragHandler(mvt: mvt);
      final pOrigin = mvt.modelToViewXYZ(0, -(sep0 / 2), 0);
      final p0 = Offset(50, pOrigin.dy);
      h.start(pMouse: p0, plateSeparation: sep0);

      // Move pointer down in view (+Y) → plates closer (smaller sep) in PhET y-down.
      final pDown = Offset(50, pOrigin.dy + 40);
      final sepDown = h.separationAt(pDown);
      expect(sepDown, lessThan(sep0));

      // Move up → larger separation
      final pUp = Offset(50, pOrigin.dy - 40);
      final sepUp = h.separationAt(pUp);
      expect(sepUp, greaterThan(sep0));

      // Same absolute position twice → same result (not cumulative deltas)
      expect(h.separationAt(pDown), sepDown);
    });
  });

  group('plate_distance_drag_bounds_test', () {
    test('clamps to min/max then quantizes', () {
      final mvt = YawPitchMvt();
      final h = PlateSeparationDragHandler(mvt: mvt);
      final sep0 = ClbConstants.plateSeparationDefault;
      final pOrigin = mvt.modelToViewXYZ(0, -(sep0 / 2), 0);
      h.start(pMouse: Offset(0, pOrigin.dy), plateSeparation: sep0);

      final hugeDown = h.separationAt(Offset(0, pOrigin.dy + 5000));
      expect(hugeDown, ClbConstants.plateSeparationMin);

      final hugeUp = h.separationAt(Offset(0, pOrigin.dy - 5000));
      expect(hugeUp, ClbConstants.plateSeparationMax);
    });
  });

  group('plate_distance_drag_reset_test', () {
    test('Capacitor.reset restores default separation', () {
      final c = Capacitor();
      final mvt = YawPitchMvt();
      final h = PlateSeparationDragHandler(mvt: mvt);
      final pOrigin =
          mvt.modelToViewXYZ(0, -(c.plateSeparation / 2), 0);
      h.start(pMouse: Offset(0, pOrigin.dy), plateSeparation: c.plateSeparation);
      c.setPlateSeparation(h.separationAt(Offset(0, pOrigin.dy - 80)));
      expect(c.plateSeparation, isNot(ClbConstants.plateSeparationDefault));
      c.reset();
      expect(c.plateSeparation, ClbConstants.plateSeparationDefault);
    });
  });
}
