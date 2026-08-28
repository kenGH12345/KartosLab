import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/scenario/lesson_plan.dart';
import 'package:kratos/lesson_editor/canvas/lesson_auto_layout.dart';

void main() {
  bool playable(String sim, String scenarioId) => true;

  Map<String, dynamic> scenarioRef() => {'sim': 'circuit', 'scenarioId': 'rgb'};

  group('LessonAutoLayout（M1 · entry 起 BFS 分层）', () {
    test('线性链（next）：各节点层级递增，纵坐标严格递增且互不重叠', () {
      final plan = LessonPlan.fromJson({
        'lessonId': 'l1',
        'name': 'l1',
        'version': '1.0',
        'description': '',
        'entry': 'n1',
        'nodes': [
          {'id': 'n1', 'title': 'A', 'scenario': scenarioRef(), 'advance': {'type': 'next'}},
          {'id': 'n2', 'title': 'B', 'scenario': scenarioRef(), 'advance': {'type': 'next'}},
          {'id': 'n3', 'title': 'C'},
        ],
      }, scenarioPlayable: playable);

      final layout = LessonAutoLayout.layout(plan);

      expect(layout, hasLength(3));
      expect(layout['n1'], isNotNull);
      expect(layout['n2'], isNotNull);
      expect(layout['n3'], isNotNull);
      // 层级递增 → 纵坐标严格递增，且三者互不重叠。
      expect(layout['n2']!.dy, greaterThan(layout['n1']!.dy));
      expect(layout['n3']!.dy, greaterThan(layout['n2']!.dy));
      expect({layout['n1'], layout['n2'], layout['n3']}, hasLength(3));
    });

    test('分叉（routes）：同层节点横向错开（dx 不同），不再堆叠同一坐标', () {
      final plan = LessonPlan.fromJson({
        'lessonId': 'l2',
        'name': 'l2',
        'version': '1.0',
        'description': '',
        'entry': 'n1',
        'nodes': [
          {
            'id': 'n1',
            'title': 'A',
            'scenario': scenarioRef(),
            'advance': {
              'type': 'routes',
              'routes': [
                {
                  'to': 'n2',
                  'when': {
                    'id': 'c1',
                    'type': 'nodeCompleted',
                    'description': 'n1完成',
                    'params': {'nodeId': 'n1'},
                  },
                },
                {'to': 'n3'}, // 末项兜底（when=null）
              ],
            },
          },
          {'id': 'n2', 'title': 'B', 'scenario': scenarioRef(), 'advance': {'type': 'onCompleted', 'to': 'n4'}},
          {'id': 'n3', 'title': 'C', 'scenario': scenarioRef(), 'advance': {'type': 'onCompleted', 'to': 'n4'}},
          {'id': 'n4', 'title': 'D'},
        ],
      }, scenarioPlayable: playable);

      final layout = LessonAutoLayout.layout(plan);

      expect(layout, hasLength(4));
      // n2/n3 同层（entry 的两条分叉后继）：纵坐标相同，横坐标不同（不堆叠）。
      expect(layout['n2']!.dy, layout['n3']!.dy);
      expect(layout['n2']!.dx, isNot(equals(layout['n3']!.dx)));
      // 汇合节点 n4 层级晚于 n2/n3。
      expect(layout['n4']!.dy, greaterThan(layout['n2']!.dy));
      // entry 层级最浅。
      expect(layout['n1']!.dy, lessThan(layout['n2']!.dy));
    });

    test('单节点剧本（entry 即终点）：返回该节点唯一坐标', () {
      final plan = LessonPlan.fromJson({
        'lessonId': 'l3',
        'name': 'l3',
        'version': '1.0',
        'description': '',
        'entry': 'only',
        'nodes': [
          {'id': 'only', 'title': '仅一个节点'},
        ],
      }, scenarioPlayable: playable);

      final layout = LessonAutoLayout.layout(plan);

      expect(layout, hasLength(1));
      expect(layout['only'], isNotNull);
    });
  });
}
