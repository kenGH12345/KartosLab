import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/ban_constants.dart';
import 'package:kratos/chemistry/build_a_nucleus/controller/build_a_nucleus_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/half_life_number_line.dart';

/// Phase 1G-3A：半衰期数轴数据与 log10 映射。无 Painter。
void main() {
  late final NuclideRepository repo;

  setUpAll(() {
    final jsonStr = File('assets/data/nuclide_table.json').readAsStringSync();
    repo = NuclideRepository(
      NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
    );
  });

  BuildANucleusController builtUp(int p, int n) {
    final c = BuildANucleusController(repository: repo);
    while (c.state.protonCount < p || c.state.neutronCount < n) {
      if (c.state.protonCount < p && c.state.neutronCount < n) {
        c.addPair();
      } else if (c.state.protonCount < p) {
        c.addProton();
      } else {
        c.addNeutron();
      }
      c.state.settleAll();
    }
    return c;
  }

  Matcher closeExp(num expected) => closeTo(expected, 1e-12);

  group('轴几何', () {
    test('范围 -24…24，tick 间距 3，含两端，0 处标签为 1', () {
      expect(HalfLifeNumberLine.startExponent, -24);
      expect(HalfLifeNumberLine.endExponent, 24);
      expect(HalfLifeNumberLine.tickSpacing, 3);
      expect(HalfLifeNumberLine.unitsLabel, 'seconds');
      final ticks = HalfLifeNumberLine.tickExponents();
      expect(ticks.first, -24);
      expect(ticks.last, 24);
      expect(ticks, hasLength(17));
      expect(ticks, contains(0));
      expect(HalfLifeNumberLine.tickLabel(0), '1');
      expect(HalfLifeNumberLine.tickLabel(-24), '10^-24');
      expect(HalfLifeNumberLine.tickLabel(24), '10^24');
    });
  });

  group('logScaleNumberToLinearScaleNumber（原版公式）', () {
    test('0 → 0，不是 log(0)，也不是 -24', () {
      expect(HalfLifeNumberLine.logScaleNumberToLinearScaleNumber(0), 0);
    });

    test('10^n 秒 → 指数 n', () {
      expect(HalfLifeNumberLine.logScaleNumberToLinearScaleNumber(1), closeExp(0));
      expect(HalfLifeNumberLine.logScaleNumberToLinearScaleNumber(1e3), closeExp(3));
      expect(HalfLifeNumberLine.logScaleNumberToLinearScaleNumber(1e-21), closeExp(-21));
      expect(
        HalfLifeNumberLine.logScaleNumberToLinearScaleNumber(
          BanConstants.stableHalfLifeDisplay,
        ),
        closeExp(24),
      );
    });
  });

  group('特殊值哨兵（fromValues，不经核素表）', () {
    test('Stable：∞ 读数，指针钉在 +24，箭头可见且向右', () {
      final r = HalfLifeNumberLine.fromValues(
        halfLifeNumber: BanConstants.stableHalfLifeDisplay,
        isStable: true,
      );
      expect(r.readoutKind, HalfLifeReadoutKind.infinity);
      expect(r.halfLifeSeconds, isNull);
      expect(r.pointerExponent, 24);
      expect(r.pointerVisible, isTrue);
      expect(r.pointerPointsRight, isTrue);
      expect(r.normalizedPosition, 1);
    });

    test('Unknown：-1 不进 log10，指针在指数 0 但隐藏', () {
      final r = HalfLifeNumberLine.fromValues(
        halfLifeNumber: BanConstants.unknownHalfLife,
        isStable: false,
      );
      expect(r.readoutKind, HalfLifeReadoutKind.unknown);
      expect(r.pointerExponent, 0);
      expect(r.pointerVisible, isFalse);
      expect(r.normalizedPosition, 0.5);
    });

    test('Nonexistent：0 指针在指数 0 隐藏，读数 none', () {
      final r = HalfLifeNumberLine.fromValues(
        halfLifeNumber: BanConstants.nonexistentHalfLife,
        isStable: false,
      );
      expect(r.readoutKind, HalfLifeReadoutKind.none);
      expect(r.pointerExponent, 0);
      expect(r.pointerVisible, isFalse);
      expect(r.normalizedPosition, 0.5);
    });

    test('超右端：指针钉 24、向右，读数仍是真值', () {
      const actual = 1e30;
      final r = HalfLifeNumberLine.fromValues(
        halfLifeNumber: actual,
        isStable: false,
      );
      expect(r.readoutKind, HalfLifeReadoutKind.seconds);
      expect(r.halfLifeSeconds, actual);
      expect(r.pointerExponent, closeExp(24));
      expect(r.pointerVisible, isTrue);
      expect(r.pointerPointsRight, isTrue);
      expect(r.normalizedPosition, closeTo(1, 1e-12));
    });

    test('左端无 clamp：1e-30 → 指数 -30，normalized < 0', () {
      final r = HalfLifeNumberLine.fromValues(
        halfLifeNumber: 1e-30,
        isStable: false,
      );
      expect(r.pointerExponent, closeExp(-30));
      expect(r.normalizedPosition, lessThan(0));
      expect(r.pointerVisible, isTrue);
      expect(r.pointerPointsRight, isFalse);
    });
  });

  group('真实核素（只读 State.halfLifeNumber）', () {
    test('正常：H-3', () {
      final s = builtUp(1, 2).state;
      expect(s.halfLifeNumber, 388781328.0);
      final r = HalfLifeNumberLine.fromState(s);
      expect(r.readoutKind, HalfLifeReadoutKind.seconds);
      expect(r.halfLifeSeconds, 388781328.0);
      expect(
        r.pointerExponent,
        closeExp(math.log(388781328.0) / math.ln10),
      );
      expect(r.pointerVisible, isTrue);
      expect(r.pointerPointsRight, isFalse);
    });

    test('非常短：Be-6', () {
      final s = builtUp(4, 2).state;
      expect(s.halfLifeNumber, 4.95911e-21);
      final r = HalfLifeNumberLine.fromState(s);
      expect(r.pointerExponent, closeExp(math.log(4.95911e-21) / math.ln10));
      expect(r.normalizedPosition, inInclusiveRange(0, 1));
    });

    test('非常长：C-14 在轴内；Pu-240 秒数大于 C-14', () {
      final c14 = HalfLifeNumberLine.fromState(builtUp(6, 8).state);
      expect(c14.halfLifeSeconds, 1.79874e11);
      expect(c14.pointerExponent, lessThan(24));

      // Pu-240 用表内秒数走同一映射，避免箭头搭建 240 核子。
      final pu = HalfLifeNumberLine.fromValues(
        halfLifeNumber: repo.halfLife(94, 146).seconds!,
        isStable: false,
      );
      expect(pu.halfLifeSeconds, 2.07045e11);
      expect(pu.pointerExponent, greaterThan(c14.pointerExponent));
    });

    test('Stable：H-1', () {
      final s = builtUp(1, 0).state;
      expect(s.halfLifeNumber, BanConstants.stableHalfLifeDisplay);
      expect(s.isStable, isTrue);
      final r = HalfLifeNumberLine.fromState(s);
      expect(r.readoutKind, HalfLifeReadoutKind.infinity);
      expect(r.pointerExponent, 24);
    });

    test('Unknown：H-4', () {
      final s = builtUp(1, 3).state;
      expect(s.halfLifeNumber, BanConstants.unknownHalfLife);
      final r = HalfLifeNumberLine.fromState(s);
      expect(r.readoutKind, HalfLifeReadoutKind.unknown);
      expect(r.pointerVisible, isFalse);
    });

    test('Nonexistent：空核与 (0,2)', () {
      final empty = BuildANucleusController(repository: repo).state;
      expect(empty.halfLifeNumber, BanConstants.nonexistentHalfLife);
      expect(
        HalfLifeNumberLine.fromState(empty).readoutKind,
        HalfLifeReadoutKind.none,
      );

      final c = builtUp(0, 1);
      c.addNeutron();
      c.state.settleAll();
      expect(c.state.halfLifeNumber, BanConstants.nonexistentHalfLife);
      expect(
        HalfLifeNumberLine.fromState(c.state).readoutKind,
        HalfLifeReadoutKind.none,
      );
    });
  });

  group('单调性与核素切换', () {
    test('正半衰期越大，指针指数越大', () {
      final seconds = <double>[
        4.95911e-21, // Be-6
        613.9, // 自由中子
        388781328.0, // H-3
        1.79874e11, // C-14
        2.07045e11, // Pu-240
      ];
      final exponents = [
        for (final t in seconds)
          HalfLifeNumberLine.fromValues(halfLifeNumber: t, isStable: false)
              .pointerExponent,
      ];
      for (var i = 1; i < exponents.length; i++) {
        expect(exponents[i], greaterThan(exponents[i - 1]),
            reason: '${seconds[i]} should sit right of ${seconds[i - 1]}');
      }
    });

    test('核素切换：对当前 State 重算，无缓存', () {
      final empty = HalfLifeNumberLine.fromState(
        BuildANucleusController(repository: repo).state,
      );
      final h1 = HalfLifeNumberLine.fromState(builtUp(1, 0).state);
      final h3 = HalfLifeNumberLine.fromState(builtUp(1, 2).state);
      final h4 = HalfLifeNumberLine.fromState(builtUp(1, 3).state);

      expect(empty.readoutKind, HalfLifeReadoutKind.none);
      expect(h1.readoutKind, HalfLifeReadoutKind.infinity);
      expect(h3.readoutKind, HalfLifeReadoutKind.seconds);
      expect(h4.readoutKind, HalfLifeReadoutKind.unknown);

      expect(h3.pointerExponent, greaterThan(empty.pointerExponent));
      expect(h1.pointerExponent, greaterThan(h3.pointerExponent));
    });
  });
}
