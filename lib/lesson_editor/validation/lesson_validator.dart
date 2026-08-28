import 'package:flutter/foundation.dart';

import '../models/editable_lesson_model.dart';
import '../../common/scenario/lesson_plan.dart';
import '../../common/scenario/lesson_sim_host.dart';

/// 校验结果（T13 · F8 · AC-9/AC-12）。
@immutable
class LessonValidationResult {
  const LessonValidationResult({required this.errors, required this.warnings});

  /// 阻断保存的错误清单（空 = 可保存）。
  final List<String> errors;

  /// 不阻断的警告清单（如 sim 冲突 · F14 后续接入）。
  final List<String> warnings;

  bool get isValid => errors.isEmpty;
}

/// 剧本校验器（T13 · F8）。
///
/// 复用运行时 [LessonPlan.fromJson] 的 9 条图校验（fail loud → 收集为错误
/// 清单）+ 编辑器特有轻量检查（占位 sim / entry 未设）。
///
/// - [scenarioPlayable] 注入真实 [LessonSimHosts.scenarioPlayable]：未接线
///   sim / 不可完成场景在解析期被拦截（错误信息已带节点 id，可定位）。
/// - 设计意图：编辑态允许中间态（占位 sim=''、entry 未设），保存前调用
///   本校验器，不通过则阻止保存并展示错误项（AC-9）。
class LessonValidator {
  const LessonValidator._();

  /// 校验可编辑模型。返回错误/警告清单。
  ///
  /// [scenarioPlayable] 可注入（默认真实 [LessonSimHosts.scenarioPlayable]），
  /// 便于测试/沙箱环境隔离 asset 依赖（与 [LessonPlan.fromJson] 同款依赖倒置）。
  static LessonValidationResult validate(
    EditableLessonModel model, {
    bool Function(String sim, String scenarioId)? scenarioPlayable,
  }) {
    final errors = <String>[];
    final warnings = <String>[];
    final playable =
        scenarioPlayable ?? LessonSimHosts.scenarioPlayable();

    // ---- 1. 轻量检查：entry / 占位 scenario / 标题 ----
    if (model.entry == null || model.entry!.isEmpty) {
      errors.add('未指定入口节点（entry）——请在剧本设置中选择课时入口');
    }
    if (model.name.isEmpty) {
      errors.add('剧本缺少名称（name）');
    }
    if (model.lessonId.isEmpty) {
      errors.add('剧本缺少 lessonId');
    }
    for (final n in model.nodes) {
      if (n.title.isEmpty) {
        errors.add('节点 "${n.id}" 缺少标题');
      }
      final sc = n.scenario;
      if (!n.isEnd && (sc == null || sc.sim.isEmpty || sc.scenarioId.isEmpty)) {
        errors.add('节点 "${n.id}" 未绑定有效场景（请在属性面板选择 sim 与场景）');
      }
    }

    // ---- 2. 复用运行时 9 条图校验（fail loud → 收集） ----
    if (errors.where((e) => e.contains('entry')).isEmpty || model.entry != null) {
      try {
        LessonPlan.fromJson(
          model.toLessonPlanJson(),
          scenarioPlayable: playable,
        );
      } on FormatException catch (e) {
        // 错误信息已带 lessonId/节点 id 前缀，可直接展示（AC-2 族格式）
        errors.add(e.message);
      } catch (e) {
        errors.add('解析失败（${e.runtimeType}）: $e');
      }
    }

    return LessonValidationResult(errors: errors, warnings: warnings);
  }
}
