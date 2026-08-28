import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/scenario/lesson_plan.dart';
import 'package:kratos/common/scenario/success_condition.dart';
import 'package:kratos/lesson_editor/models/editable_lesson_model.dart';

void main() {
  group('EditableLessonModel.edges 三型推导（T6）', () {
    test('next：连到 nodes 数组后继', () {
      final model = EditableLessonModel(
        nodes: const [
          EditableNode(id: 'n1', title: 'a', advance: LessonAdvance(type: 'next')),
          EditableNode(id: 'n2', title: 'b'),
        ],
      );
      final edges = model.edges;
      expect(edges, hasLength(1));
      expect(edges.single.fromId, 'n1');
      expect(edges.single.toId, 'n2');
      expect(edges.single.type, 'next');
      expect(edges.single.isFallback, isFalse);
    });

    test('onCompleted：label=完成后，to=指定节点', () {
      final model = EditableLessonModel(
        nodes: const [
          EditableNode(
            id: 'n1',
            title: 'a',
            advance: LessonAdvance(type: 'onCompleted', to: 'n3'),
          ),
          EditableNode(id: 'n2', title: 'b'),
          EditableNode(id: 'n3', title: 'c'),
        ],
      );
      final edges = model.edges;
      expect(edges, hasLength(1));
      expect(edges.single.toId, 'n3');
      expect(edges.single.label, '完成后');
    });

    test('routes：条件边带 label，末项兜底 isFallback=true 且 label=否则', () {
      final model = EditableLessonModel(
        nodes: const [
          EditableNode(
            id: 'n1',
            title: 'a',
            advance: LessonAdvance(
              type: 'routes',
              routes: [
                LessonRoute(
                  to: 'n2',
                  when: LeafCondition(
                    id: 'c1',
                    type: 'predictionScore',
                    description: '预测全对',
                  ),
                ),
                LessonRoute(to: 'n3'), // 兜底
              ],
            ),
          ),
          EditableNode(id: 'n2', title: 'b'),
          EditableNode(id: 'n3', title: 'c'),
        ],
      );
      final edges = model.edges;
      expect(edges, hasLength(2));
      final cond = edges[0];
      expect(cond.type, 'routes');
      expect(cond.toId, 'n2');
      expect(cond.label, '预测全对');
      expect(cond.isFallback, isFalse);
      final fallback = edges[1];
      expect(fallback.toId, 'n3');
      expect(fallback.label, '否则');
      expect(fallback.isFallback, isTrue);
    });

    test('routes 中间路由 when 为空（非法态）不标兜底', () {
      final model = EditableLessonModel(
        nodes: const [
          EditableNode(
            id: 'n1',
            title: 'a',
            advance: LessonAdvance(
              type: 'routes',
              routes: [
                LessonRoute(to: 'n2'),
                LessonRoute(to: 'n3'),
              ],
            ),
          ),
          EditableNode(id: 'n2', title: 'b'),
          EditableNode(id: 'n3', title: 'c'),
        ],
      );
      final edges = model.edges;
      // 仅末项 when==null 才标兜底；首项 when==null 不标（非法态由校验拦截）
      expect(edges[0].isFallback, isFalse);
      expect(edges[0].label, isNull);
      expect(edges[1].isFallback, isTrue);
    });

    test('终点节点（无 advance）不产生边', () {
      final model = EditableLessonModel(
        nodes: const [
          EditableNode(id: 'n1', title: 'a', advance: LessonAdvance(type: 'onCompleted', to: 'n2')),
          EditableNode(id: 'n2', title: 'end'),
        ],
      );
      // n2 无 advance，即使它在数组中也不产生"下一跳"边
      final edges = model.edges;
      expect(edges, hasLength(1));
      expect(edges.single.toId, 'n2');
    });
  });

  group('conditionLabel（T6）', () {
    test('叶子取 description', () {
      expect(
        conditionLabel(const LeafCondition(id: 'c', type: 'x', description: '达标')),
        '达标',
      );
    });

    test('空 description 叶子降级为"条件"', () {
      expect(
        conditionLabel(const LeafCondition(id: 'c', type: 'x', description: '')),
        '条件',
      );
    });

    test('组合缺 description 用类型名概括', () {
      expect(conditionLabel(const AllCondition(children: [])), '全部满足');
      expect(conditionLabel(const AnyCondition(children: [])), '任一满足');
      expect(
        conditionLabel(const NotCondition(child: LeafCondition(id: 'c', type: 'x', description: 'a'))),
        '取反',
      );
    });

    test('null 返回 null', () {
      expect(conditionLabel(null), isNull);
    });
  });
}
