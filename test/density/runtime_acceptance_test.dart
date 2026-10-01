import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/density/controller/density_controller.dart';
import 'package:kratos/density/data/density_texture_cache.dart';
import 'package:kratos/density/data/mystery_sets.dart';
import 'package:kratos/density/model/density_block.dart';
import 'package:kratos/density/model/density_material.dart';
import 'package:kratos/density/model/density_vec.dart';
import 'package:kratos/density/render/density_mvt.dart';
import 'package:kratos/density/solver/buoyancy_world.dart';
import 'package:kratos/density/solver/compare_constraint.dart';
import 'package:kratos/density/solver/density_relation.dart';
import 'package:kratos/density/view/screens/compare_screen.dart';
import 'package:kratos/density/view/screens/density_home.dart';
import 'package:kratos/density/view/screens/introduction_screen.dart';
import 'package:kratos/density/view/screens/mystery_screen.dart';

/// Loop 8 programmatic runtime acceptance (logic + layout smoke).
/// Visual texture quality still requires manual confirmation on device.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await DensityTextureCache.load();
  });

  Future<void> pumpUntilDensityReady(WidgetTester tester) async {
    for (var i = 0; i < 50; i++) {
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  group('Loop8 intro defaults', () {
    test('1.1 A Wood 2kg 0.005m³; B hidden', () {
      final intro = DensityController().intro;
      expect(intro.mode, TwoBlockMode.oneBlock);
      expect(intro.blockA.materialId, DensityMaterialId.wood);
      expect(intro.blockA.volume, 0.005);
      expect(DensityRelation.massOf(intro.blockA), closeTo(2.0, 1e-6));
      expect(intro.blockA.position, const DensityVec(-0.2, 0.2));
      expect(intro.blockB.visible, isFalse);
    });

    test('1.2 Two Blocks reveals B Aluminum 13.5kg', () {
      final c = DensityController();
      c.setIntroMode(TwoBlockMode.twoBlocks);
      expect(c.intro.blockB.visible, isTrue);
      expect(c.intro.blockB.materialId, DensityMaterialId.aluminum);
      expect(DensityRelation.massOf(c.intro.blockB), closeTo(13.5, 1e-6));
      expect(c.intro.blockB.volume, 0.005);
    });

    test('1.3 named material mass changes volume not density', () {
      var block = DensityRelation.createWithVolume(
        id: 'a',
        tag: 'A',
        materialId: DensityMaterialId.wood,
        volume: 0.005,
      );
      final d0 = DensityRelation.densityOf(block);
      block = DensityRelation.setMass(block, 3);
      expect(DensityRelation.densityOf(block), d0);
      expect(block.volume, isNot(0.005));
    });

    test('1.6 custom max mass 10 kg via density clamp', () {
      var block = DensityRelation.setMaterial(
        DensityRelation.createWithVolume(
          id: 'a',
          tag: 'A',
          materialId: DensityMaterialId.wood,
          volume: 0.005,
        ),
        DensityMaterialId.custom,
      );
      block = DensityRelation.setMass(block, 10);
      expect(DensityRelation.massOf(block), lessThanOrEqualTo(10.01));
    });

    test('4.1 beginGrab lifts 0.0001m', () {
      final mvt = DensityMvt.fit(const Size(1024, 768));
      final c = DensityController();
      final startY = c.intro.blockA.position.y;
      final screen = mvt.toScreen(c.intro.blockA.position);
      c.pointerDown(screen, mvt);
      expect(c.intro.blockA.position.y, closeTo(startY + 0.0001, 1e-4));
    });

    test('drag preserves mass volume density', () {
      final c = DensityController();
      final mvt = DensityMvt.fit(const Size(1024, 768));
      final m0 = DensityRelation.massOf(c.intro.blockA);
      final v0 = c.intro.blockA.volume;
      final d0 = DensityRelation.densityOf(c.intro.blockA);
      final screen = mvt.toScreen(c.intro.blockA.position);
      c.pointerDown(screen, mvt);
      c.pointerMove(screen + const Offset(60, -30), mvt);
      for (var i = 0; i < 10; i++) {
        c.step(1 / 60);
      }
      expect(DensityRelation.massOf(c.intro.blockA), m0);
      expect(c.intro.blockA.volume, v0);
      expect(DensityRelation.densityOf(c.intro.blockA), d0);
    });
  });

  group('Loop8 textures', () {
    test('six intro col maps loaded', () {
      expect(DensityTextureCache.isLoaded, isTrue);
      for (final id in DensityMaterials.simpleMassMaterials.map((m) => m.id)) {
        expect(DensityTextureCache.imageFor(id), isNotNull);
      }
    });

    test('texture paint rect scales with volume', () {
      final mvt = DensityMvt.fit(const Size(1024, 768));
      final small = mvt.cubeFrontRect(const DensityVec(0, 0), 0.001);
      final large = mvt.cubeFrontRect(const DensityVec(0, 0), 0.01);
      expect(large.width, greaterThan(small.width));
      expect(large.height, greaterThan(small.height));
    });
  });

  group('Loop8 compare', () {
    test('2.1 same mass 5kg volumes', () {
      final blocks = CompareConstraint.createSet(
        set: CompareBlockSet.sameMass,
        lockedMass: 5,
        lockedVolume: 0.005,
        lockedDensity: 500,
      );
      expect(blocks.length, 4);
      for (final b in blocks) {
        expect(DensityRelation.massOf(b), closeTo(5, 1e-6));
      }
      expect(blocks.map((b) => b.volume).toList(),
          [0.01, 0.005, 0.0025, 0.00125]);
    });

    test('2.2 same volume masses 8/6/4/2', () {
      final blocks = CompareConstraint.createSet(
        set: CompareBlockSet.sameVolume,
        lockedMass: 5,
        lockedVolume: 0.005,
        lockedDensity: 500,
      );
      for (final b in blocks) {
        expect(b.volume, 0.005);
      }
      expect(
        blocks.map((b) => DensityRelation.massOf(b)).toList(),
        [8, 6, 4, 2],
      );
    });

    test('2.3 same density volumes and masses', () {
      final blocks = CompareConstraint.createSet(
        set: CompareBlockSet.sameDensity,
        lockedMass: 5,
        lockedVolume: 0.005,
        lockedDensity: 500,
      );
      expect(blocks.map((b) => b.volume).toList(), [0.006, 0.004, 0.002, 0.001]);
      for (final b in blocks) {
        expect(DensityRelation.densityOf(b), 500);
        expect(
          DensityRelation.massOf(b),
          closeTo(500 * b.volume, 1e-5),
        );
      }
    });

    test('compare tags remap per mode not fixed color', () {
      final sm = CompareConstraint.cubesData[0];
      expect(sm.sameMassTag, 'B');
      expect(sm.sameVolumeTag, 'A');
      expect(sm.sameDensityTag, 'B');
    });
  });

  group('Loop8 mystery', () {
    test('3.2 set2 2A density 11340', () {
      final c = DensityController();
      c.setMysterySet(MysteryBlockSet.set2);
      final twoA = c.mystery.set2.firstWhere((b) => b.tag == '2A');
      expect(twoA.customDensity, 11340);
      expect(twoA.customDensity, isNot(11342));
    });

    test('3.4 scale reading matches mass on platform', () {
      final block = DensityRelation.createWithMass(
        id: 's',
        tag: 'T',
        materialId: DensityMaterialId.custom,
        mass: 4.5,
        customDensity: 900,
      );
      final half = DensityRelation.cubeSideLength(block.volume) / 2;
      final scaleTop = BuoyancyWorld.scalePosition.y + BuoyancyWorld.scaleHeight / 2;
      final onScale = block.copyWith(
        position: DensityVec(
          BuoyancyWorld.scalePosition.x,
          scaleTop + half,
        ),
      );
      final result = BuoyancyWorld.step(
        blocks: [onScale],
        dt: 1 / 60,
        measureScale: true,
      );
      expect(result.scaleKg, closeTo(4.5, 1e-5));
    });

    test('3.6 density table 13 rows ascending', () {
      final rows = DensityTable.rows();
      expect(rows.length, 13);
      for (var i = 1; i < rows.length; i++) {
        expect(rows[i].kgPerLiter, greaterThanOrEqualTo(rows[i - 1].kgPerLiter));
      }
      expect(rows.last.material.id, DensityMaterialId.gold);
    });

    test('random reset rerolls even when not on random tab', () {
      final seeded = DensityController(random: Random(42));
      seeded.setMysterySet(MysteryBlockSet.set1);
      final r1 = seeded.mystery.randomBlocks.map((b) => b.volume).toList();
      seeded.resetMystery();
      final r2 = seeded.mystery.randomBlocks.map((b) => b.volume).toList();
      expect(r1, isNot(equals(r2)));
    });

    test('3.16 reset collapses density table state', () {
      final c = DensityController()..selectScreen(DensityScreenId.mystery);
      c.setMysteryTableExpanded(true);
      expect(c.mystery.tableExpanded, isTrue);
      c.resetMystery();
      expect(c.mystery.tableExpanded, isFalse);
    });
  });

  group('Loop8 viewports no overflow', () {
    const sizes = [
      Size(1024, 768),
      Size(1280, 800),
      Size(1366, 1024),
      Size(840, 520),
    ];

    for (final size in sizes) {
      testWidgets('${size.width.toInt()}x${size.height.toInt()} intro compare mystery',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);

        final controller = DensityController();
        await tester.pumpWidget(
          TickerMode(
            enabled: false,
            child: MaterialApp(
              home: DensityHome(),
            ),
          ),
        );
        await tester.pump();
        await pumpUntilDensityReady(tester);

        await tester.pumpWidget(
          TickerMode(
            enabled: false,
            child: MaterialApp(
              home: Scaffold(body: CompareScreen(controller: controller)),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          TickerMode(
            enabled: false,
            child: MaterialApp(
              home: Scaffold(body: MysteryScreen(controller: controller)),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          TickerMode(
            enabled: false,
            child: MaterialApp(
              home: Scaffold(body: IntroductionScreen(controller: controller)),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
