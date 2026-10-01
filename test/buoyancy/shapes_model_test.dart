import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/buoyancy/domain/material/buoyancy_material.dart';
import 'package:kratos/buoyancy/domain/shape/shape_geometry.dart';
import 'package:kratos/buoyancy/domain/world/vec2.dart';
import 'package:kratos/buoyancy/physics/submerged_volume.dart';
import 'package:kratos/buoyancy/shapes/model/buoyancy_shapes_model.dart';
import 'package:kratos/buoyancy/shared/two_block_mode.dart';

void main() {
  group('ShapesModel', () {
    test('catalog order matches MassShape.ts', () {
      expect(kShapesCatalog, [
        MassShapeKind.block,
        MassShapeKind.ellipsoid,
        MassShapeKind.verticalCylinder,
        MassShapeKind.horizontalCylinder,
        MassShapeKind.cone,
        MassShapeKind.invertedCone,
        MassShapeKind.duck,
      ]);
    });

    test('defaults: block wood ratios 0.25/0.75, B hidden', () {
      final m = BuoyancyShapesModel();
      expect(m.objectA.shape, MassShapeKind.block);
      expect(m.objectA.widthRatio, 0.25);
      expect(m.objectA.heightRatio, 0.75);
      expect(m.material.id, 'wood');
      expect(m.objectA.mass.visible, isTrue);
      expect(m.objectB.mass.visible, isFalse);
      expect(m.objectA.mass.position.x, closeTo(-0.225, 1e-9));
      expect(m.objectB.mass.position.x, closeTo(0.075, 1e-9));
    });

    test('all shapes switch changes geometry kind', () {
      final m = BuoyancyShapesModel();
      for (final shape in kShapesCatalog) {
        m.setObjectShape('A', shape);
        expect(m.objectA.shape, shape);
        expect(m.objectA.mass.geometry.kind, shape);
        expect(m.objectA.mass.volume, greaterThan(0));
      }
    });

    test('duck physics uses ellipsoid submerged formula', () {
      final m = BuoyancyShapesModel()..setObjectShape('A', MassShapeKind.duck);
      expect(m.objectA.mass.geometry.kind, MassShapeKind.duck);
      final geom = m.objectA.mass.geometry;
      final bottom = 0.0;
      final top = geom.height;
      final mid = (bottom + top) / 2;
      final vDuck = SubmergedVolume.displacedVolume(
        geometry: geom,
        centerY: mid,
        fluidY: mid,
      );
      final vEllipsoid = SubmergedVolume.displacedVolume(
        geometry: ShapeGeometry.ellipsoid(
          width: geom.width,
          height: geom.height,
          depth: geom.depth,
        ),
        centerY: mid,
        fluidY: mid,
      );
      expect(vDuck, closeTo(vEllipsoid, 1e-12));
      expect(vDuck, closeTo(geom.totalVolume * 0.5, 1e-9));
    });

    test('cone vs invertedCone different submerged volume', () {
      final m = BuoyancyShapesModel();
      m.setObjectShape('A', MassShapeKind.cone);
      final cone = m.objectA.mass.geometry;
      final vCone = SubmergedVolume.displacedVolume(
        geometry: cone,
        centerY: 0,
        fluidY: 0,
      );
      m.setObjectShape('A', MassShapeKind.invertedCone);
      final inv = m.objectA.mass.geometry;
      final vInv = SubmergedVolume.displacedVolume(
        geometry: inv,
        centerY: 0,
        fluidY: 0,
      );
      expect(vCone, isNot(closeTo(vInv, 1e-12)));
    });

    test('vertical vs horizontal cylinder differ', () {
      final m = BuoyancyShapesModel();
      m.setObjectShape('A', MassShapeKind.verticalCylinder);
      final vv = m.objectA.mass.volume;
      m.setObjectShape('A', MassShapeKind.horizontalCylinder);
      expect(m.objectA.mass.volume, isNot(closeTo(vv, 1e-12)));
    });

    test('shape switch changes submerged volume result', () {
      final m = BuoyancyShapesModel();
      m.objectA.mass.position = const BVec2(-0.225, 0);
      m.world.pool.fluidY = 0;
      final vBlock = SubmergedVolume.displacedVolume(
        geometry: m.objectA.mass.geometry,
        centerY: 0,
        fluidY: 0,
      );
      m.setObjectShape('A', MassShapeKind.ellipsoid);
      final vEll = SubmergedVolume.displacedVolume(
        geometry: m.objectA.mass.geometry,
        centerY: m.objectA.mass.position.y,
        fluidY: 0,
      );
      expect(vBlock, isNot(closeTo(vEll, 1e-12)));
    });

    test('shared material propagates to both objects', () {
      final m = BuoyancyShapesModel()
        ..setMode(TwoBlockMode.twoBlocks)
        ..setMaterial(BuoyancyMaterial.aluminum);
      expect(m.objectA.mass.material.id, 'aluminum');
      expect(m.objectB.mass.material.id, 'aluminum');
    });

    test('two-block mode shows B', () {
      final m = BuoyancyShapesModel()..setMode(TwoBlockMode.twoBlocks);
      expect(m.objectB.mass.visible, isTrue);
    });

    test('ratios clamp and resize', () {
      final m = BuoyancyShapesModel();
      final v0 = m.objectA.mass.volume;
      m.setObjectRatios('A', 1, 1);
      expect(m.objectA.mass.volume, greaterThan(v0));
      m.setObjectRatios('A', -1, 2);
      expect(m.objectA.widthRatio, 0);
      expect(m.objectA.heightRatio, 1);
    });

    test('drag', () {
      final m = BuoyancyShapesModel();
      m.startDrag(m.objectA.mass.id, const BVec2(-0.2, 0.1));
      m.endDrag(m.objectA.mass.id);
      expect(m.objectA.mass.userControlled, isFalse);
    });

    test('reset', () {
      final m = BuoyancyShapesModel()
        ..setObjectShape('A', MassShapeKind.duck)
        ..setMaterial(BuoyancyMaterial.brick)
        ..setMode(TwoBlockMode.twoBlocks);
      m.reset();
      expect(m.objectA.shape, MassShapeKind.block);
      expect(m.material.id, 'wood');
      expect(m.mode, TwoBlockMode.oneBlock);
      expect(m.objectB.mass.visible, isFalse);
    });

    test('physics step uses shared world', () {
      final m = BuoyancyShapesModel();
      m.step(1 / 60);
      expect(m.world.clock.simulationTime, greaterThan(0));
    });

    test('determinism', () {
      ShapesModelSnapshot run() {
        final m = BuoyancyShapesModel()..setObjectShape('A', MassShapeKind.cone);
        for (var i = 0; i < 15; i++) {
          m.step(1 / 60);
        }
        return m.snapshot();
      }

      expect(run(), run());
    });
  });
}
