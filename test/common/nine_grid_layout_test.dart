import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/widgets/nine_grid_layout.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    Widget layout, {
    Size size = const Size(600, 600),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: layout)));
  }

  Widget cell(String tag) => ColoredBox(
        key: Key(tag),
        color: const Color(0xFFCCCCCC),
        child: const SizedBox.expand(),
      );

  NineGridLayout fullLayout({double area = NineGridLayout.kMinCenterAreaRatio}) =>
      NineGridLayout(
        topLeft: cell('tl'),
        topCenter: cell('tc'),
        topRight: cell('tr'),
        midLeft: cell('ml'),
        center: cell('center'),
        midRight: cell('mr'),
        bottomLeft: cell('bl'),
        bottomCenter: cell('bc'),
        bottomRight: cell('br'),
        centerAreaRatio: area,
      );

  group('NineGridLayout · 非等分 · 中间面积 ≥ 70%（正常视口）', () {
    testWidgets('默认面积 70%：中间格面积 ≈ 0.7 屏面积', (tester) async {
      await pump(tester, fullLayout(), size: const Size(600, 600));

      final center = tester.getRect(find.byKey(const Key('center')));
      final areaRatio = (center.width * center.height) / (600 * 600);
      expect(areaRatio, closeTo(0.7, 0.001));

      // 宽、高各 sqrt(0.7) ≈ 0.83666 → 600 × 0.83666 ≈ 502
      final side = math.sqrt(0.7);
      expect(center.width, closeTo(600 * side, 0.5));
      expect(center.height, closeTo(600 * side, 0.5));
      // 边条各 (600 - 502) / 2 ≈ 49（≥ minSideH 48 → 不触发矮视口降级）
      expect(center.left, closeTo(49, 0.5));
      expect(center.top, closeTo(49, 0.5));
    });

    testWidgets('周边 8 格贴屏幕边缘', (tester) async {
      await pump(tester, fullLayout(), size: const Size(600, 600));

      final side = math.sqrt(0.7);
      final edge = (600 - 600 * side) / 2; // ≈ 49

      final tl = tester.getRect(find.byKey(const Key('tl')));
      expect(tl.left, 0);
      expect(tl.top, 0);
      expect(tl.width, closeTo(edge, 0.5));
      expect(tl.height, closeTo(edge, 0.5));

      final tc = tester.getRect(find.byKey(const Key('tc')));
      expect(tc.top, 0);
      expect(tc.left, closeTo(edge, 0.5));
      expect(tc.right, closeTo(600 - edge, 0.5));

      final ml = tester.getRect(find.byKey(const Key('ml')));
      expect(ml.left, 0);
      expect(ml.top, closeTo(edge, 0.5));
      expect(ml.bottom, closeTo(600 - edge, 0.5));

      final br = tester.getRect(find.byKey(const Key('br')));
      expect(br.right, 600);
      expect(br.bottom, 600);
    });

    testWidgets('随视口尺寸自适应缩放（800×600 非方形屏）', (tester) async {
      await pump(tester, fullLayout(), size: const Size(800, 600));

      final center = tester.getRect(find.byKey(const Key('center')));
      final areaRatio = (center.width * center.height) / (800 * 600);
      expect(areaRatio, closeTo(0.7, 0.001));

      final side = math.sqrt(0.7);
      expect(center.width, closeTo(800 * side, 0.5));
      expect(center.height, closeTo(600 * side, 0.5));
      expect(center.left, closeTo((800 - 800 * side) / 2, 0.5));
    });

    testWidgets('面积比例低于 0.7 被强制抬升到下限（强制约束）', (tester) async {
      await pump(
        tester,
        fullLayout(area: 0.5),
        size: const Size(600, 600),
      );

      final center = tester.getRect(find.byKey(const Key('center')));
      final areaRatio = (center.width * center.height) / (600 * 600);
      expect(areaRatio, closeTo(0.7, 0.001));
    });

    testWidgets('自定义面积比例 0.8 生效', (tester) async {
      await pump(
        tester,
        fullLayout(area: 0.8),
        size: const Size(1000, 1000),
      );

      final center = tester.getRect(find.byKey(const Key('center')));
      final areaRatio = (center.width * center.height) / (1000 * 1000);
      expect(areaRatio, closeTo(0.8, 0.001));
    });

    testWidgets('周边格为 null 时正常渲染（只放中间格）', (tester) async {
      await pump(
        tester,
        const NineGridLayout(
          center: ColoredBox(
            key: Key('center'),
            color: Color(0xFF000000),
            child: SizedBox.expand(),
          ),
        ),
        size: const Size(600, 600),
      );

      final center = tester.getRect(find.byKey(const Key('center')));
      final areaRatio = (center.width * center.height) / (600 * 600);
      expect(areaRatio, closeTo(0.7, 0.001));
    });
  });

  group('NineGridLayout · 极端矮视口降级（minSideH=48 保底）', () {
    testWidgets('320×480：边格保底 48px，中间格面积 < 70%（有意降级）', (tester) async {
      await pump(tester, fullLayout(), size: const Size(320, 480));

      final center = tester.getRect(find.byKey(const Key('center')));
      final tl = tester.getRect(find.byKey(const Key('tl')));

      // 边格高保底 48（控件最小可操作高）
      expect(tl.height, closeTo(48, 0.5));
      // 中间格面积被压缩 < 0.7（侧边仍按 sqrt(0.7) 宽）
      final areaRatio = (center.width * center.height) / (320 * 480);
      expect(areaRatio, lessThan(0.7));
      // 中间格高度 = 480 - 2×48
      expect(center.height, closeTo(480 - 96, 0.5));
    });

    testWidgets('300×300：降级后中间格面积 < 0.7（回归基线 0.569）', (tester) async {
      await pump(tester, fullLayout(), size: const Size(300, 300));

      final center = tester.getRect(find.byKey(const Key('center')));
      final areaRatio = (center.width * center.height) / (300 * 300);
      expect(areaRatio, lessThan(0.7));
      expect(center.height, closeTo(300 - 96, 0.5));
    });
  });
}
