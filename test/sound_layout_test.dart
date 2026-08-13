// test/sound_layout_test.dart
// req-panel-bottom-migrate 批次1 · 主会话直接产出
//
// 验证 sound 操作面板底部横排（footer）在 320x480 极窄视口与 1600x900 宽视口均无溢出
// （复用 req-ui-interaction-polish molarity_layout_test 的验收模式 · AC-5.3/5.4/5.5）。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/sound/screens/sound_screen.dart';

void main() {
  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(const MaterialApp(home: SoundScreen()));
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('AC-1.3: no overflow at 320x480 (narrowest viewport)', (tester) async {
    await pumpAt(tester, const Size(320, 480));
    expect(tester.takeException(), isNull,
        reason: 'sound footer must not overflow at 320x480');
    expect(find.byType(SingleChildScrollView), findsWidgets);
  });

  testWidgets('AC-1.5: no overflow at 1600x900 (wide viewport)', (tester) async {
    await pumpAt(tester, const Size(1600, 900));
    expect(tester.takeException(), isNull,
        reason: 'sound layout must not overflow at 1600x900');
  });
}
