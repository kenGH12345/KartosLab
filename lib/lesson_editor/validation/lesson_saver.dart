import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/editable_lesson_model.dart';

/// 剧本保存（T16 · F10 · AC-12/AC-13）。
///
/// 按技术方案 §7.3 写三件：
/// 1. `<lessonId>.json` —— lesson.schema.json 契约（`toLessonPlanJson`）
/// 2. `<lessonId>.layout.json` —— 节点布局（T3 · editor-only，运行时忽略）
/// 3. `manifest.json` —— lessons 数组增/覆盖（entry 归属 sim = entry 节点）
///
/// 落点 [lessonsDir] 可注入（默认 `assets/lessons/`，开发模式下
/// Directory.current = 项目根，rootBundle 从磁盘加载 → 保存产物可被
/// `LessonRuntime.load()` 读到 · AC-13 闭环）。测试注入临时目录。
///
/// 失败兜底（交互指南 §6.2）：返回错误消息，不丢编辑态（调用方保留内存模型）。
@immutable
class LessonSaver {
  const LessonSaver({String? lessonsDir}) : _lessonsDir = lessonsDir ?? 'assets/lessons/';

  final String _lessonsDir;

  /// 保存剧本。成功返回 null；失败返回错误消息。
  Future<String?> save(EditableLessonModel model) async {
    try {
      final dir = Directory(_lessonsDir);
      if (!await dir.exists()) {
        return '保存目录不存在: $_lessonsDir（开发模式请在项目根运行）';
      }

      // 1. 剧本 JSON
      final planJson = const JsonEncoder.withIndent('  ')
          .convert(model.toLessonPlanJson());
      await File('$_lessonsDir/${model.lessonId}.json').writeAsString(planJson);

      // 2. 布局 JSON（T3 · editor-only）
      final layoutJson = jsonEncode({
        'lessonId': model.lessonId,
        'version': '1',
        'nodes': {
          for (final e in model.layout.entries)
            e.key: {'x': e.value.dx, 'y': e.value.dy},
        },
      });
      await File('$_lessonsDir/${model.lessonId}.layout.json')
          .writeAsString(layoutJson);

      // 3. manifest 更新（读 → 增/覆盖 → 写回）
      await _updateManifest(model);

      return null;
    } on FileSystemException catch (e) {
      return '写入失败（${e.osError?.message ?? e.message}）';
    } on FormatException catch (e) {
      return '序列化失败: $e';
    }
  }

  /// 更新 manifest.json 的 lessons 数组（同 lessonId 覆盖，否则追加）。
  Future<void> _updateManifest(EditableLessonModel model) async {
    final manifestPath = '$_lessonsDir/manifest.json';
    final manifestFile = File(manifestPath);
    final Map<String, dynamic> manifest = manifestFile.existsSync()
        ? (jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>)
        : {'version': '1.0', 'lessons': []};

    final lessons = manifest['lessons'];
    final list = lessons is List ? lessons : <dynamic>[];
    final entry = {
      'id': model.lessonId,
      'file': '${model.lessonId}.json',
      'name': model.name,
      'sim': _entrySim(model),
    };
    final idx = list.indexWhere(
      (e) => e is Map && e['id'] == model.lessonId,
    );
    if (idx >= 0) {
      list[idx] = entry;
    } else {
      list.add(entry);
    }
    manifest['lessons'] = list;

    await manifestFile.writeAsString(jsonEncode(manifest));
  }

  /// manifest sim 字段 = entry 节点场景的 sim（D9 · 混合剧本取 entry）。
  String _entrySim(EditableLessonModel model) {
    for (final n in model.nodes) {
      if (n.id == model.entry && n.scenario != null) return n.scenario!.sim;
    }
    return '';
  }
}
