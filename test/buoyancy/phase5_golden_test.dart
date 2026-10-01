/// PHASE 5 Flutter–Flutter golden determinism gate.
///
/// Source-screenshot pixel delta requires user-provided PhET captures
/// (not attached in this turn). These goldens lock Flutter render stability
/// at 1024×618 design framing with models paused (no ticker drift).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/buoyancy/applications/model/buoyancy_applications_model.dart';
import 'package:kratos/buoyancy/applications/view/buoyancy_applications_screen.dart';
import 'package:kratos/buoyancy/compare/model/buoyancy_compare_model.dart';
import 'package:kratos/buoyancy/compare/view/buoyancy_compare_screen.dart';
import 'package:kratos/buoyancy/domain/material/buoyancy_gravity.dart';
import 'package:kratos/buoyancy/domain/material/buoyancy_material.dart';
import 'package:kratos/buoyancy/domain/shape/shape_geometry.dart';
import 'package:kratos/buoyancy/domain/world/vec2.dart';
import 'package:kratos/buoyancy/explore/model/buoyancy_explore_model.dart';
import 'package:kratos/buoyancy/explore/view/buoyancy_explore_screen.dart';
import 'package:kratos/buoyancy/lab/model/buoyancy_lab_model.dart';
import 'package:kratos/buoyancy/lab/view/buoyancy_lab_screen.dart';
import 'package:kratos/buoyancy/shapes/model/buoyancy_shapes_model.dart';
import 'package:kratos/buoyancy/shapes/view/buoyancy_shapes_screen.dart';
import 'package:kratos/buoyancy/shared/application_mode.dart';
import 'package:kratos/buoyancy/shared/compare_block_set.dart';
import 'package:kratos/buoyancy/shared/two_block_mode.dart';

const _vp = Size(1024, 618);

Future<void> _pumpPaused(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = _vp;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.binding.setSurfaceSize(_vp);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MediaQuery(
        data: const MediaQueryData(size: _vp),
        child: child,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 16));
}

Future<void> _golden(WidgetTester tester, String name) async {
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Compare default', (tester) async {
    final m = BuoyancyCompareModel()..pause();
    await _pumpPaused(tester, BuoyancyCompareScreen(model: m));
    await _golden(tester, 'compare_default_1024x618');
  });

  testWidgets('Compare after mode sameVolume', (tester) async {
    final m = BuoyancyCompareModel()..pause();
    m.setComparisonMode(CompareBlockSet.sameVolume);
    await _pumpPaused(tester, BuoyancyCompareScreen(model: m));
    await _golden(tester, 'compare_same_volume_1024x618');
  });

  testWidgets('Compare after reset', (tester) async {
    final m = BuoyancyCompareModel()..pause();
    m.setSameMass(9);
    m.reset();
    m.pause();
    await _pumpPaused(tester, BuoyancyCompareScreen(model: m));
    await _golden(tester, 'compare_reset_1024x618');
  });

  testWidgets('Explore default', (tester) async {
    final m = BuoyancyExploreModel()..pause();
    await _pumpPaused(tester, BuoyancyExploreScreen(model: m));
    await _golden(tester, 'explore_default_1024x618');
  });

  testWidgets('Explore two blocks', (tester) async {
    final m = BuoyancyExploreModel()..pause();
    m.setMode(TwoBlockMode.twoBlocks);
    await _pumpPaused(tester, BuoyancyExploreScreen(model: m));
    await _golden(tester, 'explore_two_blocks_1024x618');
  });

  testWidgets('Explore aluminum submerged pose', (tester) async {
    final m = BuoyancyExploreModel()..pause();
    m.setBlockMaterial('explore.blockA', BuoyancyMaterial.aluminum);
    m.blockA.position = const BVec2(-0.2, -0.15);
    m.world.pool.computeFluidY([m.blockA]);
    await _pumpPaused(tester, BuoyancyExploreScreen(model: m));
    await _golden(tester, 'explore_aluminum_low_1024x618');
  });

  testWidgets('Lab default', (tester) async {
    final m = BuoyancyLabModel()..pause();
    await _pumpPaused(tester, BuoyancyLabScreen(model: m));
    await _golden(tester, 'lab_default_1024x618');
  });

  testWidgets('Lab moon gravity', (tester) async {
    final m = BuoyancyLabModel()..pause();
    m.setSelectedGravityPreset(BuoyancyGravity.moon);
    await _pumpPaused(tester, BuoyancyLabScreen(model: m));
    await _golden(tester, 'lab_moon_1024x618');
  });

  testWidgets('Shapes default block', (tester) async {
    final m = BuoyancyShapesModel()..pause();
    await _pumpPaused(tester, BuoyancyShapesScreen(model: m));
    await _golden(tester, 'shapes_block_1024x618');
  });

  testWidgets('Shapes duck', (tester) async {
    final m = BuoyancyShapesModel()..pause();
    m.setObjectShape('A', MassShapeKind.duck);
    await _pumpPaused(tester, BuoyancyShapesScreen(model: m));
    await _golden(tester, 'shapes_duck_1024x618');
  });

  testWidgets('Shapes ellipsoid', (tester) async {
    final m = BuoyancyShapesModel()..pause();
    m.setObjectShape('A', MassShapeKind.ellipsoid);
    await _pumpPaused(tester, BuoyancyShapesScreen(model: m));
    await _golden(tester, 'shapes_ellipsoid_1024x618');
  });

  testWidgets('Applications bottle default', (tester) async {
    final m = BuoyancyApplicationsModel()..pause();
    await _pumpPaused(tester, BuoyancyApplicationsScreen(model: m));
    await _golden(tester, 'applications_bottle_1024x618');
  });

  testWidgets('Applications boat', (tester) async {
    final m = BuoyancyApplicationsModel()..pause();
    m.setApplicationMode(ApplicationMode.boat);
    await _pumpPaused(tester, BuoyancyApplicationsScreen(model: m));
    await _golden(tester, 'applications_boat_1024x618');
  });
}
