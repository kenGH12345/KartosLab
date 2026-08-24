import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/molarity/config/molarity_criterion.dart';
import 'package:kratos/chemistry/molarity/config/molarity_scenario.dart';
import 'package:kratos/chemistry/molarity/config/molarity_scenario_manager.dart';
import 'package:kratos/chemistry/molarity/model/molarity_state.dart';
import 'package:kratos/chemistry/molarity/model/solution.dart';
import 'package:kratos/chemistry/molarity/model/solvent.dart';
import 'package:kratos/common/scenario/success_condition.dart';

void main() {
  final sampleJson = <String, dynamic>{
    'scenarioId': 'default',
    'name': 'Molarity 自由探索',
    'description': '自由探索',
    'version': '1.0',
    'initialParams': {'soluteIndex': 0, 'soluteAmount': 0.5, 'volume': 0.5, 'valuesVisible': false},
    'paramRanges': {
      'soluteAmount': {'min': 0, 'max': 1.0, 'step': 0.01, 'unit': 'mol'},
      'volume': {'min': 0.2, 'max': 1.0, 'step': 0.01, 'unit': 'L'},
    },
    'concentrationMax': 5.0,
    'performance': {'particlesPerMole': 200, 'particleSize': 5},
    'solutes': [
      {
        'name': 'Drink mix',
        'formula': 'Drink mix',
        'saturatedConcentration': 5.95,
        'solutionColorMin': '#FFE1E1',
        'solutionColorMax': '#FF0000',
        'particleColor': '#FF0000',
      },
    ],
    'successCriteria': [
      {'id': 'sc-1', 'type': 'concentrationReached', 'description': '浓度 1.00 M', 'params': {'targetConcentration': 1.0, 'tolerance': 0.01}},
    ],
    'hints': [
      {'trigger': 'precipitateAmount == 0', 'message': '试试增加溶质'},
    ],
    'inquiryTask': {
      'question': '问题？',
      'steps': [
        {'id': 'step-1', 'instruction': '步骤1', 'hint': '提示1'},
        {'id': 'step-2', 'instruction': '步骤2', 'hint': '提示2'},
      ],
      'snapshotColumns': [
        {'key': 'soluteAmount', 'label': '溶质(mol)', 'source': 'param'},
        {'key': 'concentration', 'label': '浓度(M)', 'source': 'reading'},
      ],
      'referenceConclusion': '结论',
    },
  };

  test('MolarityScenario.fromJson 完整解析（AC-3.1）', () {
    final s = MolarityScenario.fromJson(sampleJson);
    expect(s.scenarioId, 'default');
    expect(s.initialSoluteAmount, 0.5);
    expect(s.initialVolume, 0.5);
    expect(s.initialSoluteIndex, 0);
    expect(s.soluteAmountRange.min, 0);
    expect(s.solutes, hasLength(1));
    expect(s.solutes.first.saturatedConcentration, 5.95);
    expect(s.solutes.first.solutionColor.min, const Color(0xFFFFE1E1));
    expect(s.successCriteria, hasLength(1));
    expect(s.hints, hasLength(1));
    expect(s.inquiryTask, isNotNull);
    expect(s.inquiryTask!.snapshotColumns, hasLength(2));
  });

  test('Cobalt chloride 颜色忠实蓝本 #FF6A6A（评审 M1 回归）', () {
    final s = MolarityScenario.fromJson(const {
      'scenarioId': 'cocl2',
      'name': 'CoCl2',
      'initialParams': {'soluteIndex': 2, 'soluteAmount': 0.5, 'volume': 0.5},
      'solutes': [
        {
          'name': 'Cobalt chloride',
          'formula': 'CoCl\u2082',
          'saturatedConcentration': 4.35,
          'solutionColorMin': '#FFF2F2',
          'solutionColorMax': '#FF6A6A',
          'particleColor': '#FF6A6A',
        },
      ],
    });
    // 0xFF6A6A = (255,106,106) 暗红（蓝本 MolarityModel.java:43）
    expect(s.solutes.first.solutionColor.max, const Color(0xFFFF6A6A));
  });

  test('非法 hex 颜色 → 黑色降级 + 不崩溃（AC-3.5）', () {
    final json = Map<String, dynamic>.from(sampleJson);
    final solutes = (json['solutes'] as List).cast<Map<String, dynamic>>();
    solutes[0]['solutionColorMin'] = 'oops';
    json['solutes'] = solutes;
    final s = MolarityScenario.fromJson(json);
    expect(s.solutes.first.solutionColor.min, const Color(0xFF000000));
  });

  test('缺省字段有默认值（不 crash）', () {
    final s = MolarityScenario.fromJson(const {
      'scenarioId': 'min',
      'name': 'Minimal',
      'initialParams': {'soluteIndex': 0, 'soluteAmount': 0.5, 'volume': 0.5},
    });
    expect(s.version, '1.0');
    expect(s.concentrationMax, 5.0);
    expect(s.solutes, isEmpty);
    expect(s.successCriteria, isEmpty);
    expect(s.performance.particlesPerMole, 200);
  });

  group('MolarityCriterion.check', () {
    // 复用 fromJson 的溶质（Drink mix sat=5.95）· 声明须先于使用（闭包提前引用约束）
    late MolarityScenario sampleScenario;
    setUp(() => sampleScenario = MolarityScenario.fromJson(sampleJson));

    MolarityState stateWith(double n, double v) {
      final solute = sampleScenario.solutes.first;
      return MolarityState(
        scenarioId: 'default',
        solutes: [solute],
        solution: Solution(solvent: const Solvent(), solute: solute, soluteAmount: n, volume: v),
        initialSoluteIndex: 0,
        initialSoluteAmount: 0.5,
        initialVolume: 0.5,
        initialValuesVisible: false,
      );
    }

    test('concentrationReached：|c−target| ≤ tolerance', () {
      final c = MolarityCriterion.fromJson(const {
        'id': 'sc', 'type': 'concentrationReached', 'description': '',
        'params': {'targetConcentration': 1.0, 'tolerance': 0.01},
      });
      expect(c.check(stateWith(0.5, 0.5)), isTrue); // c=1.0
      expect(c.check(stateWith(0.3, 0.5)), isFalse); // c=0.6
    });

    test('solutionSaturated / precipitateVisible', () {
      final sat = MolarityCriterion.fromJson(const {
        'id': 'sc', 'type': 'solutionSaturated', 'description': '',
      });
      final prec = MolarityCriterion.fromJson(const {
        'id': 'sc', 'type': 'precipitateVisible', 'description': '',
      });
      // Drink mix sat=5.95 → 0.5/0.5 不饱和
      expect(sat.check(stateWith(0.5, 0.5)), isFalse);
      expect(prec.check(stateWith(0.5, 0.5)), isFalse);
    });

    test('未知 type → false（不 crash）', () {
      final c = MolarityCriterion.fromJson(const {
        'id': 'sc', 'type': 'unknown', 'description': '',
      });
      expect(c.check(stateWith(0.5, 0.5)), isFalse);
    });
  });

  group('组合条件场景（req-criteria-composable · AC-3 端到端）', () {
    // K₂Cr₂O₇（sat=0.50）组合目标：concentrationReached(0.45) 且 not(solutionSaturated)
    final comboJson = <String, dynamic>{
      'scenarioId': 'combo-test',
      'name': '组合测试',
      'initialParams': {'soluteIndex': 3, 'soluteAmount': 0.3, 'volume': 0.3},
      'solutes': [
        {
          'name': '重铬酸钾',
          'formula': 'K₂Cr₂O₇',
          'saturatedConcentration': 0.50,
          'solutionColorMin': '#FFE8D2',
          'solutionColorMax': '#FF7F00',
          'particleColor': '#FF7F00',
        },
      ],
      'successCriteria': [
        {
          'id': 'g-1',
          'description': '浓度 0.45 M 且不饱和',
          'all': [
            {
              'id': 'sc-1',
              'type': 'concentrationReached',
              'description': '浓度达到 0.45 M',
              'params': {'targetConcentration': 0.45, 'tolerance': 0.01},
            },
            {
              'id': 'sc-2',
              'description': '不得饱和',
              'not': {
                'id': 'sc-2n',
                'type': 'solutionSaturated',
                'description': '饱和',
                'params': <String, dynamic>{},
              },
            },
          ],
        },
      ],
    };

    MolarityState stateWith(double n, double v) {
      final solute = MolarityScenario.fromJson(comboJson).solutes.first;
      return MolarityState(
        scenarioId: 'combo-test',
        solutes: [solute],
        solution:
            Solution(solvent: const Solvent(), solute: solute, soluteAmount: n, volume: v),
        initialSoluteIndex: 0,
        initialSoluteAmount: 0.3,
        initialVolume: 0.3,
        initialValuesVisible: true,
      );
    }

    test('解析为 AllCondition + 嵌套 NotCondition', () {
      final s = MolarityScenario.fromJson(comboJson);
      expect(s.successCriteria, hasLength(1));
      final g = s.successCriteria[0];
      expect(g, isA<AllCondition>());
      expect(g.collectLeaves(), hasLength(2));
      expect(g.collectLeaves()[0].type, 'concentrationReached');
      expect(g.collectLeaves()[1].type, 'solutionSaturated');
    });

    test('判定链：0.45 M 不饱和 → 达成', () {
      final s = MolarityScenario.fromJson(comboJson);
      // 0.225 mol / 0.5 L = 0.45 M ≤ 0.50 → 不饱和
      final met = SuccessCondition.allSatisfied(
        s.successCriteria,
        (type, params) => MolarityCriterion.evaluateLeaf(type, params, stateWith(0.225, 0.5)),
      );
      expect(met, isTrue);
    });

    test('判定链：过饱和（not 分支失败）→ 不达成', () {
      final s = MolarityScenario.fromJson(comboJson);
      // 0.3 mol / 0.3 L = 1.0 M > 0.50 → 饱和（沉淀）
      final met = SuccessCondition.allSatisfied(
        s.successCriteria,
        (type, params) => MolarityCriterion.evaluateLeaf(type, params, stateWith(0.3, 0.3)),
      );
      expect(met, isFalse);
    });

    test('判定链：浓度不足（叶子失败）→ 不达成', () {
      final s = MolarityScenario.fromJson(comboJson);
      // 0.09 mol / 0.3 L = 0.30 M 不饱和但未达 0.45
      final met = SuccessCondition.allSatisfied(
        s.successCriteria,
        (type, params) => MolarityCriterion.evaluateLeaf(type, params, stateWith(0.09, 0.3)),
      );
      expect(met, isFalse);
    });

    testWidgets('precision-dilution 场景经 rootBundle 全链路加载', (tester) async {
      final mgr = MolarityScenarioManager();
      await mgr.loadScenarios();
      final s = mgr.findById('precision-dilution');
      expect(s, isNotNull, reason: 'manifest 应注册 precision-dilution');
      expect(s!.successCriteria, hasLength(1));
      expect(s.successCriteria[0], isA<AllCondition>());
      expect(s.successCriteria[0].collectLeaves(), hasLength(2));
    });
  });
}
