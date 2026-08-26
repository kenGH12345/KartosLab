// test/color_vision/rgb_explore_hook_test.dart
// 代码评审 Blocker-1 T1 补测（2026-08-25）：rgb 探索模式强度变化 →
// checkObjectives 满足 → onScenarioSuccess 外发一次（纯探索场景可完成）。
//
// 实现约束（magic_lab_ac44_test.dart 先例）：
// - 场景用内联 JSON 构造（rootBundle 真实 IO 在 fake async 测试可能挂起）
// - MagicLabScreen 的 _bubbleTicker 持续 tick → 固定帧 pump + 结束卸载树
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/color_vision/config/color_vision_scenario.dart';
import 'package:kratos/color_vision/config/color_vision_scenario_manager.dart';
import 'package:kratos/color_vision/screens/rgb_bulbs_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ColorVisionScenario whiteScenario() => ColorVisionScenario.fromJson({
        'scenarioId': 'rgb-explore-hook',
        'name': '探索钩子测试',
        'version': '1.0',
        'screen': 'rgb',
        'initialParams': {
          'redIntensity': 100,
          'greenIntensity': 100,
          'blueIntensity': 0,
          'personPosition': 300,
        },
        // 单一 white 目标（可满足 · 与修复后的 rgb-yellow-only 同构）
        'successCriteria': [
          {
            'id': 'sc-1',
            'type': 'colorMatch',
            'description': '调出白光',
            'params': {'targetColor': 'white'},
          },
        ],
      });

  Future<void> teardown(WidgetTester tester) async {
    // 卸载树停 _bubbleTicker（单测末尾必须有，否则 pending timer 报错）
    await tester.pumpWidget(const SizedBox());
  }

  testWidgets('Blocker-1 T1 · 探索模式拖 B 滑块到 100（白光）→ 钩子外发一次',
      (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final scenario = whiteScenario();
    final mgr = ColorVisionScenarioManager()..setCurrentScenario(scenario);
    var calls = 0;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MagicLabScreen(
          scenario: scenario,
          scenarioList: const [],
          manager: mgr,
          onScenarioSuccess: () => calls++,
        ),
      ),
    ));
    await tester.pump();

    // 探索模式默认三个 RGB 滑块（R/G 初始 100，B 初始 0）。
    // 直接调用第三个（B）Slider 的 onChanged=100（绕过 hit test——布局遮挡
    // 下直接验证接线点 · Blocker-1 修复即在此回调内接入判定）
    expect(find.byType(Slider), findsNWidgets(3));
    tester.widget<Slider>(find.byType(Slider).at(2)).onChanged!(100);
    await tester.pump();
    await tester.pump();

    expect(calls, 1, reason: '探索模式达成判定应外发一次完成信号');

    // 幂等：满足后继续调 R → 仍 1（_objectivesMetNotified 门控）
    tester.widget<Slider>(find.byType(Slider).at(0)).onChanged!(50);
    await tester.pump();
    await tester.pump();
    expect(calls, 1);

    await teardown(tester);
  });

  testWidgets('Blocker-1 T1 · 不满足判定时钩子不触发（探索模式 B 保持 0）',
      (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final scenario = whiteScenario();
    final mgr = ColorVisionScenarioManager()..setCurrentScenario(scenario);
    var calls = 0;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MagicLabScreen(
          scenario: scenario,
          scenarioList: const [],
          manager: mgr,
          onScenarioSuccess: () => calls++,
        ),
      ),
    ));
    await tester.pump();

    // 仅调 R（100→50），B 仍 0 → (50,100,0) 非白 → 不触发
    tester.widget<Slider>(find.byType(Slider).at(0)).onChanged!(50);
    await tester.pump();
    await tester.pump();
    expect(calls, 0, reason: '未达成判定不触发完成信号');

    await teardown(tester);
  });
}
