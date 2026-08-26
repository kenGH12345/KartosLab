import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/common/scenario/lesson_plan.dart';
import 'package:kratos/common/scenario/success_condition.dart';

/// T-P1-02 · lesson_plan.dart 单测（正例 + 逐规则反例）。
///
/// scenarioPlayable 桩：circuit 的 4 个试点场景可完成；'rgb-dark-room'
/// 模拟「存在但不可完成」（无 objectives/未实现叶子，D10）；其余一律 false。
void main() {
  bool playable(String sim, String scenarioId) {
    if (sim == 'circuit') {
      return const {
        'simple-series',
        'open-circuit-debug',
        'controlled-switch',
        'fuse-blown',
      }.contains(scenarioId);
    }
    return false;
  }

  LessonPlan parse(Map<String, dynamic> json) =>
      LessonPlan.fromJson(json, scenarioPlayable: playable);

  /// 方案 §6.2 条件剧本 JSON 全文（routes + unlock + any 组合 + 两叶子）。
  Map<String, dynamic> ohmDiagnosisJson() => {
        'lessonId': 'circuit-ohm-diagnosis',
        'name': '欧姆定律与电路诊断',
        'version': '1.0',
        'description': '欧姆定律探究 → 按预测表现分流挑战/复习 → 汇合观察保险丝保护',
        'entry': 'n1',
        'nodes': [
          {
            'id': 'n1',
            'title': '欧姆定律探究（含预测）',
            'scenario': {'sim': 'circuit', 'scenarioId': 'simple-series'},
            'unlock': null,
            'advance': {
              'type': 'routes',
              'routes': [
                <String, dynamic>{
                  'to': 'n2-hunt',
                  'when': {
                    'id': 'g-1',
                    'description': '预测正确率≥50%',
                    'type': 'predictionScore',
                    'params': {
                      'nodeId': 'n1',
                      'metric': 'ratio',
                      'operator': 'gte',
                      'threshold': 0.5,
                    },
                  },
                },
                <String, dynamic>{'to': 'n2-review', 'when': null},
              ],
            },
          },
          {
            'id': 'n2-hunt',
            'title': '电路诊断挑战（表现优秀）',
            'scenario': {'sim': 'circuit', 'scenarioId': 'open-circuit-debug'},
            'unlock': {
              'id': 'u-1',
              'description': '完成欧姆定律探究',
              'type': 'nodeCompleted',
              'params': {'nodeId': 'n1'},
            },
            'advance': {'type': 'onCompleted', 'to': 'n3'},
          },
          {
            'id': 'n2-review',
            'title': '开关控制复习（待巩固）',
            'scenario': {'sim': 'circuit', 'scenarioId': 'controlled-switch'},
            'unlock': {
              'id': 'u-2',
              'description': '完成欧姆定律探究',
              'type': 'nodeCompleted',
              'params': {'nodeId': 'n1'},
            },
            'advance': {'type': 'onCompleted', 'to': 'n3'},
          },
          {
            'id': 'n3',
            'title': '观察保险丝的保护作用',
            'scenario': {'sim': 'circuit', 'scenarioId': 'fuse-blown'},
            'unlock': {
              'id': 'u-3',
              'description': '完成任一分流节点',
              'any': [
                {
                  'id': 'u-3a',
                  'type': 'nodeCompleted',
                  'description': '完成挑战线',
                  'params': {'nodeId': 'n2-hunt'},
                },
                {
                  'id': 'u-3b',
                  'type': 'nodeCompleted',
                  'description': '完成复习线',
                  'params': {'nodeId': 'n2-review'},
                },
              ],
            },
            'advance': {'type': 'onCompleted', 'to': 'n-end'},
          },
          {
            'id': 'n-end',
            'title': '课时完成',
            'scenario': null,
            'unlock': null,
            'advance': null,
          },
        ],
      };

  /// 最小线性剧本（3 节点 + 终点），供反例用例做局部变异。
  Map<String, dynamic> linearJson() => {
        'lessonId': 'linear-lesson',
        'name': '线性课时',
        'version': '1.0',
        'description': '线性',
        'entry': 'a',
        'nodes': [
          {
            'id': 'a',
            'title': 'A',
            'scenario': {'sim': 'circuit', 'scenarioId': 'controlled-switch'},
            'advance': {'type': 'next'},
          },
          <String, dynamic>{
            'id': 'b',
            'title': 'B',
            'scenario': {'sim': 'circuit', 'scenarioId': 'open-circuit-debug'},
            'advance': {'type': 'onCompleted', 'to': 'n-end'},
          },
          <String, dynamic>{
            'id': 'n-end',
            'title': '完',
            'scenario': null,
            'advance': null,
          },
        ],
      };

  group('LessonPlan.fromJson · 正例（AC-1）', () {
    test('§6.2 条件剧本全文解析——routes/unlock/any 组合/两叶子全字段可访问', () {
      final plan = parse(ohmDiagnosisJson());
      expect(plan.lessonId, 'circuit-ohm-diagnosis');
      expect(plan.name, '欧姆定律与电路诊断');
      expect(plan.version, '1.0');
      expect(plan.entry, 'n1');
      expect(plan.nodes, hasLength(5));

      final n1 = plan.entryNode;
      expect(n1.scenario!.sim, 'circuit');
      expect(n1.scenario!.scenarioId, 'simple-series');
      expect(n1.advance!.type, 'routes');
      expect(n1.advance!.routes, hasLength(2));
      expect(n1.advance!.routes![0].to, 'n2-hunt');
      expect(n1.advance!.routes![0].when, isA<LeafCondition>());
      final leaf = n1.advance!.routes![0].when! as LeafCondition;
      expect(leaf.type, 'predictionScore');
      expect(leaf.params['nodeId'], 'n1');
      expect(leaf.params['metric'], 'ratio');
      expect(leaf.params['operator'], 'gte');
      expect(leaf.params['threshold'], 0.5);
      expect(n1.advance!.routes![1].when, isNull); // 兜底路由

      final n3 = plan.find('n3')!;
      expect(n3.unlock, isA<AnyCondition>());
      expect(n3.unlock!.collectLeaves(), hasLength(2));
      expect(n3.advance!.type, 'onCompleted');
      expect(n3.advance!.to, 'n-end');

      final end = plan.find('n-end')!;
      expect(end.isEnd, isTrue);
      expect(end.advance, isNull);

      // 辅助 API
      expect(plan.requiredNodes, hasLength(4));
      expect(plan.totalRequiredNodes, 4);
      // nextInOrder 是纯数组位置语义（与 advance.type 无关）
      expect(plan.nextInOrder('n1')!.id, 'n2-hunt');
      expect(plan.nextInOrder('n-end'), isNull); // 末位无后继
      expect(plan.find('missing'), isNull);
    });
  });

  group('LessonPlan.fromJson · 反例（均抛 FormatException 且消息含 lessonId）', () {
    void expectLessonIdError(Map<String, dynamic> json, String lessonId,
        [Pattern? reason]) {
      expect(
        () => parse(json),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          reason == null
              ? startsWith(lessonId)
              : allOf(startsWith(lessonId), contains(reason)),
        )),
      );
    }

    test('AC-2 · entry 悬空', () {
      final json = linearJson();
      json['entry'] = 'ghost';
      expectLessonIdError(json, 'linear-lesson', 'entry');
    });

    test('AC-3 · 引用不存在场景（scenarioPlayable 返回 false）', () {
      final json = linearJson();
      (json['nodes'] as List)[0]['scenario'] = {
        'sim': 'circuit',
        'scenarioId': 'not-exist',
      };
      expectLessonIdError(json, 'linear-lesson', 'not-exist');
    });

    test('D10 · 引用不可完成场景（无 objectives / 未实现叶子 → false）', () {
      final json = linearJson();
      (json['nodes'] as List)[0]['scenario'] = {
        'sim': 'color_vision',
        'scenarioId': 'rgb-dark-room', // 桩中不可完成（D10）
      };
      expectLessonIdError(json, 'linear-lesson', 'rgb-dark-room');
    });

    test('AC-4 · onCompleted.to 悬空', () {
      final json = linearJson();
      (json['nodes'] as List)[1]['advance'] = {
        'type': 'onCompleted',
        'to': 'ghost',
      };
      expectLessonIdError(json, 'linear-lesson', 'ghost');
    });

    test('AC-4 · routes.to 悬空', () {
      final json = ohmDiagnosisJson();
      (((json['nodes'] as List)[0]['advance'] as Map)['routes'] as List)[0]
          ['to'] = 'ghost';
      expectLessonIdError(json, 'circuit-ohm-diagnosis', 'ghost');
    });

    test('AC-5 · 从 entry 不可达的孤立节点', () {
      final json = linearJson();
      // 插到 b 之后、n-end 之前——a→next→b，b→onCompleted→n-end，
      // orphan 无任何 incoming 引用（插到 index 1 会被 a 的 next 覆盖成可达）
      (json['nodes'] as List).insert(2, {
        'id': 'orphan',
        'title': '孤立',
        'scenario': {'sim': 'circuit', 'scenarioId': 'controlled-switch'},
        'advance': {'type': 'next'},
      });
      expectLessonIdError(json, 'linear-lesson', '不可达');
    });

    test('规则 2 · 节点 id 重复', () {
      final json = linearJson();
      (json['nodes'] as List).add({
        'id': 'a',
        'title': '重复 id',
        'scenario': {'sim': 'circuit', 'scenarioId': 'controlled-switch'},
        'advance': {'type': 'next'},
      });
      expectLessonIdError(json, 'linear-lesson', '重复');
    });

    test('规则 4 · 终点二元绑定违规：scenario=null 但 advance 非 null', () {
      final json = linearJson();
      final end = (json['nodes'] as List)[2] as Map;
      end['advance'] = {'type': 'onCompleted', 'to': 'a'};
      expectLessonIdError(json, 'linear-lesson', '终点');
    });

    test('规则 4 · 终点二元绑定违规：scenario 非 null 但 advance=null', () {
      final json = linearJson();
      final b = (json['nodes'] as List)[1] as Map;
      b['advance'] = null;
      expectLessonIdError(json, 'linear-lesson', '二元绑定');
    });

    test('规则 4 · 终点节点 unlock 非 null', () {
      final json = linearJson();
      final end = (json['nodes'] as List)[2] as Map;
      end['unlock'] = {
        'id': 'u',
        'type': 'nodeCompleted',
        'description': 'x',
        'params': {'nodeId': 'a'},
      };
      expectLessonIdError(json, 'linear-lesson', '终点');
    });

    test('AC-39 · routes 缺兜底（末项 when 非 null）', () {
      final json = ohmDiagnosisJson();
      final routes =
          (((json['nodes'] as List)[0]['advance'] as Map)['routes'] as List);
      routes[1]['when'] = {
        'id': 'g-2',
        'type': 'nodeCompleted',
        'description': 'x',
        'params': {'nodeId': 'n1'},
      };
      expectLessonIdError(json, 'circuit-ohm-diagnosis', '兜底');
    });

    test('D7 · routes 中间项 when=null', () {
      final json = ohmDiagnosisJson();
      final routes =
          (((json['nodes'] as List)[0]['advance'] as Map)['routes'] as List);
      routes[0]['when'] = null;
      expectLessonIdError(json, 'circuit-ohm-diagnosis', '仅允许末项');
    });

    test('规则 6 · advance.type 非法值', () {
      final json = linearJson();
      (json['nodes'] as List)[0]['advance'] = {'type': 'teleport', 'to': 'b'};
      expectLessonIdError(json, 'linear-lesson', 'teleport');
    });

    test('规则 6 · next 在数组末位（无后继）', () {
      final json = linearJson();
      (json['nodes'] as List)[1]['advance'] = {'type': 'next'};
      // b 后是 n-end（终点），b 非末位——把 b 挪到末位构造「next 无后继」
      final nodes = json['nodes'] as List;
      final b = nodes.removeAt(1);
      nodes.add(b);
      expectLessonIdError(json, 'linear-lesson', '末位');
    });

    test('AC-32 · 条件树深度 5 层（>maxParseDepth=4）', () {
      Map<String, dynamic> deep = {
        'id': 'leaf',
        'type': 'nodeCompleted',
        'description': 'x',
        'params': {'nodeId': 'n1'},
      };
      for (var i = 0; i < 5; i++) {
        deep = {
          'id': 'g$i',
          'all': [deep],
        };
      }
      final json = ohmDiagnosisJson();
      ((json['nodes'] as List)[1] as Map)['unlock'] = deep;
      expectLessonIdError(json, 'circuit-ohm-diagnosis');
    });

    test('规则 8 · 条件叶子 nodeId 悬空', () {
      final json = ohmDiagnosisJson();
      ((json['nodes'] as List)[1] as Map)['unlock'] = {
        'id': 'u-x',
        'type': 'nodeCompleted',
        'description': '悬空引用',
        'params': {'nodeId': 'ghost'},
      };
      expectLessonIdError(json, 'circuit-ohm-diagnosis', 'ghost');
    });

    test('D1 契约 · 叶子缺 id → TypeError 被包装为 FormatException（Minor-4）', () {
      final json = ohmDiagnosisJson();
      ((json['nodes'] as List)[1] as Map)['unlock'] = {
        // 缺 id——LeafCondition.fromJson 的 `json['id'] as String` 抛 TypeError
        'type': 'nodeCompleted',
        'description': '缺 id',
        'params': {'nodeId': 'n1'},
      };
      expectLessonIdError(json, 'circuit-ohm-diagnosis');
    });

    test('D1 契约 · 叶子缺 description → TypeError 被包装为 FormatException', () {
      final json = ohmDiagnosisJson();
      ((json['nodes'] as List)[1] as Map)['unlock'] = {
        'id': 'u-x',
        'type': 'nodeCompleted',
        // 缺 description
        'params': {'nodeId': 'n1'},
      };
      expectLessonIdError(json, 'circuit-ohm-diagnosis');
    });

    test('规则 1 · 顶层缺 entry 字段', () {
      final json = linearJson();
      json.remove('entry');
      expectLessonIdError(json, 'linear-lesson', 'entry');
    });
  });
}
