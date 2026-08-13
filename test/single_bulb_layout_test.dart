// test/single_bulb_layout_test.dart
// req-panel-bottom-migrate 批次3 · 主会话直接产出（修正：包 Scaffold——SingleBulbScreen 自身无 Scaffold，
// 独立 pump 需 Scaffold 包裹，否则布局异常（参考 color_vision_test.dart L54 先例）。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/color_vision/screens/single_bulb_screen.dart';

void main() {
  testWidgets('AC-3.5: single_bulb no overflow at 1600x900', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SingleBulbScreen())),
    );
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(tester.takeException(), isNull,
        reason: 'single_bulb must not overflow at 1600x900 (with Scaffold)');
  });

  testWidgets('AC-3.3: single_bulb no overflow at 320x480', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SingleBulbScreen())),
    );
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(tester.takeException(), isNull,
        reason: 'single_bulb must not overflow at 320x480');
  });
}
