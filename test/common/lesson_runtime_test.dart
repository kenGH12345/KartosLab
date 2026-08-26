import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/common/scenario/lesson_plan.dart';
import 'package:kratos/common/scenario/lesson_runtime.dart';

/// T-P1-05 · LessonRuntime 单测（P1 部分：线性流转）。
void main() {
  bool playable(String sim, String scenarioId) => true; // 全放行（纯逻辑测试）

  LessonPlan plan(List<Map<String, dynamic>> nodes, {String entry = 'a'}) {
    return LessonPlan.fromJson(
      {
        'lessonId': 'test-lesson',
        'name': '测试课时',
        'version': '1.0',
        'description': 'runtime 测试',
        'entry': entry,
        'nodes': nodes,
      },
      scenarioPlayable: playable,
    );
  }

  Map<String, dynamic> sceneNode(
          String id, String scenarioId, Map<String, dynamic> advance) =>
      {
        'id': id,
        'title': id,
        'scenario': {'sim': 'circuit', 'scenarioId': scenarioId},
        'advance': advance,
      };

  final endNode = {
    'id': 'n-end',
    'title': '完',
    'scenario': null,
    'advance': null,
  };

  group('LessonRuntime · load（AC-7）', () {
    test('load 后 current == entry，progress == 0', () {
      final p = plan([
        sceneNode('a', 's-1', {'type': 'next'}),
        sceneNode('b', 's-2', {'type': 'onCompleted', 'to': 'n-end'}),
        endNode,
      ]);
      final rt = LessonRuntime()..load(p);
      expect(rt.current, 'a');
      expect(rt.currentNode!.scenario!.scenarioId, 's-1');
      expect(rt.progress, 0);
      expect(rt.isLessonCompleted, isFalse);
      expect(rt.completed, isEmpty);
    });

    test('AC-11 · entry 即终点的单终点剧本 → load 即完成且非 crash', () {
      final p = plan([endNode], entry: 'n-end');
      final rt = LessonRuntime()..load(p);
      expect(rt.current, 'n-end');
      expect(rt.isLessonCompleted, isTrue);
      // 完成态后再触发完成事件 → 幂等无操作（不 crash）
      rt.onScenarioSuccess();
      expect(rt.isLessonCompleted, isTrue);
    });
  });

  group('LessonRuntime · 条件叶子矩阵（T-P2-01 · AC-27~33）', () {
    LessonPlan conditionPlan() => LessonPlan.fromJson(
          {
            'lessonId': 'cond-lesson',
            'name': '条件课时',
            'version': '1.0',
            'description': 'x',
            'entry': 'a',
            'nodes': [
              {
                'id': 'a',
                'title': 'A',
                'scenario': {'sim': 'circuit', 'scenarioId': 's-1'},
                'advance': {'type': 'routes', 'routes': [
                  {
                    'to': 'b',
                    'when': {
                      'id': 'g1',
                      'type': 'predictionScore',
                      'description': '预测正确率≥80%',
                      'params': {
                        'nodeId': 'a',
                        'metric': 'ratio',
                        'operator': 'gte',
                        'threshold': 0.8,
                      },
                    },
                  },
                  {'to': 'c', 'when': null},
                ]},
              },
              {
                'id': 'b',
                'title': 'B',
                'scenario': {'sim': 'circuit', 'scenarioId': 's-2'},
                'unlock': {
                  'id': 'u-b',
                  'type': 'nodeCompleted',
                  'description': '完成A',
                  'params': {'nodeId': 'a'},
                },
                'advance': {'type': 'onCompleted', 'to': 'n-end'},
              },
              {
                'id': 'c',
                'title': 'C',
                'scenario': {'sim': 'circuit', 'scenarioId': 's-3'},
                'advance': {'type': 'onCompleted', 'to': 'n-end'},
              },
              {'id': 'n-end', 'title': '完', 'scenario': null, 'advance': null},
            ],
          },
          scenarioPlayable: (_s, _) => true,
        );

    test('AC-29 · predictionScore ratio 0.8+gte：3/3 正确 → true（走 routes 分流）', () {
      final rt = LessonRuntime()..load(conditionPlan());
      rt.onPredictionResult(3, 3);
      rt.onScenarioSuccess(); // a 完成 → routes 求值
      expect(rt.current, 'b'); // ratio=1.0 ≥ 0.8 → 挑战线
    });

    test('AC-29 反例 · 2/3 正确（ratio=0.67 < 0.8）→ 走兜底', () {
      final rt = LessonRuntime()..load(conditionPlan());
      rt.onPredictionResult(3, 2);
      rt.onScenarioSuccess();
      expect(rt.current, 'c'); // 兜底路由
    });

    test('AC-33 · verified=0 → predictionScore false（走兜底）', () {
      final rt = LessonRuntime()..load(conditionPlan());
      rt.onPredictionResult(0, 0);
      rt.onScenarioSuccess();
      expect(rt.current, 'c');
    });

    test('AC-33 · 未作答（无预测记录）→ predictionScore false', () {
      final rt = LessonRuntime()..load(conditionPlan());
      rt.onScenarioSuccess(); // 从未调用 onPredictionResult
      expect(rt.current, 'c');
    });

    test('AC-28 · nodeCompleted 叶子：完成后 true（unlock 解锁）', () {
      final rt = LessonRuntime()..load(conditionPlan());
      expect(rt.isUnlocked('b'), isFalse); // a 未完成 → 锁
      rt.onScenarioSuccess(); // a 完成（routes 求值会切 current，但 completed 已含 a）
      expect(rt.isUnlocked('b'), isTrue); // nodeCompleted(a) → true
    });

    test('AC-31 · 未知叶子 type → false 不抛（fail-safe）', () {
      final plan = LessonPlan.fromJson(
        {
          'lessonId': 'alien-lesson',
          'name': 'x',
          'version': '1.0',
          'description': 'x',
          'entry': 'a',
          'nodes': [
            {
              'id': 'a',
              'title': 'A',
              'scenario': {'sim': 'circuit', 'scenarioId': 's-1'},
              'unlock': {
                'id': 'u-a',
                'type': 'alienLeaf', // 解析期不拦未知 type（规则 8 仅校验 nodeId 引用）
                'description': 'x',
                'params': {'nodeId': 'a'},
              },
              'advance': {'type': 'onCompleted', 'to': 'n-end'},
            },
            {'id': 'n-end', 'title': '完', 'scenario': null, 'advance': null},
          ],
        },
        scenarioPlayable: (_s, _) => true,
      );
      final rt = LessonRuntime()..load(plan);
      expect(rt.isUnlocked('a'), isFalse); // 未知叶子 → false 不抛（AC-31）
    });

    test('AC-30 · scenarioSuccess 叶子（显式 nodeId——unlock 场景正解）', () {
      final plan = LessonPlan.fromJson(
        {
          'lessonId': 'ss-lesson',
          'name': 'x',
          'version': '1.0',
          'description': 'x',
          'entry': 'a',
          'nodes': [
            {
              'id': 'a',
              'title': 'A',
              'scenario': {'sim': 'circuit', 'scenarioId': 's-1'},
              'unlock': {
                'id': 'u-a',
                'type': 'scenarioSuccess',
                'description': 'A 场景成功',
                'params': <String, dynamic>{'nodeId': 'a'},
              },
              'advance': {'type': 'onCompleted', 'to': 'n-end'},
            },
            {'id': 'n-end', 'title': '完', 'scenario': null, 'advance': null},
          ],
        },
        scenarioPlayable: (_s, _) => true,
      );
      final rt = LessonRuntime()..load(plan);
      // unlock 引用 scenarioSuccess(nodeId=a) → load 时未成功 → 锁
      expect(rt.isUnlocked('a'), isFalse);
      // onScenarioSuccess 完成后 → _scenarioSuccess 含 a → 解锁
      rt.onScenarioSuccess();
      expect(rt.isUnlocked('a'), isTrue);
      // 注意：缺省（无 nodeId）语义 = 运行时 current（方案 §4）——流转后
      // current 已切走，unlock 场景应始终用显式 nodeId（fail-safe 设计）
    });

    test('AC-27 · all/any/not 组合树求值（结构复用 SuccessCondition）', () {
      final plan = LessonPlan.fromJson(
        {
          'lessonId': 'tree-lesson',
          'name': 'x',
          'version': '1.0',
          'description': 'x',
          'entry': 'a',
          'nodes': [
            {
              'id': 'a',
              'title': 'A',
              'scenario': {'sim': 'circuit', 'scenarioId': 's-1'},
              // a → b（保证 b 图可达·解析期校验）
              'advance': {'type': 'onCompleted', 'to': 'b'},
            },
            {
              'id': 'b',
              'title': 'B',
              'scenario': {'sim': 'circuit', 'scenarioId': 's-2'},
              'unlock': {
                'id': 'u-b',
                'description': 'a 完成且 b 未完成（矛盾树·恒 false）',
                'all': [
                  {
                    'id': 'u-b1',
                    'type': 'nodeCompleted',
                    'description': 'x',
                    'params': {'nodeId': 'a'},
                  },
                  {
                    'id': 'u-b2',
                    'not': {
                      'id': 'u-b3',
                      'type': 'nodeCompleted',
                      'description': 'x',
                      'params': {'nodeId': 'b'},
                    },
                  },
                ],
              },
              'advance': {'type': 'onCompleted', 'to': 'n-end'},
            },
            {'id': 'n-end', 'title': '完', 'scenario': null, 'advance': null},
          ],
        },
        scenarioPlayable: (_s, _) => true,
      );
      final rt = LessonRuntime()..load(plan);
      expect(rt.isUnlocked('b'), isFalse); // all(completed(a)=false, not(completed(b))=true) → false
      rt.onScenarioSuccess(); // a 完成
      expect(rt.isUnlocked('b'), isTrue); // all(true, not(false)=true) → true
    });
  });

  Map<String, dynamic> conditionPlan2Json() => {
        'lessonId': 'routes-lesson',
        'name': 'x',
        'version': '1.0',
        'description': 'x',
        'entry': 'a',
        'nodes': [
          {
            'id': 'a',
            'title': 'A',
            'scenario': {'sim': 'circuit', 'scenarioId': 's-1'},
            'advance': {
              'type': 'routes',
              'routes': [
                {
                  'to': 'b',
                  'when': {
                    'id': 'g1',
                    'type': 'predictionScore',
                    'description': '正确率≥50%',
                    'params': {
                      'nodeId': 'a',
                      'metric': 'ratio',
                      'operator': 'gte',
                      'threshold': 0.5,
                    },
                  },
                },
                {'to': 'c', 'when': null},
              ],
            },
          },
          {
            'id': 'b',
            'title': 'B',
            'scenario': {'sim': 'circuit', 'scenarioId': 's-2'},
            'advance': {'type': 'onCompleted', 'to': 'n-end'},
          },
          {
            'id': 'c',
            'title': 'C',
            'scenario': {'sim': 'circuit', 'scenarioId': 's-3'},
            'advance': {'type': 'onCompleted', 'to': 'n-end'},
          },
          {'id': 'n-end', 'title': '完', 'scenario': null, 'advance': null},
        ],
      };

  LessonPlan conditionPlan2() => LessonPlan.fromJson(conditionPlan2Json(),
      scenarioPlayable: (_s, _) => true);

  group('LessonRuntime · routes 条件路由（T-P2-04 · AC-37/38/39）', () {
    test('AC-38 · 全 false 走末项兜底', () {
      final rt = LessonRuntime()..load(conditionPlan2());
      rt.onPredictionResult(1, 0); // ratio=0 < 0.8
      rt.onScenarioSuccess();
      expect(rt.current, 'c'); // 兜底
    });

    test('AC-37 · 按序求值首中短路（首路由命中不再看后续）', () {
      final rt = LessonRuntime()..load(conditionPlan2());
      rt.onPredictionResult(2, 2); // ratio=1 ≥ 0.5 → 首路由
      rt.onScenarioSuccess();
      expect(rt.current, 'b');
    });

    test('AC-39 关联 · 无兜底路由在解析期被拒（T-P1-01 反例已有 · 此断言关联）', () {
      final json = conditionPlan2Json();
      final routes = (json['nodes'] as List)[0]['advance']['routes'] as List;
      routes[1] = <String, dynamic>{
        'to': 'c',
        'when': {
          'id': 'g2',
          'type': 'nodeCompleted',
          'description': 'x',
          'params': {'nodeId': 'a'},
        },
      };
      expect(
        () => LessonPlan.fromJson(json, scenarioPlayable: (_s, _) => true),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('兜底'),
        )),
      );
    });
  });

  group('LessonRuntime · 线性流转（AC-8/9/10/13）', () {
    test('AC-8 · 3 节点线性：三次 onScenarioSuccess → 逐节点流转 → 终点完成', () {
      final p = plan([
        sceneNode('a', 's-1', {'type': 'next'}),
        sceneNode('b', 's-2', {'type': 'next'}),
        sceneNode('c', 's-3', {'type': 'onCompleted', 'to': 'n-end'}),
        endNode,
      ]);
      final rt = LessonRuntime()..load(p);

      expect(rt.current, 'a');
      expect(rt.progress, 0);

      rt.onScenarioSuccess(); // a 完成
      expect(rt.current, 'b');
      expect(rt.completed, {'a'});
      expect(rt.progress, closeTo(1 / 3, 1e-9));

      rt.onScenarioSuccess(); // b 完成
      expect(rt.current, 'c');
      expect(rt.completed, {'a', 'b'});
      expect(rt.progress, closeTo(2 / 3, 1e-9));

      rt.onScenarioSuccess(); // c 完成 → 终点
      expect(rt.current, 'n-end');
      expect(rt.isLessonCompleted, isTrue);
      expect(rt.progress, closeTo(1, 1e-9));
      expect(rt.completed, {'a', 'b', 'c'});
    });

    test('AC-9 · next 语义：按 nodes 数组顺延', () {
      final p = plan([
        sceneNode('a', 's-1', {'type': 'next'}),
        sceneNode('b', 's-2', {'type': 'next'}),
        sceneNode('c', 's-3', {'type': 'onCompleted', 'to': 'n-end'}),
        endNode,
      ]);
      final rt = LessonRuntime()..load(p);
      rt.onScenarioSuccess();
      expect(rt.current, 'b'); // 数组中 a 的下一个
    });

    test('AC-10 · onCompleted 语义：显式跳转到 advance.to（可跳越数组序）', () {
      final p = plan([
        sceneNode('a', 's-1', {'type': 'onCompleted', 'to': 'c'}),
        sceneNode('b', 's-2', {'type': 'onCompleted', 'to': 'n-end'}),
        sceneNode('c', 's-3', {'type': 'onCompleted', 'to': 'b'}),
        endNode,
      ]);
      final rt = LessonRuntime()..load(p);
      rt.onScenarioSuccess(); // a → 显式 to 'c'（跳过数组中的 b）
      expect(rt.current, 'c');
      rt.onScenarioSuccess(); // c → to 'b'
      expect(rt.current, 'b');
    });

    test('AC-13 · 重复 onScenarioSuccess 幂等（不重复流转/不重复计数）', () {
      final p = plan([
        sceneNode('a', 's-1', {'type': 'next'}),
        sceneNode('b', 's-2', {'type': 'onCompleted', 'to': 'n-end'}),
        endNode,
      ]);
      final rt = LessonRuntime()..load(p);
      rt.onScenarioSuccess();
      expect(rt.current, 'b');
      expect(rt.completed, {'a'});
      // 再次触发（此时 current 已是 b，但调用方可能重复回调 a 的钩子）
      rt.onScenarioSuccess();
      expect(rt.current, 'n-end'); // b 完成 → 终点
      expect(rt.completed, {'a', 'b'});
      // 完成态后重复触发 → 幂等
      rt.onScenarioSuccess();
      expect(rt.completed, {'a', 'b'});
    });

    test('Major-3 · jumpTo 回已完成节点重玩 → 再次完成 → 再次流转', () {
      final p = plan([
        sceneNode('a', 's-1', {'type': 'onCompleted', 'to': 'b'}),
        sceneNode('b', 's-2', {'type': 'onCompleted', 'to': 'n-end'}),
        endNode,
      ]);
      final rt = LessonRuntime()..load(p);

      rt.onScenarioSuccess(); // a 完成 → b
      expect(rt.current, 'b');
      rt.onScenarioSuccess(); // b 完成 → n-end（课时完成）
      expect(rt.current, 'n-end');

      // jumpTo 回已完成节点 b（重玩）
      expect(rt.jumpTo('b'), isTrue);
      expect(rt.current, 'b');
      expect(rt.completed, contains('b')); // completed 保留（进度不倒退）

      // 重玩完成 → 再次流转到终点（Major-3 语义）
      rt.onScenarioSuccess();
      expect(rt.current, 'n-end');

      // 幂等：终点后再触发 → 不再流转
      rt.onScenarioSuccess();
      expect(rt.current, 'n-end');
    });

    test('终点进入后 currentNode.isEnd == true，且 onScenarioSuccess 为 no-op', () {
      final p = plan([
        sceneNode('a', 's-1', {'type': 'onCompleted', 'to': 'n-end'}),
        endNode,
      ]);
      final rt = LessonRuntime()..load(p);
      rt.onScenarioSuccess();
      expect(rt.currentNode!.isEnd, isTrue);
      rt.onScenarioSuccess(); // 完成态 no-op
      expect(rt.current, 'n-end');
    });
  });
}
