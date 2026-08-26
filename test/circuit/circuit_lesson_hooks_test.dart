import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/circuit/models/circuit_state.dart';
import 'package:kratos/circuit/screens/circuit_screen.dart';
import 'package:kratos/circuit/widgets/component_icon.dart';
import 'package:kratos/common/controls/kratos_combo_box.dart';

/// T-P1-06 · CircuitScreen 剧本钩子接线测试（AC-18 接线 1/2）。
///
/// 注意（既有缺陷 · zz_min_repro 实证 2026-08-25）：CircuitScreen 在同一
/// 测试文件内第二次实例化时 _loadDefaultScenario 挂起（rootBundle 可直读
/// 但 manager.loadScenarios 不完成）——**每个测试文件只允许 1 个
/// CircuitScreen 用例**。AC-R1 / Major-3 用例拆到独立文件：
/// - circuit_lesson_hooks_r1_test.dart（无 inquiryTask 场景行为不变）
/// - circuit_lesson_hooks_r1_inquiry_test.dart（探案场景 Snackbar 回归）
/// - circuit_lesson_menu_gate_test.dart（Major-3 场景菜单门控）
void main() {
  testWidgets('AC-8 联动/D4 · 传 onScenarioSuccess → 合闸达成 circuitClosed → 钩子触发一次',
      (tester) async {
    // 注（代码评审 Major-2 · 2026-08-25）：本用例实为 D4 钩子接线 +
    // AC-8（场景完成→完成事件），原误标 AC-18（点击入口进入 entry 场景）
    // ——AC-18 已由 lesson_entry_test 的 _launch 全链路用例承担。
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    var calls = 0;
    await tester.pumpWidget(MaterialApp(
      home: CircuitScreen(onScenarioSuccess: () => calls++),
    ));

    // 等场景管理器加载（AppBar 下拉出现即完成）
    for (var i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(KratosComboBox<String>).evaluate().isNotEmpty) break;
    }
    expect(find.byType(KratosComboBox<String>), findsOneWidget);

    // 切到 controlled-switch
    await tester.tap(find.byType(KratosComboBox<String>));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('开关控制电路').last);
    await tester.pump(const Duration(milliseconds: 300));

    // tap 开关图标中心选中（IgnorePointer 穿透命中；single-tap 回调需等
    // 300ms 双击窗口超时）→ AppBar「切换」按钮 → 合闸
    final switchIcon = find.byWidgetPredicate(
      (w) => w is ComponentIconWidget && w.type == ComponentType.switch_,
    );
    expect(switchIcon, findsOneWidget);
    await tester.tapAt(tester.getCenter(switchIcon));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byTooltip('切换'));
    await tester.pump();

    expect(calls, 1, reason: '合闸后 circuitClosed 判定满足，钩子应触发一次');

    // 再次切换（断开→闭合，幂等：一次成功只外发一次）
    await tester.tap(find.byTooltip('切换'));
    await tester.pump();
    await tester.tap(find.byTooltip('切换'));
    await tester.pump();
    expect(calls, 1);
  });
}
