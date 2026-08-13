import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

import 'package:kratos/color_vision/config/color_vision_scenario.dart';
import 'package:kratos/color_vision/config/color_vision_scenario_manager.dart';
import 'package:kratos/color_vision/model/color_vision_state.dart';
import 'package:kratos/color_vision/solver/photon_beam.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CVChallengeConfig 解析（AC-2.2 / AC-4.x）', () {
    test('rgb-challenge-basic.json 解析 challenge 配置', () async {
      final jsonStr = await rootBundle.loadString('assets/scenarios/color-vision/rgb-challenge-basic.json');
      final scenario = ColorVisionScenario.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);

      final cfg = scenario.challenge;
      expect(cfg, isNotNull);
      expect(cfg!.enabled, isTrue);
      expect(cfg.mode, 'colorMatch');
      expect(cfg.difficulty, 'easy');
      expect(cfg.timeLimit, 30);
      expect(cfg.timeBonusPerLevel, 5);
      expect(cfg.accuracyThreshold, 95.0);
      expect(cfg.targets.length, 3);
      expect(cfg.randomTargets, isNotNull);
      expect(cfg.randomTargets!.excludeGrayscale, isTrue);
    });

    test('rgb-default.json 已补 challenge（targets 3 个）', () async {
      final jsonStr = await rootBundle.loadString('assets/scenarios/color-vision/rgb-default.json');
      final scenario = ColorVisionScenario.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
      expect(scenario.challenge, isNotNull);
      expect(scenario.challenge!.targets.length, 3);
    });

    test('无 challenge 字段旧 JSON 向后兼容（challenge == null）', () {
      const jsonStr = '''
{
  "scenarioId": "legacy",
  "name": "legacy",
  "version": "1.0",
  "screen": "rgb",
  "initialParams": {"redIntensity": 100, "greenIntensity": 0, "blueIntensity": 0}
}''';
      final scenario = ColorVisionScenario.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
      expect(scenario.challenge, isNull);
      expect(scenario.inquiryTask, isNull);
    });

    test('CVTargetColor.toColor 解析 hex 色值', () {
      const t = CVTargetColor(color: '#FFFF00', label: '黄色');
      expect(t.toColor(), const Color(0xFFFFFF00));
    });
  });

  group('CVCriterionConfig.check + checkObjectives（AC-4.4）', () {
    ColorVisionState state(double r, double g, double b) {
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

    test('colorMatch criterion: 黄色目标在 R+G 下达成', () {
      const c = CVCriterionConfig(
        id: 'sc-1',
        type: 'colorMatch',
        description: 'Produce yellow',
        params: {'targetColor': 'yellow'},
      );
      expect(c.check(state(100, 100, 0)), isTrue);
      expect(c.check(state(100, 0, 100)), isFalse);
    });

    test('checkObjectives: 全部 successCriteria 达成才返回 true', () async {
      final mgr = ColorVisionScenarioManager();
      await mgr.loadScenarios();

      // rgb-make-white：sc-1 = 白光（tolerance 5）· 单目标
      mgr.loadScenario('rgb-make-white');
      expect(mgr.checkObjectives(state(100, 100, 100)), isTrue);
      expect(mgr.checkObjectives(state(100, 0, 0)), isFalse);

      // rgb-default：黄/品红/青三目标不可同时达成 → 整体恒 false
      mgr.loadScenario('rgb-default');
      expect(mgr.checkObjectives(state(100, 100, 0)), isFalse);
      expect(mgr.checkObjectives(state(100, 100, 100)), isFalse);

      // 无 scenario 时返回 false
      final empty = ColorVisionScenarioManager();
      expect(empty.checkObjectives(state(100, 100, 100)), isFalse);
    });
  });
}
