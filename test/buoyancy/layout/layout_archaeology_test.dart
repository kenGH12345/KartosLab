import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/buoyancy/domain/shape/shape_geometry.dart';
import 'package:kratos/buoyancy/layout/buoyancy_applications_layout_spec.dart';
import 'package:kratos/buoyancy/layout/buoyancy_compare_layout_spec.dart';
import 'package:kratos/buoyancy/layout/buoyancy_explore_layout_spec.dart';
import 'package:kratos/buoyancy/layout/buoyancy_global_layout_spec.dart';
import 'package:kratos/buoyancy/layout/buoyancy_lab_layout_spec.dart';
import 'package:kratos/buoyancy/layout/buoyancy_shapes_layout_spec.dart';

void main() {
  group('PHASE 2A Global', () {
    const g = BuoyancyGlobalLayoutSpec();

    test('design bounds 1024×618', () {
      expect(g.designWidth, 1024);
      expect(g.designHeight, 618);
    });

    test('uniform scale is min(sx,sy) and centered', () {
      final wide = g.designFrame(const Size(1280, 800));
      expect(wide.scale, closeTo(1280 / 1024, 1e-12));
      expect(wide.origin.dx, closeTo(0, 1e-9));
      expect(wide.origin.dy, greaterThan(0)); // letterbox
      final narrow = g.designFrame(const Size(800, 600));
      expect(narrow.scale, closeTo(800 / 1024, 1e-12));
      expect(narrow.origin.dx, closeTo(0, 1e-9));
      expect(narrow.origin.dy, greaterThan(0));
      final squat = g.designFrame(const Size(1200, 500));
      expect(squat.scale, closeTo(500 / 618, 1e-12));
      expect(squat.origin.dy, closeTo(0, 1e-9));
      expect(squat.origin.dx, greaterThan(0)); // pillarbox
    });

    test('insets use MARGIN_SMALL=5', () {
      expect(g.contentInsets.left, 5);
      expect(g.contentInsets.bottom, 5);
    });

    test('MVT contract is THREE not 2D scale', () {
      const mvt = BuoyancyMvtContract();
      expect(mvt.productionIsTwoDimensionalScale, isFalse);
      expect(mvt.defaultCameraZoom, closeTo(1.75 * 3.5, 1e-12));
      expect(mvt.buoyancyLookAt.y, -0.18);
      expect(mvt.compareLookAt.y, -0.1);
      expect(mvt.compareViewOffset.dx, -25);
    });

    test('design↔viewport roundtrip', () {
      final frame = g.designFrame(const Size(1024, 618));
      final p = const Offset(512, 309);
      expect(frame.viewportToDesign(frame.designToViewport(p)).dx,
          closeTo(p.dx, 1e-9));
    });

    test('determinism: same viewport → same frame', () {
      final a = g.designFrame(const Size(1280, 800));
      final b = g.designFrame(const Size(1280, 800));
      expect(a.scale, b.scale);
      expect(a.origin, b.origin);
    });
  });

  group('PHASE 2B Compare/Explore/Lab', () {
    test('Compare never freezes block Y in design pixels', () {
      const s = BuoyancyCompareLayoutSpec();
      for (final o in s.dynamicObjects) {
        if (o.id.startsWith('block')) {
          expect(o.coordinateSpace, BuoyancyCoordinateSpace.modelMeters);
          expect(o.driver, BuoyancyGeometryDriver.physicsDriven);
        }
      }
      expect(s.cameraLookAt.y, -0.1);
      expect(s.viewOffset.dx, -25);
      expect(s.rightSideMaxContentWidthSeed, 512);
    });

    test('Explore B visibility is visibility-false semantics', () {
      const s = BuoyancyExploreLayoutSpec();
      expect(s.blockBVisibilitySemantics.contains('visibility false'), isTrue);
      expect(s.alignBoxModules.any((m) => m.id == 'rightSideVBox'), isTrue);
    });

    test('Lab force mapping uses ×20 units/N', () {
      const s = BuoyancyLabLayoutSpec();
      expect(s.forcesInitiallyDisplayed, isTrue);
      expect(s.forceArrowUnitsPerNewton, 20);
      final arrows =
          s.dynamicObjects.firstWhere((o) => o.id == 'forceArrows');
      expect(arrows.driver, BuoyancyGeometryDriver.modelDriven);
    });

    test('responsive frames for three screens share global scale', () {
      const g = BuoyancyGlobalLayoutSpec();
      for (final size in [
        const Size(1024, 618),
        const Size(1280, 800),
        const Size(800, 600),
      ]) {
        final f = g.designFrame(size);
        expect(f.scale, greaterThan(0));
        expect(f.contentBounds.width, closeTo(1024 * f.scale, 1e-9));
      }
    });
  });

  group('PHASE 2C Shapes/Applications', () {
    test('Shapes catalog order + duck visual vs physics', () {
      const s = BuoyancyShapesLayoutSpec();
      expect(s.shapeCatalogOrder.length, 7);
      expect(s.shapeCatalogOrder.last, MassShapeKind.duck);
      expect(s.duckGeometry.visual.toLowerCase().contains('duck'), isTrue);
      expect(s.duckGeometry.physics.toLowerCase().contains('ellipsoid'), isTrue);
      expect(s.duckGeometry.mapping.contains('different mesh'), isTrue);
      expect(s.initialForceScale, 1 / 4);
    });

    test('cylinder orientations not rotate-90 hacks', () {
      const s = BuoyancyShapesLayoutSpec();
      final h = s.shapeVisualPhysics
          .firstWhere((p) => p.objectId == 'horizontalCylinder');
      expect(h.mapping.contains('not rotate-90'), isTrue);
    });

    test('Applications boat/bottle not cubes; basin RESOLVED', () {
      const s = BuoyancyApplicationsLayoutSpec();
      expect(s.boatCabinBasinStatus.contains('RESOLVED'), isTrue);
      for (final m in s.applicationMeshes) {
        if (m.objectId == 'bottle' || m.objectId == 'boat') {
          expect(m.mapping.contains('not a cube'), isTrue);
        }
      }
      expect(
        s.dynamicObjects
            .any((o) => o.id == 'poolWaterline' && o.note.contains('Never fixed')),
        isTrue,
      );
      expect(s.usesSameThreeMvtAsOtherBuoyancyScreens, isTrue);
    });
  });
}
