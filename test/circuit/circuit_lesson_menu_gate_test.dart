import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/circuit/screens/circuit_screen.dart';
import 'package:kratos/common/controls/kratos_combo_box.dart';

/// T-P1-06 · Major-3：showScenarioMenu=false → AppBar 场景下拉禁用。
/// 「默认 true → 下拉存在」半句由 circuit_lesson_hooks_test.dart 的
/// 加载等待断言覆盖（同文件二例化缺陷约束）。
/// （独立文件：CircuitScreen 二例化加载挂起缺陷 · 每文件 1 用例）
void main() {
  testWidgets('Major-3 · showScenarioMenu:false → 场景下拉不渲染', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(
      home: CircuitScreen(showScenarioMenu: false),
    ));
    // 充分等待加载完成（即使加载完成，false 门控下也不渲染下拉）
    for (var i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(KratosComboBox<String>), findsNothing);
  });
}
