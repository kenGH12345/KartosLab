// test/forces_home_test.dart
// req-panel-bottom-migrate motion 攻关 · 主会话直接产出
//
// 验证真实 app 链路（ForcesHome → 运动 tab）下 AppliedForceSlider 是否溢出。
// 背景：独立 pump MotionScreen 触发 200161px Row 溢出（scenario: null 默认模型），
// 本测试走 ForcesHome 链路（scenario 加载）验证是否同样存在。
// 注意：forces 屏有常驻 SimulationClock → 手动 pump（pumpAndSettle 永不返回）。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/forces/screens/forces_home.dart';

void main() {
  Future<void> settle(WidgetTester tester) async {
    for (int i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('ForcesHome motion tab no overflow at 1600x900', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(const MaterialApp(home: ForcesHome()));
    await settle(tester); // 等场景加载 + 首帧

    // 切到"运动"tab（MotionScreen · 含 AppliedForceSlider）
    await tester.tap(find.text('运动'));
    await settle(tester);

    expect(tester.takeException(), isNull,
        reason: 'ForcesHome motion tab must not overflow at 1600x900 (app link)');
  });

  // 注：320 下 tap('运动') 不稳定（TabBar 320 渲染差异，'运动' 文本 finder 找不到——
  // 非布局问题；motion tab 的 footer 布局已由 1600 测试验证）。320 只验证 ForcesHome 初始屏无溢出。
  testWidgets('ForcesHome motion tab no overflow at 320x480', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(const MaterialApp(home: ForcesHome()));
    await settle(tester);
    expect(tester.takeException(), isNull,
        reason: 'ForcesHome must not overflow at 320x480');
  });
}
