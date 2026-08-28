import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/scenario/lesson_manifest.dart';
import 'package:kratos/common/scenario/lesson_plan.dart';
import 'package:kratos/common/scenario/lesson_runtime.dart';
import 'package:kratos/common/scenario/success_condition.dart';
import 'package:kratos/lesson_editor/conflict/conflict_checker.dart';
import 'package:kratos/lesson_editor/conflict/conflict_rules.dart';
import 'package:kratos/lesson_editor/models/editable_lesson_model.dart';
import 'package:kratos/lesson_editor/validation/lesson_importer.dart';
import 'package:kratos/lesson_editor/validation/lesson_saver.dart';
import 'package:kratos/lesson_editor/validation/lesson_validator.dart';

/// T22 端到端（AC-13）：编辑器全链路闭环
///
/// 构造跨 sim 混合剧本（circuit→color_vision→circuit→终点，含 unlock 门禁
/// + routes 条件路由）→ 校验 → 保存 → 导入 → 运行时 load 可运行，
/// 且三型流转（next/onCompleted/routes）全部按预期生效。
void main() {
  bool playable(String sim, String scenarioId) => true;

  // ---------- 1. 构造可编辑模型（跨 sim 混合 · 通关地图结构） ----------

  EditableLessonModel buildModel() {
    return EditableLessonModel(
      lessonId: 'e2e-lesson',
      name: '端到端课时',
      entry: 'n1',
      nodes: const [
        // n1 circuit：完成后 → n2（onCompleted）
        EditableNode(
          id: 'n1',
          title: '电路搭建',
          scenario: LessonScenarioRef(sim: 'circuit', scenarioId: 'rgb'),
          advance: LessonAdvance(type: 'onCompleted', to: 'n2'),
        ),
        // n2 color_vision：门禁=完成 n1；路由=预测分≥0.5 → n3 挑战，否则 n3 复习
        EditableNode(
          id: 'n2',
          title: '色觉混合',
          scenario: LessonScenarioRef(sim: 'color_vision', scenarioId: 'rgb'),
          unlock: LeafCondition(
            id: 'c1',
            type: 'nodeCompleted',
            description: '完成电路',
            params: {'nodeId': 'n1'},
          ),
          advance: LessonAdvance(
            type: 'routes',
            routes: [
              // 条件路由：预测分 ≥ 0.5 → n3 挑战线
              LessonRoute(
                to: 'n3',
                when: LeafCondition(
                  id: 'c2',
                  type: 'predictionScore',
                  description: '预测全对',
                  params: {'nodeId': 'n2', 'metric': 'ratio', 'operator': 'gte', 'threshold': 0.5},
                ),
              ),
              // 兜底路由（末项 when==null · D7）：预测分不足 → 仍到 n3 复习线
              LessonRoute(to: 'n3'),
            ],
          ),
        ),
        // n3 circuit：无 advance（终点 · 二元绑定）
        EditableNode(id: 'n3', title: '课时完成'),
      ],
      layout: const {'n1': Offset(0, 0), 'n2': Offset(0, 100), 'n3': Offset(0, 200)},
    );
  }

  test('端到端：构造→校验→保存→导入→运行时全链路', () async {
    final tmp = Directory.systemTemp.createTempSync('e2e_');
    addTearDown(() => tmp.deleteSync(recursive: true));
    final model = buildModel();

    // ---- 步骤 2. 校验（AC-9）----
    final validation = LessonValidator.validate(model, scenarioPlayable: playable);
    expect(validation.isValid, isTrue, reason: '校验应通过：${validation.errors}');

    // ---- 步骤 3. 冲突检测（F14）----
    // AC-21：白名单只保证"教学语义"（sim 组合边）零警告；
    // 本模型 n2 的 unlock 条件树跨 sim 引用 n1（circuit）→ 数据传递警告
    // 是设计预期（F14 · 作者需确认教学合理性）。
    const rules = ConflictRuleSet(
      allowedCombos: [('circuit', 'color_vision')],
      warnCombos: [],
    );
    final warnings = ConflictChecker.analyze(model, rules);
    final semantic = warnings.where((w) => w.type == 'semantic').toList();
    expect(semantic, isEmpty,
        reason: 'AC-21：circuit↔color_vision 教学语义零冲突警告');
    final dataFlow = warnings.where((w) => w.type == 'dataFlow').toList();
    expect(dataFlow, hasLength(1),
        reason: 'F14：跨 sim 条件树引用应产生数据传递警告（作者确认）');

    // ---- 步骤 4. 保存（T16 · AC-12）----
    final saveError = await LessonSaver(lessonsDir: tmp.path).save(model);
    expect(saveError, isNull);

    // ---- 步骤 5. 导入回读（T17 · 布局还原）----
    final importer = LessonImporter(lessonsDir: tmp.path);
    final restored = await importer.importByEntry(
      LessonManifestEntry(id: 'e2e-lesson', file: 'e2e-lesson.json', name: '端到端课时', sim: 'circuit'),
      scenarioPlayable: playable,
    );
    expect(restored.lessonId, 'e2e-lesson');
    expect(restored.nodes, hasLength(3));
    expect(restored.layout['n2'], Offset(0, 100)); // 布局还原
    expect(restored.nodes[1].unlock, isNotNull); // 门禁还原

    // ---- 步骤 6. 运行时 load（AC-13）----
    final plan = LessonPlan.fromJson(
      restored.toLessonPlanJson(),
      scenarioPlayable: playable,
    );
    final runtime = LessonRuntime();
    runtime.load(plan);
    expect(runtime.current, 'n1');
    expect(runtime.isLessonCompleted, isFalse);
    expect(runtime.isUnlocked('n1'), isTrue);

    // ---- 步骤 7. 运行流转验证 ----
    // n1 完成 → 自动流转到 n2
    runtime.onScenarioSuccess();
    expect(runtime.current, 'n2');
    expect(runtime.completed, contains('n1'));

    // n2 有门禁（unlock=完成n1）→ 已满足（n1 完成）
    expect(runtime.isUnlocked('n2'), isTrue);

    // 预测分 3/4 = 0.75 ≥ 0.5 → 条件路由命中 → 流转到 n3（终点）
    runtime.onPredictionResult(4, 3);
    runtime.onScenarioSuccess();
    expect(runtime.current, 'n3');
    expect(runtime.isLessonCompleted, isTrue, reason: '进入终点 → 课时完成（D5）');
  });

  test('端到端：门禁拦截（未完成前置 → 不可跳入）', () {
    final model = buildModel();
    final plan = LessonPlan.fromJson(
      model.toLessonPlanJson(),
      scenarioPlayable: playable,
    );
    final runtime = LessonRuntime();
    runtime.load(plan);
    // n2 有门禁（unlock=完成 n1），但 n1 未完成 → 跳入被拒
    expect(runtime.isUnlocked('n2'), isFalse);
    expect(runtime.jumpTo('n2'), isFalse);
    expect(runtime.current, 'n1');
  });

  test('端到端：路由兜底（预测分不足 → 仍走末项 to）', () {
    final model = buildModel();
    final plan = LessonPlan.fromJson(
      model.toLessonPlanJson(),
      scenarioPlayable: playable,
    );
    final runtime = LessonRuntime();
    runtime.load(plan);
    runtime.onScenarioSuccess(); // n1 → n2
    // 预测分 1/4 = 0.25 < 0.5 → 条件不中 → 兜底末项（n3）
    runtime.onPredictionResult(4, 1);
    runtime.onScenarioSuccess();
    expect(runtime.current, 'n3');
    expect(runtime.isLessonCompleted, isTrue);
  });
}
