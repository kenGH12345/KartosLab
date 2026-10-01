import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/buoyancy/application/application_geometry.dart';
import 'package:kratos/buoyancy/applications/model/application_displacement_tables.dart';
import 'package:kratos/buoyancy/applications/model/buoyancy_applications_model.dart';
import 'package:kratos/buoyancy/domain/material/buoyancy_material.dart';
import 'package:kratos/buoyancy/domain/shape/shape_geometry.dart';
import 'package:kratos/buoyancy/domain/world/vec2.dart';
import 'package:kratos/buoyancy/physics/submerged_volume.dart';
import 'package:kratos/buoyancy/shared/application_mode.dart';

void main() {
  group('ApplicationsModel structure', () {
    test('defaults: bottle mode, interior water 0.004 m³', () {
      final m = BuoyancyApplicationsModel();
      expect(m.applicationMode, ApplicationMode.bottle);
      expect(m.bottle.visible, isTrue);
      expect(m.boat.visible, isFalse);
      expect(m.block.visible, isFalse);
      expect(m.bottleInteriorVolume, 0.004);
      expect(m.bottleInteriorMaterial.id, 'water');
      expect(m.bottle.geometry.kind, MassShapeKind.bottle);
      expect(m.bottle.volume, closeTo(0.01, 1e-12));
    });

    test('bottle density includes empty mass + interior', () {
      final m = BuoyancyApplicationsModel();
      final expected =
          (0.1 + 1000 * 0.004) / 0.01;
      expect(m.bottle.density, closeTo(expected, 1e-6));
    });

    test('switch to boat shows boat+block, hides bottle', () {
      final m = BuoyancyApplicationsModel()
        ..setApplicationMode(ApplicationMode.boat);
      expect(m.boat.visible, isTrue);
      expect(m.block.visible, isTrue);
      expect(m.bottle.visible, isFalse);
      expect(m.boat.geometry.kind, MassShapeKind.boat);
      expect(m.block.material.id, 'brick');
      expect(m.block.volume, closeTo(0.001, 1e-12));
    });

    test('bottle interior material/volume update density', () {
      final m = BuoyancyApplicationsModel()
        ..setBottleInteriorMaterial(BuoyancyMaterial.sand)
        ..setBottleInteriorVolume(0.008);
      final expected =
          (0.1 + BuoyancyMaterial.sand.density * 0.008) / 0.01;
      expect(m.bottle.density, closeTo(expected, 1e-5));
    });

    test('block material/mass/volume APIs', () {
      final m = BuoyancyApplicationsModel()
        ..setApplicationMode(ApplicationMode.boat)
        ..setBlockMaterial(BuoyancyMaterial.aluminum)
        ..setBlockVolume(0.002);
      expect(m.block.material.id, 'aluminum');
      expect(m.block.volume, closeTo(0.002, 1e-12));
    });

    test('resetBoatAndBlockPosition clears basin', () {
      final m = BuoyancyApplicationsModel()
        ..setApplicationMode(ApplicationMode.boat);
      m.boatBasinFluidVolume = 0.002;
      m.boat.containedMass = 2;
      m.resetBoatAndBlockPosition();
      expect(m.boatBasinFluidVolume, 0);
      expect(m.boat.containedMass, 0);
    });

    test('reset restores bottle scene', () {
      final m = BuoyancyApplicationsModel()
        ..setApplicationMode(ApplicationMode.boat)
        ..setBottleInteriorVolume(0.009);
      m.reset();
      expect(m.applicationMode, ApplicationMode.bottle);
      expect(m.bottleInteriorVolume, 0.004);
      expect(m.bottle.visible, isTrue);
      expect(m.boat.visible, isFalse);
    });

    test('drag bottle uses shared DragConstraint', () {
      final m = BuoyancyApplicationsModel();
      m.startDrag(m.bottle.id, const BVec2(0, 0.1));
      m.endDrag(m.bottle.id);
      expect(m.bottle.userControlled, isFalse);
    });

    test('ownership: bottle/block/boat are distinct world masses', () {
      final m = BuoyancyApplicationsModel();
      expect(m.world.masses.length, 3);
      expect(m.world.massById('applications.bottle'), isNotNull);
      expect(m.world.massById('applications.boat'), isNotNull);
      expect(m.world.massById('applications.block'), isNotNull);
    });

    test('determinism bottle scene', () {
      ApplicationsModelSnapshot run() {
        final m = BuoyancyApplicationsModel();
        for (var i = 0; i < 20; i++) {
          m.step(1 / 60);
        }
        return m.snapshot();
      }

      expect(run(), run());
    });
  });

  group('Applications specialized geometry', () {
    test('bottle tables length 1000, max volume 0.01', () {
      expect(ApplicationDisplacementTables.bottleVolumes.length, 1000);
      expect(ApplicationDisplacementTables.bottleVolumes.last, closeTo(0.01, 1e-12));
    });

    test('bottle not a cube: partial submersion uses piecewise', () {
      final geom = PiecewiseApplicationGeometry.bottleTenLiter(
        height: BuoyancyApplicationsModel.bottleHeight,
      ).toShapeGeometry();
      final cube = ShapeGeometry.cubeFromVolume(0.01);
      final vBottle = SubmergedVolume.displacedVolume(
        geometry: geom,
        centerY: 0,
        fluidY: 0,
      );
      final vCube = SubmergedVolume.displacedVolume(
        geometry: cube,
        centerY: 0,
        fluidY: 0,
      );
      expect(vBottle, isNot(closeTo(vCube, 1e-6)));
      expect(geom.kind, MassShapeKind.bottle);
    });

    test('boat scaled tables max volume ≈ 0.01', () {
      final geom = PiecewiseApplicationGeometry.boatScaled(
        displacementVolumeM3: 0.01,
        oneLiterHeight: BuoyancyApplicationsModel.oneLiterBoatHeight,
        hullVolume: BuoyancyApplicationsModel.boatHullVolumeStatic,
      ).toShapeGeometry();
      expect(geom.applicationMaxVolume, closeTo(0.01, 1e-9));
      expect(
        geom.totalVolume,
        closeTo(BuoyancyApplicationsModel.boatHullVolumeStatic, 1e-12),
      );
      expect(geom.kind, MassShapeKind.boat);
    });

    test('boat fully submerged uses applicationMaxVolume', () {
      final m = BuoyancyApplicationsModel()
        ..setApplicationMode(ApplicationMode.boat);
      m.boat.position = const BVec2(0.08, -1);
      final v = SubmergedVolume.displacedVolume(
        geometry: m.boat.geometry,
        centerY: m.boat.position.y,
        fluidY: 0,
      );
      expect(v, closeTo(m.boat.geometry.applicationMaxVolume, 1e-9));
    });

    test('boat basin state is separate from pool', () {
      final m = BuoyancyApplicationsModel()
        ..setApplicationMode(ApplicationMode.boat);
      final pool0 = m.world.pool.fluidVolume;
      m.boatBasinFluidVolume = 0.001;
      expect(m.world.pool.fluidVolume, pool0);
      expect(m.boatBasinFluidVolume, 0.001);
    });
  });
}
