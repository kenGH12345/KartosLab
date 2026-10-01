import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/buoyancy/applications/composer/applications_composer.dart';
import 'package:kratos/buoyancy/applications/model/boat_basin.dart';
import 'package:kratos/buoyancy/applications/model/buoyancy_applications_model.dart';
import 'package:kratos/buoyancy/domain/world/vec2.dart';
import 'package:kratos/buoyancy/physics/constants.dart';
import 'package:kratos/buoyancy/shared/application_mode.dart';

void main() {
  group('PHASE 6 boat cabin coupling', () {
    test('composer flag RESOLVED', () {
      expect(ApplicationsComposer.cabinBasinCoupling, 'RESOLVED');
    });

    test('basin step extents track boat pose', () {
      final m = BuoyancyApplicationsModel()..pause();
      m.setApplicationMode(ApplicationMode.boat);
      m.boat.position = const BVec2(0.1, -0.05);
      m.boatBasin.updateStepFromBoat(
        boat: m.boat,
        displacementVolumeM3:
            BuoyancyApplicationsModel.defaultDisplacementVolume,
      );
      final top = m.boatBasin.boatStepTop(
        m.boat,
        BuoyancyApplicationsModel.defaultDisplacementVolume,
      );
      final bottom = m.boatBasin.boatStepBottom(
        m.boat,
        BuoyancyApplicationsModel.defaultDisplacementVolume,
      );
      expect(top, greaterThan(bottom));
      expect(top, closeTo(m.boatBasin.stepTop, 1e-9));
    });

    test('cabin empty → fluidY at interior bottom', () {
      final basin = BoatBasin();
      basin.stepBottom = -0.1;
      basin.stepTop = 0.05;
      basin.fluidVolume = 0;
      basin.computeY();
      expect(basin.fluidY, -0.1);
    });

    test('cabin water present → fluidY between bottom and top', () {
      final m = BuoyancyApplicationsModel()..pause();
      m.setApplicationMode(ApplicationMode.boat);
      m.setBoatBasinFluidVolume(0.002);
      expect(m.boatBasin.fluidVolume, closeTo(0.002, 1e-12));
      expect(m.boatBasin.fluidY, greaterThan(m.boatBasin.stepBottom));
      expect(m.boatBasin.fluidY, lessThanOrEqualTo(m.boatBasin.stepTop));
      expect(m.boat.containedMass, greaterThan(0));
    });

    test('boat high with cabin water → spilling drains toward pool', () {
      final m = BuoyancyApplicationsModel()..pause();
      m.setApplicationMode(ApplicationMode.boat);
      m.setBoatBasinFluidVolume(0.003);
      final cabinBefore = m.boatBasin.fluidVolume;
      final poolBefore = m.world.pool.fluidVolume;
      final high = BVec2(
        m.boat.position.x,
        m.world.pool.fluidY + m.boat.geometry.height * 2.5,
      );
      // Hold boat high each frame so spill threshold stays armed.
      for (var i = 0; i < 60; i++) {
        m.boat.position = high;
        m.boat.velocity = BVec2.zero;
        m.resume();
        m.step(1 / 60);
        m.pause();
      }
      expect(m.boatBasin.fluidVolume, lessThan(cabinBefore));
      expect(m.world.pool.fluidVolume, greaterThan(poolBefore));
    });

    test('boat low / partially submerged keeps basin extents under waterline',
        () {
      final m = BuoyancyApplicationsModel()..pause();
      m.setApplicationMode(ApplicationMode.boat);
      m.boat.position = const BVec2(0.08, -0.25);
      m.boatBasin.updateStepFromBoat(
        boat: m.boat,
        displacementVolumeM3:
            BuoyancyApplicationsModel.defaultDisplacementVolume,
      );
      expect(
        m.boatBasin.stepTop,
        lessThan(m.world.pool.maxY + BuoyancyPhysicsConstants.slip),
      );
    });

    test('reset clears cabin fluid', () {
      final m = BuoyancyApplicationsModel()..pause();
      m.setApplicationMode(ApplicationMode.boat);
      m.setBoatBasinFluidVolume(0.004);
      m.reset();
      expect(m.applicationMode, ApplicationMode.bottle);
      expect(m.boatBasin.fluidVolume, 0);
      expect(m.boat.containedMass, 0);
    });

    test('compose exposes cabinFluidY when cabin has water', () {
      final m = BuoyancyApplicationsModel()..pause();
      m.setApplicationMode(ApplicationMode.boat);
      m.setBoatBasinFluidVolume(0.002);
      final scene = ApplicationsComposer().compose(m);
      expect(scene.cabinFluidY, isNotNull);
      expect(scene.cabinFluidY, closeTo(m.boatBasin.fluidY, 1e-9));
      expect(scene.cabinCouplingDeferred, isFalse);
    });

    test('determinism ×3 cabin transfer state', () {
      ApplicationsModelSnapshot run() {
        final m = BuoyancyApplicationsModel();
        m.setApplicationMode(ApplicationMode.boat);
        m.setBoatBasinFluidVolume(0.0025);
        m.boat.position = const BVec2(0.08, -0.12);
        for (var i = 0; i < 40; i++) {
          m.step(1 / 60);
        }
        return m.snapshot();
      }

      final a = run();
      final b = run();
      final c = run();
      expect(a, b);
      expect(b, c);
    });
  });

  group('PHASE 6 p2 fidelity gates', () {
    test('velocityCap 5 is source DensityBuoyancyModel clamp', () {
      expect(BuoyancyPhysicsConstants.velocityCap, 5);
    });

    test('fixed timestep / maxSubSteps match query defaults', () {
      expect(BuoyancyPhysicsConstants.fixedTimeStep, closeTo(1 / 120, 1e-15));
      expect(BuoyancyPhysicsConstants.maxSubSteps, 30);
    });

    test('pointer maxForce = 0*m + 2500', () {
      expect(BuoyancyPhysicsConstants.pointerBaseForce, 2500);
      expect(BuoyancyPhysicsConstants.pointerMassForce, 0);
    });
  });
}
