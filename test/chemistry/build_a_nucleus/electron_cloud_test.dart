import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/ban_constants.dart';
import 'package:kratos/chemistry/build_a_nucleus/controller/build_a_nucleus_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/build_a_nucleus_state.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/electron_cloud.dart';
import 'package:kratos/chemistry/build_a_nucleus/screens/build_a_nucleus_screen.dart';

/// Phase 1G-3B-6：电子云取证对应的派生与生命周期测试。
/// 无 golden / 新视觉框架。屏内 SimulationClock 常开，不能 pumpAndSettle。
void main() {
  late final NuclideRepository repo;

  setUpAll(() {
    final jsonStr = File('assets/data/nuclide_table.json').readAsStringSync();
    repo = NuclideRepository(
      NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
    );
  });

  BuildANucleusState newState() => BuildANucleusState(repository: repo);

  void buildUp(BuildANucleusState s, int p, int n) {
    while (s.protonCount < p || s.neutronCount < n) {
      if (s.protonCount < p && s.neutronCount < n) {
        expect(s.addPair(), isTrue);
      } else if (s.protonCount < p) {
        expect(s.addProton(), isNotNull);
      } else {
        expect(s.addNeutron(), isNotNull);
      }
      s.settleAll();
    }
  }

  double compressedOf(double atomicRadius) =>
      10 + (atomicRadius - 1) / (94 - 1) * (20 - 10);

  group('ElectronCloudReading 派生', () {
    test('空核：透明，不查有效半径', () {
      final s = newState();
      final r = ElectronCloudReading.fromState(s);
      expect(s.isEmptyNucleus, isTrue);
      expect(r.protonCount, 0);
      expect(r.isTransparent, isTrue);
      expect(r.compressedDiameter(), 0);
      expect(r.viewRadius(BanConstants.screenViewAtomCenterX), 0);
    });

    test('H-1：电子数 = 质子数 1，半径来自表 53', () {
      final s = newState();
      buildUp(s, 1, 0);
      expect(s.electronCloudAtomicRadius, 53);
      final r = ElectronCloudReading.fromState(s);
      expect(r.protonCount, 1);
      expect(r.isTransparent, isFalse);
      expect(r.atomicRadius, 53);
      expect(r.compressedDiameter(), closeTo(compressedOf(53), 1e-9));
    });

    test('H-3：与 H-1 同质子数 → 同一云（中子不影响）', () {
      final h1 = newState()..addProton();
      h1.settleAll();
      final h3 = newState();
      buildUp(h3, 1, 2);
      final a = ElectronCloudReading.fromState(h1);
      final b = ElectronCloudReading.fromState(h3);
      expect(a.protonCount, b.protonCount);
      expect(a.atomicRadius, b.atomicRadius);
      expect(a.compressedDiameter(), b.compressedDiameter());
    });

    test('C-14：Z=6，表半径 67', () {
      final s = newState();
      buildUp(s, 6, 8);
      expect(s.elementSymbol, 'C');
      expect(s.electronCloudAtomicRadius, 67);
      final r = ElectronCloudReading.fromState(s);
      expect(r.protonCount, 6);
      expect(r.compressedDiameter(), closeTo(compressedOf(67), 1e-9));
    });

    test('较高质子数：表半径 26→156、92→175；LinearFunction 不 clamp', () {
      expect(repo.electronCloudRadius(26), 156);
      expect(repo.electronCloudRadius(92), 175);
      const r = ElectronCloudReading(protonCount: 26, atomicRadius: 156);
      // 156 > 94，无 clamp → 压缩直径 > 20
      expect(r.compressedDiameter(), closeTo(compressedOf(156), 1e-9));
      expect(r.compressedDiameter(), greaterThan(20));
    });

    test('不存在核素：云仍只跟质子数，不跟存在性', () {
      final s = newState();
      buildUp(s, 2, 0); // He-2 不存在
      expect(s.nuclideExists, isFalse);
      expect(s.electronCloudAtomicRadius, 31); // He 表半径
      final r = ElectronCloudReading.fromState(s);
      expect(r.isTransparent, isFalse);
      expect(r.protonCount, 2);
    });

    test('0p 中子团：质子 0 → 云透明（empty 圆另由 massNumber 控制）', () {
      final s = newState();
      expect(s.addNeutron(), isNotNull);
      s.settleAll();
      expect(s.protonCount, 0);
      expect(s.neutronCount, 1);
      expect(s.isEmptyNucleus, isFalse);
      final r = ElectronCloudReading.fromState(s);
      expect(r.isTransparent, isTrue);
    });

    test('元素变化：H→C 压缩直径随表半径变', () {
      final h = newState();
      buildUp(h, 1, 0);
      final c = newState();
      buildUp(c, 6, 8);
      expect(
        ElectronCloudReading.fromState(h).compressedDiameter(),
        isNot(ElectronCloudReading.fromState(c).compressedDiameter()),
      );
      expect(
        ElectronCloudReading.fromState(c).compressedDiameter(),
        closeTo(compressedOf(67), 1e-9),
      );
    });

    test('电子数量变化 = 质子数变化；视图半径公式', () {
      const cx = 256.0;
      final h = newState();
      buildUp(h, 1, 0);
      final r1 = ElectronCloudReading.fromState(h);
      final d1 = r1.compressedDiameter();
      expect(r1.viewRadius(cx), closeTo((cx - d1 / 2) * 0.27, 1e-9));

      final o = newState();
      buildUp(o, 8, 8);
      final r8 = ElectronCloudReading.fromState(o);
      expect(r8.protonCount, 8);
      expect(r8.atomicRadius, 48);
      expect(r8.viewRadius(cx), isNot(r1.viewRadius(cx)));
    });

    test('Reset 后回到透明空核', () {
      final s = newState();
      buildUp(s, 6, 8);
      expect(ElectronCloudReading.fromState(s).isTransparent, isFalse);
      s.reset();
      final r = ElectronCloudReading.fromState(s);
      expect(r.protonCount, 0);
      expect(r.isTransparent, isTrue);
    });

    test('无动画：同一质子数重复读取结果确定', () {
      final s = newState();
      buildUp(s, 6, 8);
      final a = ElectronCloudReading.fromState(s);
      final b = ElectronCloudReading.fromState(s);
      expect(a.viewRadius(100), b.viewRadius(100));
      expect(a.compressedDiameter(), b.compressedDiameter());
    });

    test('缺表条目：压缩直径 0（对标 getAtomicRadius 空值分支）', () {
      const r = ElectronCloudReading(protonCount: 3, atomicRadius: null);
      expect(r.isTransparent, isFalse);
      expect(r.compressedDiameter(), 0);
    });
  });

  group('Checkbox 生命周期（视图层）', () {
    Future<BuildANucleusController> pumpScreen(
      WidgetTester tester, {
      BuildANucleusController? controller,
    }) async {
      final c = controller ?? BuildANucleusController(repository: repo);
      await tester.pumpWidget(
        MaterialApp(home: BuildANucleusScreen(controller: c)),
      );
      await tester.pump();
      return c;
    }

    testWidgets('默认勾选 Electron Cloud', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Electron Cloud'), findsOneWidget);
      expect(
        tester.widget<Checkbox>(find.byType(Checkbox)).value,
        isTrue,
      );
    });

    testWidgets('取消勾选后 Reset 恢复为显示', (tester) async {
      final c = await pumpScreen(tester);
      c.addProton();
      c.state.settleAll();
      await tester.pump();

      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(
        tester.widget<Checkbox>(find.byType(Checkbox)).value,
        isFalse,
      );

      await tester.tap(find.byKey(const ValueKey('ban_reset')));
      await tester.pump();
      expect(
        tester.widget<Checkbox>(find.byType(Checkbox)).value,
        isTrue,
      );
      expect(c.state.isEmptyNucleus, isTrue);
      expect(ElectronCloudReading.fromState(c.state).isTransparent, isTrue);
    });

    testWidgets('H-1 与 C-14 屏上可渲染（无 throw）', (tester) async {
      final h = BuildANucleusController(repository: repo);
      h.addProton();
      h.state.settleAll();
      await pumpScreen(tester, controller: h);
      expect(find.text('Hydrogen - 1'), findsOneWidget);

      final carbon = BuildANucleusController(repository: repo);
      while (carbon.state.protonCount < 6 || carbon.state.neutronCount < 8) {
        if (carbon.state.protonCount < 6 && carbon.state.neutronCount < 8) {
          carbon.addPair();
        } else if (carbon.state.protonCount < 6) {
          carbon.addProton();
        } else {
          carbon.addNeutron();
        }
        carbon.state.settleAll();
      }
      await tester.pumpWidget(
        MaterialApp(home: BuildANucleusScreen(controller: carbon)),
      );
      await tester.pump();
      expect(find.textContaining('Carbon'), findsWidgets);
    });
  });
}
