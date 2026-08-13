// test/molarity_layout_test.dart
// req-ui-interaction-polish AC-5 · 主会话直接产出
//
// 验证 molarity 操作面板底部横排（footer）在 320x480 极窄视口与 1600x900 宽视口均无溢出。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/molarity/view/screens/molarity_screen.dart';

void main() {
  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(const MaterialApp(home: MolarityScreen()));
    // 等场景异步加载 + 首帧布局完成
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('AC-5.3: no overflow at 320x480 (narrowest viewport)', (
    tester,
  ) async {
    await pumpAt(tester, const Size(320, 480));
    expect(
      tester.takeException(),
      isNull,
      reason: 'molarity footer must not overflow at 320x480 (AC-5.3)',
    );
    // 底部横排操作面板存在（横向滚动可到达全部控件）
    expect(find.byType(SingleChildScrollView), findsWidgets);
  });

  testWidgets('AC-5.5: no overflow at 1600x900 (wide viewport)', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1600, 900));
    expect(
      tester.takeException(),
      isNull,
      reason: 'molarity layout must not overflow at 1600x900 (AC-5.5)',
    );
  });
}
