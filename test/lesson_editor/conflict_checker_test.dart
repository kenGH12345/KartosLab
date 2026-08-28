import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/scenario/lesson_plan.dart';
import 'package:kratos/common/scenario/success_condition.dart';
import 'package:kratos/lesson_editor/conflict/conflict_checker.dart';
import 'package:kratos/lesson_editor/conflict/conflict_rules.dart';
import 'package:kratos/lesson_editor/models/editable_lesson_model.dart';

void main() {
  const circuit = LessonScenarioRef(sim: 'circuit', scenarioId: 'rgb');
  const colorVision = LessonScenarioRef(sim: 'color_vision', scenarioId: 'rgb');
  const forces = LessonScenarioRef(sim: 'forces', scenarioId: 'basic');

  /// 规则表：allowed=[circuit,color_vision]；warn=[forces→circuit, forces→color_vision]。
  const rules = ConflictRuleSet(
    allowedCombos: [('circuit', 'color_vision')],
    warnCombos: [
      WarnCombo(from: 'forces', to: 'circuit', reason: '力学→电路需确认'),
      WarnCombo(from: 'forces', to: 'color_vision', reason: '力学→光学需确认'),
    ],
  );

  /// 降级态规则表（仅数据传递检查）。
  const degraded = ConflictRuleSet(isDegraded: true);

  group('ConflictChecker · 第一类教学语义冲突', () {
    test('circuit→color_vision（白名单）→ 零警告（AC-21）', () {
      const model = EditableLessonModel(
        nodes: [
          EditableNode(
            id: 'n1',
            title: '电路',
            scenario: circuit,
            advance: LessonAdvance(type: 'onCompleted', to: 'n2'),
          ),
          EditableNode(id: 'n2', title: '色觉', scenario: colorVision),
        ],
      );
      final ws = ConflictChecker.analyze(model, rules);
      expect(ws.where((w) => w.type == 'semantic'), isEmpty);
    });

    test('forces→circuit（warn 命中）→ 教学语义警告', () {
      const model = EditableLessonModel(
        nodes: [
          EditableNode(
            id: 'n1',
            title: '力学',
            scenario: forces,
            advance: LessonAdvance(type: 'onCompleted', to: 'n2'),
          ),
          EditableNode(id: 'n2', title: '电路', scenario: circuit),
        ],
      );
      final ws = ConflictChecker.analyze(model, rules);
      final semantic = ws.where((w) => w.type == 'semantic').toList();
      expect(semantic, hasLength(1));
      expect(semantic.single.fromNodeId, 'n1');
      expect(semantic.single.toNodeId, 'n2');
      expect(semantic.single.reason, contains('力学→电路'));
    });

    test('同 sim 边不查 → 零警告', () {
      const model = EditableLessonModel(
        nodes: [
          EditableNode(
            id: 'n1',
            title: 'a',
            scenario: circuit,
            advance: LessonAdvance(type: 'onCompleted', to: 'n2'),
          ),
          EditableNode(id: 'n2', title: 'b', scenario: circuit),
        ],
      );
      expect(ConflictChecker.analyze(model, rules), isEmpty);
    });

    test('未知组合（未在 allowed/warn）→ 保守放行', () {
      const model = EditableLessonModel(
        nodes: [
          EditableNode(
            id: 'n1',
            title: '声波',
            scenario: LessonScenarioRef(sim: 'sound', scenarioId: 'x'),
            advance: LessonAdvance(type: 'onCompleted', to: 'n2'),
          ),
          EditableNode(id: 'n2', title: '电路', scenario: circuit),
        ],
      );
      final ws = ConflictChecker.analyze(model, rules);
      expect(ws.where((w) => w.type == 'semantic'), isEmpty);
    });

    test('降级态（规则表加载失败）→ 不查教学语义', () {
      const model = EditableLessonModel(
        nodes: [
          EditableNode(
            id: 'n1',
            title: '力学',
            scenario: forces,
            advance: LessonAdvance(type: 'onCompleted', to: 'n2'),
          ),
          EditableNode(id: 'n2', title: '电路', scenario: circuit),
        ],
      );
      expect(ConflictChecker.analyze(model, degraded), isEmpty);
    });
  });

  group('ConflictChecker · 第二类数据传递冲突', () {
    test('unlock 条件树叶子跨 sim 引用 → 数据传递警告', () {
      const model = EditableLessonModel(
        nodes: [
          EditableNode(
            id: 'n1',
            title: '电路',
            scenario: circuit,
            unlock: LeafCondition(
              id: 'c1',
              type: 'nodeCompleted',
              description: '完成色觉节点',
              params: {'nodeId': 'n2'},
            ),
            advance: LessonAdvance(type: 'onCompleted', to: 'n2'),
          ),
          EditableNode(id: 'n2', title: '色觉', scenario: colorVision),
        ],
      );
      final ws = ConflictChecker.analyze(model, rules);
      final dataFlow = ws.where((w) => w.type == 'dataFlow').toList();
      expect(dataFlow, hasLength(1));
      expect(dataFlow.single.fromNodeId, 'n1'); // 条件所在节点
      expect(dataFlow.single.toNodeId, 'n2'); // 跨 sim 引用节点
      expect(dataFlow.single.reason, contains('n2'));
    });

    test('routes.when 跨 sim 引用 → 数据传递警告', () {
      const model = EditableLessonModel(
        nodes: [
          EditableNode(
            id: 'n1',
            title: '电路',
            scenario: circuit,
            advance: LessonAdvance(
              type: 'routes',
              routes: [
                LessonRoute(
                  to: 'n2',
                  when: LeafCondition(
                    id: 'c1',
                    type: 'predictionScore',
                    description: '预测全对',
                    params: {'nodeId': 'n2'},
                  ),
                ),
              ],
            ),
          ),
          EditableNode(id: 'n2', title: '色觉', scenario: colorVision),
        ],
      );
      final ws = ConflictChecker.analyze(model, rules);
      expect(ws.where((w) => w.type == 'dataFlow'), hasLength(1));
    });

    test('同 sim 叶子引用 → 无数据传递警告', () {
      const model = EditableLessonModel(
        nodes: [
          EditableNode(
            id: 'n1',
            title: '电路a',
            scenario: circuit,
            unlock: LeafCondition(
              id: 'c1',
              type: 'nodeCompleted',
              description: '',
              params: {'nodeId': 'n2'},
            ),
            advance: LessonAdvance(type: 'onCompleted', to: 'n2'),
          ),
          EditableNode(id: 'n2', title: '电路b', scenario: circuit),
        ],
      );
      expect(ConflictChecker.analyze(model, rules), isEmpty);
    });

    test('组合条件树（all 内嵌跨 sim 叶子）→ 递归检出', () {
      const model = EditableLessonModel(
        nodes: [
          EditableNode(
            id: 'n1',
            title: '电路',
            scenario: circuit,
            unlock: AllCondition(children: [
              LeafCondition(
                id: 'c1',
                type: 'nodeCompleted',
                description: '',
                params: {'nodeId': 'n1'},
              ),
              AnyCondition(children: [
                LeafCondition(
                  id: 'c2',
                  type: 'scenarioSuccess',
                  description: '',
                  params: {'nodeId': 'n2'},
                ),
              ]),
            ]),
            advance: LessonAdvance(type: 'onCompleted', to: 'n2'),
          ),
          EditableNode(id: 'n2', title: '色觉', scenario: colorVision),
        ],
      );
      final ws = ConflictChecker.analyze(model, rules);
      expect(ws.where((w) => w.type == 'dataFlow'), hasLength(1));
    });

    test('降级态仍检查数据传递（C8 · 失败降级只丢教学语义）', () {
      const model = EditableLessonModel(
        nodes: [
          EditableNode(
            id: 'n1',
            title: '电路',
            scenario: circuit,
            unlock: LeafCondition(
              id: 'c1',
              type: 'nodeCompleted',
              description: '',
              params: {'nodeId': 'n2'},
            ),
            advance: LessonAdvance(type: 'onCompleted', to: 'n2'),
          ),
          EditableNode(id: 'n2', title: '色觉', scenario: colorVision),
        ],
      );
      final ws = ConflictChecker.analyze(model, degraded);
      expect(ws.where((w) => w.type == 'dataFlow'), hasLength(1));
    });
  });

  group('ConflictRuleSet.load', () {
    test('解析正常 JSON', () async {
      final rules = await ConflictRuleSet.load(
        loadString: (_) async => '''
        {
          "version": "1",
          "allowedCombos": [["circuit", "color_vision"]],
          "warnCombos": [
            {"from": "forces", "to": "circuit", "reason": "需确认"}
          ]
        }
        ''',
      );
      expect(rules.isDegraded, isFalse);
      expect(rules.allowedCombos, [('circuit', 'color_vision')]);
      expect(rules.warnCombos.single.from, 'forces');
      expect(rules.findWarn('forces', 'circuit')?.reason, '需确认');
      expect(rules.isAllowed('color_vision', 'circuit'), isTrue); // 无序
    });

    test('损坏 JSON → 降级态', () async {
      final rules = await ConflictRuleSet.load(
        loadString: (_) async => '{bad json',
      );
      expect(rules.isDegraded, isTrue);
    });

    test('缺字段条目 → 跳过', () async {
      final rules = await ConflictRuleSet.load(
        loadString: (_) async => '''
        {
          "allowedCombos": [["circuit"]],
          "warnCombos": [{"from": "forces", "to": 3}]
        }
        ''',
      );
      expect(rules.isDegraded, isFalse);
      expect(rules.allowedCombos, isEmpty);
      expect(rules.warnCombos, isEmpty);
    });
  });
}
