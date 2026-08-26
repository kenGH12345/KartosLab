import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/circuit/models/circuit_state.dart';
import 'package:kratos/circuit/screens/circuit_screen.dart';
import 'package:kratos/circuit/widgets/component_icon.dart';
import 'package:kratos/common/controls/kratos_combo_box.dart';

/// T-P1-06 · AC-R1 回归（1/2）：不传钩子 → 无 inquiryTask 场景行为不变。
/// （独立文件：CircuitScreen 二例化加载挂起缺陷 · 每文件 1 用例）
void main() {
  testWidgets('AC-R1 · 不传钩子 → controlled-switch 合闸后无 Snackbar、无 crash'
      '（与判定/提示解耦前一致）', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: CircuitScreen()));
    for (var i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(KratosComboBox<String>).evaluate().isNotEmpty) break;
    }

    // 切到 controlled-switch 并合闸
    await tester.tap(find.byType(KratosComboBox<String>));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('开关控制电路').last);
    await tester.pump(const Duration(milliseconds: 300));
    final switchIcon = find.byWidgetPredicate(
      (w) => w is ComponentIconWidget && w.type == ComponentType.switch_,
    );
    await tester.tapAt(tester.getCenter(switchIcon));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byTooltip('切换'));
    await tester.pump(const Duration(milliseconds: 100));

    // controlled-switch 无 inquiryTask → Snackbar 本就不提示（解耦前后行为一致）
    expect(find.textContaining('探究目标已达成'), findsNothing);
  });
}
