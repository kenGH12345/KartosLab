import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/ban_constants.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/half_life_number_line.dart';
import 'package:kratos/chemistry/build_a_nucleus/painters/half_life_number_line_painter.dart';
import 'package:kratos/chemistry/build_a_nucleus/widgets/half_life_number_line_view.dart';

/// Phase 1G-3B-1：数轴基础视觉。坐标公式来自 ChartTransform，非经验拟合。
void main() {
  const viewW = 480.0;

  double x(num exponent) =>
      HalfLifeChartTransform.modelToViewX(exponent.toDouble(), viewW);

  group('ChartTransform 映射（公式精确）', () {
    test('两端与中点', () {
      expect(x(-24), 0);
      expect(x(24), viewW);
      expect(x(0), viewW / 2);
    });

    test('用户点名的刻度：-24/-21/-3/0/3/21/24', () {
      expect(x(-24), 0);
      expect(x(-21), viewW * 3 / 48);
      expect(x(-3), viewW * 21 / 48);
      expect(x(0), viewW * 24 / 48);
      expect(x(3), viewW * 27 / 48);
      expect(x(21), viewW * 45 / 48);
      expect(x(24), viewW);
    });
  });

  Future<void> pumpLine(
    WidgetTester tester,
    HalfLifeNumberLineReading reading,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: viewW,
              child: HalfLifeNumberLineView(reading: reading),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('刻度数量与标签', () {
    testWidgets('17 个 tick；0→1，其余 10^n 上标', (tester) async {
      await pumpLine(
        tester,
        HalfLifeNumberLine.fromValues(halfLifeNumber: 1, isStable: false),
      );
      for (final e in [-24, -21, -3, 0, 3, 21, 24]) {
        expect(find.byKey(ValueKey('ban_half_life_tick_$e')), findsOneWidget);
      }
      expect(find.byKey(const ValueKey('ban_half_life_number_line')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('ban_half_life_tick_-24')),
        findsOneWidget,
      );
      expect(HalfLifeNumberLine.tickExponents(), hasLength(17));
      expect(find.text('1'), findsOneWidget);
      expect(find.textContaining('-24'), findsOneWidget);
      expect(find.textContaining('-21'), findsOneWidget);
      expect(find.textContaining('-3'), findsOneWidget);
    });

    testWidgets('tick Positioned.left 等于 modelToViewX', (tester) async {
      await pumpLine(
        tester,
        HalfLifeNumberLine.fromValues(halfLifeNumber: 1, isStable: false),
      );
      final origin = tester.getTopLeft(
        find.byKey(const ValueKey('ban_half_life_number_line')),
      );
      for (final e in [-24, -21, -3, 0, 3, 21, 24]) {
        final tickLeft = tester.getTopLeft(find.byKey(ValueKey('ban_half_life_tick_$e')));
        expect(tickLeft.dx - origin.dx, closeTo(x(e), 0.5));
      }
    });
  });

  group('指针静态位置与可见性（只用 Reading，不解读哨兵）', () {
    testWidgets('Stable：可见、在 +24、向右', (tester) async {
      final r = HalfLifeNumberLine.fromValues(
        halfLifeNumber: BanConstants.stableHalfLifeDisplay,
        isStable: true,
      );
      expect(r.pointerVisible, isTrue);
      expect(r.pointerPointsRight, isTrue);
      expect(r.pointerExponent, 24);
      await pumpLine(tester, r);
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.byKey(const ValueKey('ban_half_life_pointer')), findsOneWidget);
      final origin = tester.getTopLeft(
        find.byKey(const ValueKey('ban_half_life_number_line')),
      );
      final p = tester.getTopLeft(find.byKey(const ValueKey('ban_half_life_pointer')));
      expect(p.dx - origin.dx, closeTo(x(24), 0.5));
    });

    testWidgets('Unknown：指针隐藏', (tester) async {
      final r = HalfLifeNumberLine.fromValues(
        halfLifeNumber: BanConstants.unknownHalfLife,
        isStable: false,
      );
      expect(r.pointerVisible, isFalse);
      await pumpLine(tester, r);
      expect(find.byKey(const ValueKey('ban_half_life_pointer')), findsNothing);
    });

    testWidgets('Nonexistent：指针隐藏', (tester) async {
      final r = HalfLifeNumberLine.fromValues(
        halfLifeNumber: BanConstants.nonexistentHalfLife,
        isStable: false,
      );
      expect(r.pointerVisible, isFalse);
      await pumpLine(tester, r);
      expect(find.byKey(const ValueKey('ban_half_life_pointer')), findsNothing);
    });

    testWidgets('已知 1s：指针在指数 0（轴中点）', (tester) async {
      final r = HalfLifeNumberLine.fromValues(
        halfLifeNumber: 1,
        isStable: false,
      );
      expect(r.pointerVisible, isTrue);
      expect(r.pointerPointsRight, isFalse);
      await pumpLine(tester, r);
      final origin = tester.getTopLeft(
        find.byKey(const ValueKey('ban_half_life_number_line')),
      );
      final p = tester.getTopLeft(find.byKey(const ValueKey('ban_half_life_pointer')));
      expect(p.dx - origin.dx, closeTo(x(0), 0.5));
    });
  });
}
