import 'dart:convert';
import 'dart:ui' show Color;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/color_vision/config/color_vision_scenario.dart';
import 'package:kratos/color_vision/config/color_vision_scenario_manager.dart';
import 'package:kratos/color_vision/model/color_vision_state.dart';
import 'package:kratos/color_vision/screens/rgb_bulbs_screen.dart';
import 'package:kratos/color_vision/solver/photon_beam.dart';

ColorVisionState _state(double r, double g, double b) {
  final beams = <PhotonBeam>[
    PhotonBeam(color: const Color(0xFFFF0000), originX: 0, originY: 0, maxDistance: 100),
    PhotonBeam(color: const Color(0xFF00FF00), originX: 0, originY: 0, maxDistance: 100),
    PhotonBeam(color: const Color(0xFF0000FF), originX: 0, originY: 0, maxDistance: 100),
  ];
  final s = ColorVisionState(beams: beams, redIntensity: r, greenIntensity: g, blueIntensity: b);
  beams[0].setIntensity(r);
  beams[1].setIntensity(g);
  beams[2].setIntensity(b);
  return s;
}

/// AC-4.4 触发链路：MagicLabScreen 初始化/切场景时必须同步 manager.currentScenario，
/// 否则 checkObjectives 恒 false（Blocker 回归测试）。
///
/// 实现约束：
/// - 场景用内联 JSON 构造（不调用 manager.loadScenarios —— rootBundle 真实 IO
///   在 fake async 测试里可能挂起，且 loadScenarios 与 checkObjectives 链路无关）
/// - MagicLabScreen 的 _bubbleTicker 持续 tick → 只用固定帧 pump + 结束卸载树
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ColorVisionScenario scenarioFromJson(String scenarioId, String name, String jsonBody) =>
      ColorVisionScenario.fromJson({
        ...jsonDecode(jsonBody) as Map<String, dynamic>,
        'scenarioId': scenarioId,
        'name': name,
      });

  ColorVisionScenario challengeBasic() => scenarioFromJson('rgb-challenge-basic', '颜色匹配挑战 · 初级', '''
{
  "screen": "rgb",
  "challenge": {
    "enabled": true, "mode": "colorMatch", "difficulty": "easy",
    "timeLimit": 30, "timeBonusPerLevel": 5, "accuracyThreshold": 95.0,
    "targets": [ {"color": "#FFFF00", "label": "黄色（红+绿）"} ],
    "randomTargets": {"enabled": true, "count": 5, "excludeGrayscale": true}
  },
  "successCriteria": [
    {"id": "sc-1", "type": "colorMatch", "description": "匹配出黄色", "params": {"targetColor": "yellow", "tolerance": 30}}
  ]
}''');

  ColorVisionScenario inquiryAdditive() => scenarioFromJson('rgb-inquiry-additive', '加色混合探究', '''
{
  "screen": "rgb",
  "inquiryTask": {
    "question": "红绿蓝两两组合得到什么颜色？",
    "steps": [],
    "referenceConclusion": "红+绿=黄"
  }
}''');

  Future<ColorVisionScenarioManager> pumpLab(
    WidgetTester tester, {
    ColorVisionScenario? initial,
  }) async {
    final mgr = ColorVisionScenarioManager();
    final scenarios = <ColorVisionScenario>[challengeBasic(), inquiryAdditive()];
    final init = initial ?? scenarios.first;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MagicLabScreen(scenario: init, scenarioList: scenarios, manager: mgr),
      ),
    ));
    return mgr;
  }

  /// 卸载 widget 树并推进一帧，确保 ticker dispose 完成。
  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 20));
  }

  testWidgets('initState 同步 manager.currentScenario（AC-4.4）', (tester) async {
    final mgr = await pumpLab(tester);
    expect(mgr.currentScenario, isNotNull);
    expect(mgr.currentScenario!.scenarioId, 'rgb-challenge-basic');
    expect(mgr.currentScenario!.successCriteria, isNotEmpty);
    await teardown(tester);
  });

  testWidgets('场景切换后 manager.currentScenario 跟随更新（AC-4.4）', (tester) async {
    final mgr = await pumpLab(tester);
    expect(mgr.currentScenario!.scenarioId, 'rgb-challenge-basic');

    // 场景菜单在 topRight 独立格
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('加色混合探究').last, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(mgr.currentScenario, isNotNull);
    expect(mgr.currentScenario!.scenarioId, 'rgb-inquiry-additive');
    await teardown(tester);
  });

  testWidgets('rgb-challenge-basic 完成黄色匹配 → checkObjectives 全达成（AC-4.4）', (tester) async {
    final mgr = await pumpLab(tester);
    expect(mgr.currentScenario!.scenarioId, 'rgb-challenge-basic');
    expect(mgr.checkObjectives(_state(100, 100, 0)), isTrue);
    expect(mgr.checkObjectives(_state(0, 0, 100)), isFalse);
    await teardown(tester);
  });
}
