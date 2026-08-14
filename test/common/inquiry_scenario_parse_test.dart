import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/forces/config/forces_scenario.dart';
import 'package:kratos/optics/config/lab_scenario.dart';
import 'package:kratos/radio_waves/config/radio_waves_scenario.dart';
import 'package:kratos/sound/config/sound_scenario.dart';
import 'package:kratos/wave_interference/config/wave_interference_scenario.dart';

/// 5 sim 推广需求：scenario model 解析 inquiryTask（AC 向后兼容 + 新字段）。
///
/// 用内联 JSON 绕开 rootBundle（fake async 下真实 IO 可能挂起）。
void main() {
  Map<String, dynamic> base(String scenarioId, [Map<String, dynamic> extra = const {}]) =>
      {'scenarioId': scenarioId, 'name': scenarioId, ...extra};

  const inquiryJson = {
    'question': '测试问题',
    'steps': [
      {'id': 's1', 'instruction': '步骤一'},
    ],
    'referenceConclusion': '参考结论',
    'snapshotColumns': [
      {'key': 'a', 'label': 'A', 'source': 'param'},
      {'key': 'b', 'label': 'B'},
    ],
    'predictions': [
      {
        'id': 'p1',
        'question': '电阻增大电流会?',
        'options': ['增大', '减小', '不变'],
        'answer': 1,
        'explanation': '欧姆定律',
      },
    ],
  };

  // 旧 JSON 无 predictions 字段 → 向后兼容（默认空）
  const legacyInquiryJson = {
    'question': '旧问题',
    'steps': [
      {'id': 's1', 'instruction': '步骤一'},
    ],
  };

  test('ForcesScenario 解析 inquiryTask + 向后兼容', () {
    final s = ForcesScenario.fromJson(
      base('f1', {'mode': 'netForce', 'inquiryTask': inquiryJson}));
    expect(s.inquiryTask, isNotNull);
    expect(s.inquiryTask!.question, '测试问题');
    expect(s.inquiryTask!.steps, hasLength(1));
    expect(s.inquiryTask!.referenceConclusion, '参考结论');
    expect(s.inquiryTask!.snapshotColumns, hasLength(2));
    expect(s.inquiryTask!.snapshotColumns.first.source, 'param');

    // req-predictive-inquiry：predictions 解析
    expect(s.inquiryTask!.predictions, hasLength(1));
    expect(s.inquiryTask!.predictions.first.id, 'p1');
    expect(s.inquiryTask!.predictions.first.options, ['增大', '减小', '不变']);
    expect(s.inquiryTask!.predictions.first.answer, 1);
    expect(s.inquiryTask!.predictions.first.explanation, '欧姆定律');

    // 无 inquiryTask 不崩
    final old = ForcesScenario.fromJson(base('f2', {'mode': 'motion'}));
    expect(old.inquiryTask, isNull);

    // 旧 JSON 无 predictions → 默认空列表（向后兼容）
    final legacy = ForcesScenario.fromJson(
      base('f3', {'mode': 'netForce', 'inquiryTask': legacyInquiryJson}));
    expect(legacy.inquiryTask!.predictions, isEmpty);
  });

  test('LabScenario(optics) 解析 inquiryTask + 向后兼容', () {
    final s = LabScenario.fromJson(base('o1', {
      'description': 'd',
      'version': '1.0',
      'level': 'intro',
      'domain': 'lens',
      'inventory': {'components': []},
      'initialLayout': [],
      'constraints': [],
      'ui': {'showGrid': true},
      'inquiryTask': inquiryJson,
    }));
    expect(s.inquiryTask, isNotNull);
    expect(s.inquiryTask!.question, '测试问题');

    final old = LabScenario.fromJson(base('o2', {
      'description': 'd',
      'version': '1.0',
      'level': 'intro',
      'domain': 'lens',
      'inventory': {'components': []},
      'initialLayout': [],
      'constraints': [],
      'ui': {'showGrid': true},
    }));
    expect(old.inquiryTask, isNull);
  });

  test('SoundScenario 解析 inquiryTask + 向后兼容', () {
    final s = SoundScenario.fromJson(
      base('so1', {'inquiryTask': inquiryJson}));
    expect(s.inquiryTask, isNotNull);
    expect(s.inquiryTask!.snapshotColumns, hasLength(2));

    final old = SoundScenario.fromJson(base('so2'));
    expect(old.inquiryTask, isNull);
  });

  test('RadioWavesScenario 解析 inquiryTask + 向后兼容', () {
    final s = RadioWavesScenario.fromJson(
      base('r1', {'inquiryTask': inquiryJson}));
    expect(s.inquiryTask, isNotNull);
    expect(s.inquiryTask!.steps, hasLength(1));

    final old = RadioWavesScenario.fromJson(base('r2'));
    expect(old.inquiryTask, isNull);
  });

  test('WaveInterferenceScenario 解析 inquiryTask + 向后兼容', () {
    final s = WaveInterferenceScenario.fromJson(
      base('w1', {'inquiryTask': inquiryJson}));
    expect(s.inquiryTask, isNotNull);
    expect(s.inquiryTask!.referenceConclusion, '参考结论');

    final old = WaveInterferenceScenario.fromJson(base('w2'));
    expect(old.inquiryTask, isNull);
  });
}
