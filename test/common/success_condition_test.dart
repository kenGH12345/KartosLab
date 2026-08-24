import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/common/scenario/success_condition.dart';

void main() {
  /// 叶子求值器桩：type 为 'true' 返回 true，其余 false。
  bool leafTrue(String type, Map<String, dynamic> params) => type == 'true';

  group('SuccessCondition.fromJson · 叶子（向后兼容平铺格式）', () {
    test('存量平铺叶子格式零改动可解析', () {
      final c = SuccessCondition.fromJson(const {
        'id': 'c1',
        'type': 'concentrationReached',
        'description': '浓度达到 1.0 M',
        'params': {'targetConcentration': 1.0, 'tolerance': 0.01},
      });
      expect(c, isA<LeafCondition>());
      final leaf = c as LeafCondition;
      expect(leaf.id, 'c1');
      expect(leaf.type, 'concentrationReached');
      expect(leaf.description, '浓度达到 1.0 M');
      expect(leaf.params['targetConcentration'], 1.0);
    });

    test('叶子 params 缺省为空 map', () {
      final c = SuccessCondition.fromJson(const {
        'id': 'c1',
        'type': 'solutionSaturated',
        'description': '饱和',
      });
      expect((c as LeafCondition).params, isEmpty);
    });

    test('叶子求值委托给注入的回调', () {
      final c = SuccessCondition.fromJson(const {
        'id': 'c1',
        'type': 'true',
        'description': '',
      });
      expect(c.evaluate(leafTrue), isTrue);
      expect(
        c.evaluate((type, params) => false),
        isFalse,
      );
    });
  });

  group('SuccessCondition · 组合算子', () {
    test('all：全部满足才 true', () {
      final allTrue = SuccessCondition.fromJson(const {
        'id': 'g1',
        'all': [
          {'id': 'a', 'type': 'true', 'description': ''},
          {'id': 'b', 'type': 'true', 'description': ''},
        ],
      });
      final hasFalse = SuccessCondition.fromJson(const {
        'all': [
          {'id': 'a', 'type': 'true', 'description': ''},
          {'id': 'b', 'type': 'false', 'description': ''},
        ],
      });
      expect(allTrue.evaluate(leafTrue), isTrue);
      expect(hasFalse.evaluate(leafTrue), isFalse);
    });

    test('any：任一满足即 true', () {
      final c = SuccessCondition.fromJson(const {
        'any': [
          {'id': 'a', 'type': 'false', 'description': ''},
          {'id': 'b', 'type': 'true', 'description': ''},
        ],
      });
      expect(c.evaluate(leafTrue), isTrue);
    });

    test('not：取反', () {
      final c = SuccessCondition.fromJson(const {
        'not': {'id': 'a', 'type': 'false', 'description': ''},
      });
      expect(c.evaluate(leafTrue), isTrue);
    });

    test('嵌套组合：all[ not(false), any[false, true] ]', () {
      final c = SuccessCondition.fromJson(const {
        'id': 'root',
        'all': [
          {
            'not': {'id': 'n', 'type': 'false', 'description': ''},
          },
          {
            'any': [
              {'id': 'x', 'type': 'false', 'description': ''},
              {'id': 'y', 'type': 'true', 'description': ''},
            ],
          },
        ],
      });
      expect(c.evaluate(leafTrue), isTrue);
    });

    test('all 短路求值（遇 false 不再求值后续叶子）', () {
      var calls = 0;
      bool countingLeaf(String type, Map<String, dynamic> params) {
        calls++;
        return false;
      }
      final c = SuccessCondition.fromJson(const {
        'all': [
          {'id': 'a', 'type': 'x', 'description': ''},
          {'id': 'b', 'type': 'x', 'description': ''},
          {'id': 'c', 'type': 'x', 'description': ''},
        ],
      });
      expect(c.evaluate(countingLeaf), isFalse);
      expect(calls, 1);
    });

    test('any 短路求值（遇 true 不再求值后续叶子）', () {
      var calls = 0;
      bool countingLeaf(String type, Map<String, dynamic> params) {
        calls++;
        return true;
      }
      final c = SuccessCondition.fromJson(const {
        'any': [
          {'id': 'a', 'type': 'x', 'description': ''},
          {'id': 'b', 'type': 'x', 'description': ''},
        ],
      });
      expect(c.evaluate(countingLeaf), isTrue);
      expect(calls, 1);
    });

    test('组合节点 id/description 可选', () {
      final c = SuccessCondition.fromJson(const {
        'all': [
          {'id': 'a', 'type': 'true', 'description': ''},
        ],
      }) as AllCondition;
      expect(c.id, isNull);
      expect(c.description, isNull);
    });
  });

  group('SuccessCondition.fromJson · 非法格式 fail loud', () {
    test('type 与组合键并存 → FormatException', () {
      expect(
        () => SuccessCondition.fromJson(const {
          'id': 'x',
          'type': 'a',
          'description': '',
          'all': [
            {'id': 'y', 'type': 'b', 'description': ''},
          ],
        }),
        throwsFormatException,
      );
    });

    test('组合键互斥并存（all + any）→ FormatException', () {
      expect(
        () => SuccessCondition.fromJson(const {
          'all': [
            {'id': 'a', 'type': 'b', 'description': ''},
          ],
          'any': [
            {'id': 'c', 'type': 'd', 'description': ''},
          ],
        }),
        throwsFormatException,
      );
    });

    test('无 type 无组合键 → FormatException', () {
      expect(
        () => SuccessCondition.fromJson(const {'id': 'x', 'description': ''}),
        throwsFormatException,
      );
    });

    test('not 值非条件对象 → FormatException', () {
      expect(
        () => SuccessCondition.fromJson(const {'not': 'oops'}),
        throwsFormatException,
      );
    });

    test('all 空数组 → FormatException', () {
      expect(
        () => SuccessCondition.fromJson(const {'all': <dynamic>[]}),
        throwsFormatException,
      );
    });

    test('超深度（5 层节点：4 层 not 嵌套叶子）→ FormatException', () {
      // not(1) > not(2) > not(3) > not(4) > leaf(5) —— 叶子位于第 5 层 > maxParseDepth(4)
      final tooDeep = <String, dynamic>{
        'not': <String, dynamic>{
          'not': <String, dynamic>{
            'not': <String, dynamic>{
              'not': <String, dynamic>{
                'id': 'leaf',
                'type': 'x',
                'description': '',
              },
            },
          },
        },
      };
      expect(
        () => SuccessCondition.fromJson(tooDeep),
        throwsFormatException,
      );
    });

    test('深度上限内（4 层节点：3 层 not 嵌套叶子）可解析', () {
      // not(1) > not(2) > not(3) > leaf(4) —— 恰好 4 层
      final fourLevels = <String, dynamic>{
        'not': <String, dynamic>{
          'not': <String, dynamic>{
            'not': <String, dynamic>{
              'id': 'leaf',
              'type': 'x',
              'description': '',
            },
          },
        },
      };
      expect(
        () => SuccessCondition.fromJson(fourLevels),
        returnsNormally,
      );
    });
  });

  group('SuccessCondition · collectLeaves / toJson / allSatisfied', () {
    test('collectLeaves 按树序收集全部叶子', () {
      final c = SuccessCondition.fromJson(const {
        'all': [
          {'id': 'a', 'type': 't1', 'description': '第一条'},
          {
            'not': {'id': 'b', 'type': 't2', 'description': '第二条'},
          },
          {
            'any': [
              {'id': 'c', 'type': 't3', 'description': '第三条'},
            ],
          },
        ],
      });
      final leaves = c.collectLeaves();
      expect(leaves.map((l) => l.id).toList(), ['a', 'b', 'c']);
      expect(leaves.map((l) => l.description).toList(),
          ['第一条', '第二条', '第三条']);
    });

    test('toJson 往返保持结构（叶子 + 组合）', () {
      final original = const {
        'id': 'root',
        'description': '组合目标',
        'all': [
          {'id': 'a', 'type': 't1', 'description': 'd1', 'params': {'k': 1}},
          {
            'not': {'id': 'b', 'type': 't2', 'description': 'd2'},
          },
          {
            'any': [
              {'id': 'c', 'type': 't3', 'description': 'd3'},
              {'id': 'd', 'type': 't4', 'description': 'd4'},
            ],
          },
        ],
      };
      final parsed = SuccessCondition.fromJson(original);
      final roundTripped = parsed.toJson();
      final reparsed = SuccessCondition.fromJson(
          roundTripped.cast<String, dynamic>());
      expect(reparsed.toJson(), equals(roundTripped));
    });

    test('allSatisfied：全部条件满足才 true（保持改造前 every 语义）', () {
      final conditions = [
        SuccessCondition.fromJson(const {
          'id': 'a',
          'type': 'true',
          'description': '',
        }),
        SuccessCondition.fromJson(const {
          'all': [
            {'id': 'b', 'type': 'true', 'description': ''},
          ],
        }),
      ];
      expect(SuccessCondition.allSatisfied(conditions, leafTrue), isTrue);
      conditions.add(SuccessCondition.fromJson(const {
        'id': 'c',
        'type': 'false',
        'description': '',
      }));
      expect(SuccessCondition.allSatisfied(conditions, leafTrue), isFalse);
    });

    test('allSatisfied：空列表 → true（与 manager isEmpty 短路一致）', () {
      expect(
        SuccessCondition.allSatisfied(const [], leafTrue),
        isTrue,
      );
    });
  });
}
