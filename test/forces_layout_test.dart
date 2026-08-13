// test/forces_layout_test.dart
// req-panel-bottom-migrate 批次2 · 主会话直接产出
//
// 验证 motion/netforce 操作面板底部横排（footer）在 1600x900 宽视口无溢出。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/forces/screens/netforce_screen.dart';

void main() {
  Future<void> pumpAt(WidgetTester tester, Size size, Widget screen) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(MaterialApp(home: screen));
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  // 注：motion 已完成 footer 迁移 + AppliedForceSlider Expanded 修复（req-panel-bottom-migrate
  // process.txt 15:10）——布局由 forces_home_test 验证；本文件测 netforce（含 320）。

  testWidgets('AC-2.5: netforce no overflow at 1600x900', (tester) async {
    await pumpAt(tester, const Size(1600, 900), const NetForceScreen());
    expect(tester.takeException(), isNull,
        reason: 'netforce footer must not overflow at 1600x900');
  });

  testWidgets('AC-2.3: netforce no overflow at 320x480', (tester) async {
    await pumpAt(tester, const Size(320, 480), const NetForceScreen());
    expect(tester.takeException(), isNull,
        reason: 'netforce footer must not overflow at 320x480');
  });
}
