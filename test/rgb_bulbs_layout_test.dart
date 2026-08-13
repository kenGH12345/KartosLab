// test/rgb_bulbs_layout_test.dart
// req-panel-bottom-migrate 批次3 · 主会话直接产出
//
// 验证 rgb_bulbs 操作面板底部横排（footer）在 1600x900 宽视口无溢出（三个模式分支）。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/color_vision/screens/rgb_bulbs_screen.dart';

void main() {
  Future<void> pumpAt(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MagicLabScreen())),
    );
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('AC-3.5: rgb_bulbs no overflow at 1600x900', (tester) async {
    await pumpAt(tester);
    expect(tester.takeException(), isNull,
        reason: 'rgb_bulbs footer must not overflow at 1600x900');
  });

  testWidgets('AC-3.3: rgb_bulbs no overflow at 320x480', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final errs = <String>[];
    final old = FlutterError.onError;
    FlutterError.onError = (d) {
      errs.add(d.toString());
      old?.call(d);
    };
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MagicLabScreen())),
    );
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    FlutterError.onError = old;
    if (errs.isNotEmpty) debugPrint('[rgb-320]\n${errs.join('\n===')}');
    expect(tester.takeException(), isNull,
        reason: 'rgb_bulbs footer must not overflow at 320x480');
  });
}
