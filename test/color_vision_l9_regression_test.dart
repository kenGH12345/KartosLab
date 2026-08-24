import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/color_vision/config/color_vision_scenario.dart';
import 'package:kratos/color_vision/config/color_vision_scenario_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('L9 regression: all 10 scenarios load and pass schema validation', () async {
    final mgr = ColorVisionScenarioManager();
    await mgr.loadScenarios();

    expect(mgr.scenarios.length, 11, reason: '8 L9 场景 + req-inquiry-learning 新增 rgb-inquiry-additive / rgb-challenge-basic + req-single-bulb-inquiry 新增 single-inquiry-subtractive');

    for (final s in mgr.scenarios) {
      // Verify each field populates correctly
      expect(s.scenarioId, isNotEmpty);
      expect(s.name, isNotEmpty);
      expect(s.screen, anyOf(CVScreen.rgb, CVScreen.singleBulb));

      // Verify intensities are in valid range
      expect(s.redIntensity, inInclusiveRange(0, 100));
      expect(s.greenIntensity, inInclusiveRange(0, 100));
      expect(s.blueIntensity, inInclusiveRange(0, 100));

      // Verify filterType is a known value
      expect(s.filterType, anyOf('none', 'red', 'green', 'blue', 'custom'));

      // Verify customFilter values are in range if filterType is custom
      if (s.filterType == 'custom') {
        expect(s.customFilterR, inInclusiveRange(0, 1));
        expect(s.customFilterG, inInclusiveRange(0, 1));
        expect(s.customFilterB, inInclusiveRange(0, 1));
      }

      debugPrint('PASS: ${s.scenarioId} (screen=${s.screen.name})');
    }
  });

  test('L9 regression: specific scenario checks', () async {
    final mgr = ColorVisionScenarioManager();
    await mgr.loadScenarios();

    // rgb-yellow-only: blue should be 0
    final yellow = mgr.findById('rgb-yellow-only');
    expect(yellow, isNotNull);
    expect(yellow!.blueIntensity, 0);

    // rgb-dark-room: all intensities 0
    final dark = mgr.findById('rgb-dark-room');
    expect(dark, isNotNull);
    expect(dark!.redIntensity, 0);
    expect(dark.greenIntensity, 0);
    expect(dark.blueIntensity, 0);

    // single-custom-yellow-filter: should have custom pass rates
    final custom = mgr.findById('single-custom-yellow-filter');
    expect(custom, isNotNull);
    expect(custom!.filterType, 'custom');
    expect(custom.customFilterR, 0.5);
    expect(custom.customFilterG, 0.5);
    expect(custom.customFilterB, 0);

    debugPrint('All specific scenario checks passed');
  });

  test('L9 regression: successCriteria and hints parsing', () async {
    final mgr = ColorVisionScenarioManager();
    await mgr.loadScenarios();

    for (final s in mgr.scenarios) {
      for (final sc in s.successCriteria) {
        for (final leaf in sc.collectLeaves()) {
          expect(leaf.id, isNotEmpty);
          expect(leaf.type, anyOf('colorMatch', 'filterPassed', 'intensityReached'));
        }
      }
      for (final h in s.hints) {
        expect(h.trigger, isNotEmpty);
        expect(h.message, isNotEmpty);
      }
    }
    debugPrint('All successCriteria and hints parse correctly');
  });

  test('req-inquiry-learning: new scenarios parse inquiryTask and challenge', () async {
    final mgr = ColorVisionScenarioManager();
    await mgr.loadScenarios();

    // rgb-inquiry-additive: 探究任务齐全
    final inquiry = mgr.findById('rgb-inquiry-additive');
    expect(inquiry, isNotNull);
    expect(inquiry!.inquiryTask, isNotNull);
    expect(inquiry.inquiryTask!.question, isNotEmpty);
    expect(inquiry.inquiryTask!.steps.length, 3);
    expect(inquiry.inquiryTask!.referenceConclusion, isNotNull);
    expect(inquiry.inquiryTask!.snapshotColumns.length, 4);

    // rgb-challenge-basic: challenge 配置齐全
    final challenge = mgr.findById('rgb-challenge-basic');
    expect(challenge, isNotNull);
    expect(challenge!.challenge, isNotNull);
    expect(challenge.challenge!.enabled, isTrue);
    expect(challenge.challenge!.timeLimit, 30);
    expect(challenge.challenge!.accuracyThreshold, 95.0);
    expect(challenge.challenge!.targets.length, 3);
    expect(challenge.challenge!.randomTargets, isNotNull);

    // rgb-default: challenge 已补充
    final def = mgr.findById('rgb-default');
    expect(def, isNotNull);
    expect(def!.challenge, isNotNull);
    expect(def.challenge!.targets.length, 3);

    // 旧场景无新字段不崩（向后兼容）
    final old = mgr.findById('single-white-red-filter');
    expect(old, isNotNull);
    expect(old!.inquiryTask, isNull);
    expect(old.challenge, isNull);
  });
}
