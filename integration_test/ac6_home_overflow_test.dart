// integration_test/ac6_home_overflow_test.dart
// req-ui-interaction-polish AC-6 · 主会话直接产出
//
// 验证 HomeScreen -> ColorVisionHome 导航链在 1600x900 视口无 RenderFlex overflow。
// 背景：req-home-screen-overflow-fix 存桩记录该链曾存在 offset(715,0) 130x139 Column overflow，
//       color_vision_test.dart 因之绕过导航链直接挂载 SingleBulbScreen（见该文件 L17-22）。
// 本测试重挂 KratosApp 整链，实证 HomeScreen 重写 + ColorVisionHome 现状是否已消除病灶。
//
// 注意：color_vision 有常驻 60fps SimulationClock → pumpAndSettle 永不返回，
//       进入 ColorVisionHome 后用 pump(Duration) 手动推进帧（同 color_vision_test.dart L14-15）。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kratos/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(WidgetTester tester) async {
    for (int i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('AC-6: HomeScreen -> ColorVisionHome no overflow at 1600x900', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const KratosApp());
    await tester.pumpAndSettle();

    // 主界面自身无 overflow
    expect(
      tester.takeException(),
      isNull,
      reason: 'HomeScreen must have no overflow at 1600x900 (AC-6.1)',
    );

    // 进入色觉 sim（物理-光学与波动组卡片）
    final colorCard = find.text('色觉');
    expect(colorCard, findsOneWidget);
    await tester.ensureVisible(colorCard);
    await tester.pump();
    await tester.tap(colorCard);
    await settle(tester);

    // 整链无 overflow（原 offset(715,0) 130x139 Column 病灶）
    expect(
      tester.takeException(),
      isNull,
      reason:
          'HomeScreen -> ColorVisionHome chain must have no overflow (AC-6.1/6.2)',
    );
  });
}
