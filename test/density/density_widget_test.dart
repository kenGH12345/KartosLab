import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/density/data/density_texture_cache.dart';
import 'package:kratos/density/controller/density_controller.dart';
import 'package:kratos/density/density_strings.dart';
import 'package:kratos/density/model/density_block.dart';
import 'package:kratos/density/model/density_material.dart';
import 'package:kratos/density/model/density_vec.dart';
import 'package:kratos/density/render/density_mvt.dart';
import 'package:kratos/density/solver/buoyancy_world.dart';
import 'package:kratos/density/solver/density_relation.dart';
import 'package:kratos/density/view/screens/compare_screen.dart';
import 'package:kratos/density/view/screens/density_home.dart';
import 'package:kratos/density/view/screens/introduction_screen.dart';
import 'package:kratos/density/view/screens/mystery_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await DensityTextureCache.load();
  });

  test('Intro named materials decode original PhET JPEGs', () {
    expect(
      DensityTextureCache.imageFor(DensityMaterialId.wood),
      isNotNull,
    );
    expect(
      DensityTextureCache.imageForBlock(
        materialId: DensityMaterialId.aluminum,
        colorArgb: null,
      ),
      isNotNull,
    );
    expect(
      DensityTextureCache.imageForBlock(
        materialId: DensityMaterialId.custom,
        colorArgb: 0xFFFF0000,
      ),
      isNull,
    );
  });

  Future<void> setPad(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    await tester.binding.setSurfaceSize(const Size(1024, 768));
    addTearDown(() async {
      tester.view.resetPhysicalSize();
      await tester.binding.setSurfaceSize(null);
    });
  }

  group('pointer drag', () {
    test('down/move/up changes position not volume', () {
      final controller = DensityController();
      const size = Size(1024, 768);
      final mvt = DensityMvt.fit(size);
      final start = controller.intro.blockA;
      final screen = mvt.toScreen(start.position);
      final volume = start.volume;
      controller.pointerDown(screen, mvt);
      expect(controller.grabbedId, start.id);
      controller.pointerMove(screen + const Offset(40, -20), mvt);
      controller.step(1 / 60);
      expect(controller.intro.blockA.volume, volume);
      expect(
        controller.intro.blockA.position.x,
        isNot(closeTo(start.position.x, 1e-6)),
      );
      controller.pointerUp();
      expect(controller.grabbedId, isNull);
    });
  });

  group('buoyancy', () {
    test('styrofoam rises, aluminum sinks in the pool', () {
      final foam = DensityRelation.createWithVolume(
        id: 'foam',
        tag: 'A',
        materialId: DensityMaterialId.styrofoam,
        volume: 0.005,
      ).copyWith(position: const DensityVec(0, -0.2));
      final alum = DensityRelation.createWithVolume(
        id: 'al',
        tag: 'B',
        materialId: DensityMaterialId.aluminum,
        volume: 0.005,
      ).copyWith(position: const DensityVec(0.2, -0.2));
      var blocks = [foam, alum];
      var foamY = foam.position.y;
      var alumY = alum.position.y;
      for (var i = 0; i < 120; i++) {
        final result = BuoyancyWorld.step(blocks: blocks, dt: 1 / 60);
        blocks = result.blocks;
      }
      expect(blocks[0].position.y, greaterThan(foamY));
      expect(blocks[1].position.y, lessThan(alumY));
    });

    test('blocks separate on overlap', () {
      final a = DensityRelation.createWithVolume(
        id: 'a',
        tag: 'A',
        materialId: DensityMaterialId.wood,
        volume: 0.005,
      ).copyWith(position: const DensityVec(0, 0.1));
      final b = DensityRelation.createWithVolume(
        id: 'b',
        tag: 'B',
        materialId: DensityMaterialId.aluminum,
        volume: 0.005,
      ).copyWith(position: const DensityVec(0, 0.1));
      var blocks = [a, b];
      for (var i = 0; i < 5; i++) {
        blocks = BuoyancyWorld.step(blocks: blocks, dt: 1 / 60).blocks;
      }
      expect((blocks[0].position.y - blocks[1].position.y).abs(), greaterThan(0.01));
    });
  });

  testWidgets('DensityHome shows three screen tabs', (tester) async {
    await setPad(tester);
    await tester.pumpWidget(
      const TickerMode(enabled: false, child: MaterialApp(home: DensityHome())),
    );
    await tester.pump();
    expect(find.text(DensityStrings.intro), findsWidgets);
    expect(find.text(DensityStrings.compare), findsOneWidget);
    expect(find.text(DensityStrings.mystery), findsOneWidget);
  });

  testWidgets('Introduction two blocks, material, reset', (tester) async {
    await setPad(tester);
    final controller = DensityController();
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: IntroductionScreen(controller: controller))),
    );
    await tester.pump();
    expect(find.text(DensityStrings.materialName('density.material.wood')),
        findsWidgets);

    await tester.tap(find.byTooltip(DensityStrings.twoBlocks));
    await tester.pump();
    expect(find.text('${DensityStrings.mass} B'), findsOneWidget);

    await tester.tap(find.byTooltip(DensityStrings.resetAll));
    await tester.pump();
    expect(find.text('${DensityStrings.mass} B'), findsNothing);
  });

  testWidgets('Compare same-mass control', (tester) async {
    await setPad(tester);
    final controller = DensityController()..selectScreen(DensityScreenId.compare);
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: CompareScreen(controller: controller))),
    );
    await tester.pump();
    expect(find.text(DensityStrings.sameMass), findsOneWidget);
    await tester.tap(find.text(DensityStrings.sameVolume));
    await tester.pump();
    expect(controller.compare.blockSet, CompareBlockSet.sameVolume);
  });

  testWidgets('Mystery density table expands', (tester) async {
    await setPad(tester);
    final controller = DensityController()..selectScreen(DensityScreenId.mystery);
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: MysteryScreen(controller: controller))),
    );
    await tester.pump();
    expect(find.text(DensityStrings.set1), findsOneWidget);
    await tester.tap(find.text(DensityStrings.densityTable));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(DensityStrings.materialName('density.material.gold')),
        findsOneWidget);
    expect(find.text(DensityStrings.materialName('density.material.wood')),
        findsOneWidget);
  });

  testWidgets('Mystery density table visible at 840x520 viewport', (tester) async {
    tester.view.physicalSize = const Size(840, 520);
    tester.view.devicePixelRatio = 1;
    await tester.binding.setSurfaceSize(const Size(840, 520));
    addTearDown(() async {
      tester.view.resetPhysicalSize();
      await tester.binding.setSurfaceSize(null);
    });

    final controller = DensityController()..selectScreen(DensityScreenId.mystery);
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: MysteryScreen(controller: controller))),
    );
    await tester.pump();
    await tester.tap(find.text(DensityStrings.densityTable));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(DensityStrings.materialName('density.material.gold')),
        findsOneWidget);
    expect(find.text('0.40'), findsOneWidget);
  });
}
