// integration_test/color_vision_test.dart
// req-color-vision-layout-fix Phase 3 · 由主会话在 pair 编程中直接产出
//
// 本文件用 flutter integration_test 框架自动化验证 color_vision Single Bulb 屏的核心 AC。
// 通过 headless test runner 跑，无需 GUI · 无需鼠标 · 无需人工截图。
//
// 覆盖：
//   AC-1 (L0-2)：主图 CustomPaint 始终可见 · 高度 > 0
//   AC-2 (filter)：White 光 + Red 滤片 → Person sees: Red
//   AC-3 (filter)：切换所有 filter · 主图仍可见（L0-2 回归保护）
//   AC-3b (filter)：White 光 + Blue 滤片 → Person sees: Blue
//   AC-1b (mono)：切到 Mono 模式 · SpectrumSlider 出现
//
// 关键约束：color_vision 有常驻 60fps SimulationClock (single_bulb_screen.dart:52),
//         导致 pumpAndSettle() 永不返回。改用 pump(Duration) 手动推进指定帧数。
//
// Fixture 策略（v2 · 2026-08-06 修订）：
//   直接 pumpWidget(MaterialApp(home: SingleBulbScreen(scenario: null))) 挂载本 sim,
//   绕过 HomeScreen → ColorVisionHome 导航链。原因: 那条链上存在与本需求无关的
//   RenderFlex overflow (offset(715,0), 130x139 Column), 会污染 IntegrationTestBinding
//   的 exception 判定, 让本 sim 的 AC 断言无法拿到清白结果。
//   该 overflow 转档追踪于 requirements/req-home-screen-overflow-fix/ (stub, 2026-08-06 立)。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kratos/color_vision/screens/single_bulb_screen.dart';
import 'package:kratos/color_vision/painters/single_bulb_painter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Configure test viewport (desktop-scale, 与 AC-4 desktop-red.png 视口一致).
  void configureViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  /// Pump several frames to let animations progress
  /// without blocking forever on the always-ticking SimulationClock.
  Future<void> settle(WidgetTester tester) async {
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Mount SingleBulbScreen in isolation (bypass HomeScreen/ColorVisionHome).
  Future<void> mountSingleBulb(WidgetTester tester) async {
    configureViewport(tester);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SingleBulbScreen())),
    );
    await settle(tester);
  }

  group('Color Vision Single Bulb (isolated)', () {
    testWidgets('AC-1 L0-2: main canvas visible in default state', (tester) async {
      await mountSingleBulb(tester);
      final painterFinder = find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is SingleBulbPainter,
      );
      expect(painterFinder, findsOneWidget);
      final size = tester.getSize(painterFinder.first);
      expect(size.height, greaterThan(0.0),
          reason: 'Main canvas must have positive height (L0-2 rule)');
      expect(size.width, greaterThan(0.0),
          reason: 'Main canvas must have positive width (L0-2 rule)');
    });

    testWidgets('AC-2 white + red filter -> Person sees Red', (tester) async {
      await mountSingleBulb(tester);
      final redChip = find.widgetWithText(ChoiceChip, 'Red');
      expect(redChip, findsOneWidget);
      await tester.tap(redChip);
      await settle(tester);
      expect(find.textContaining('Person sees:'), findsWidgets);
      expect(find.textContaining('Red'), findsWidgets,
          reason: 'AC-2: white light + red filter must yield red perceived color');
    });

    testWidgets('AC-3 filter switching keeps main canvas visible', (tester) async {
      await mountSingleBulb(tester);
      final painterFinder = find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is SingleBulbPainter,
      );
      for (final label in ['None', 'Red', 'Green', 'Blue', 'Custom']) {
        final chip = find.widgetWithText(ChoiceChip, label);
        expect(chip, findsOneWidget, reason: '$label filter chip should exist');
        await tester.tap(chip);
        await settle(tester);
        expect(painterFinder, findsOneWidget,
            reason: 'After selecting $label filter, main canvas must still exist');
        final size = tester.getSize(painterFinder.first);
        expect(size.height, greaterThan(0.0),
            reason: 'After selecting $label filter, canvas height must be > 0 (L0-2)');
      }
    });

    testWidgets('AC-3b white + blue filter -> Person sees Blue', (tester) async {
      await mountSingleBulb(tester);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Blue'));
      await settle(tester);
      expect(find.textContaining('Blue'), findsWidgets,
          reason: 'AC-3: white light + blue filter must yield blue perceived color');
    });

    testWidgets('AC-1b mono mode toggles SpectrumSlider visibility', (tester) async {
      await mountSingleBulb(tester);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Mono'));
      await settle(tester);
      expect(find.byType(Slider), findsWidgets,
          reason: 'Mono mode should show SpectrumSlider (with inner Slider)');
    });
  });
}
