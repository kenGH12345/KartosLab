import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../common/scenario/lesson_manifest.dart';
import '../../common/scenario/lesson_plan.dart';
import '../../common/scenario/lesson_sim_host.dart';
import '../canvas/lesson_auto_layout.dart';
import '../models/editable_lesson_model.dart';

/// 剧本导入（T17 · F9 · AC-10/AC-11）。
///
/// 与 [LessonSaver] 配对闭环：读 `<lessonId>.json`（校验）+
/// `<lessonId>.layout.json`（布局还原 · T3），缺失布局走自动布局兜底
/// （交互指南 §7 降级）。
///
/// [loadString] 可注入（默认真实 rootBundle / dart:io，测试注入内存实现）。
@immutable
class LessonImporter {
  const LessonImporter({String? lessonsDir, this.loadString})
      : _lessonsDir = lessonsDir ?? LessonManifestLoader.lessonsDir;

  final String _lessonsDir;
  final Future<String> Function(String path)? loadString;

  Future<String> _read(String path) {
    final fn = loadString;
    if (fn != null) return fn(path);
    // 编辑器为桌面作者工具：直接用 dart:io 读磁盘（开发模式 CWD=项目根，
    // 与 LessonSaver 落盘路径一致 · T16 闭环）。
    return File(path).readAsString();
  }

  /// 读 manifest → 返回可导入的剧本清单（id/name/sim）。
  ///
  /// 直接读 `$_lessonsDir/manifest.json`（不依赖 LessonManifestLoader 的
  /// 固定 assets/lessons/ 路径常量，便于测试注入临时目录）。解析规则与
  /// loader 一致：缺/损坏 → 空列表；字段非法条目 → 跳过。
  Future<List<LessonManifestEntry>> listAvailable() async {
    final Map<String, dynamic> json;
    try {
      final raw = await _read('$_lessonsDir/manifest.json');
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return const [];
      json = decoded;
    } catch (e) {
      debugPrint('manifest 缺失或损坏，返回空列表: $e');
      return const [];
    }
    final rawLessons = json['lessons'];
    if (rawLessons is! List) return const [];
    final entries = <LessonManifestEntry>[];
    for (final raw in rawLessons) {
      if (raw is! Map<String, dynamic>) continue;
      final id = raw['id'];
      final file = raw['file'];
      final name = raw['name'];
      final sim = raw['sim'];
      if (id is! String ||
          id.isEmpty ||
          file is! String ||
          file.isEmpty ||
          name is! String ||
          sim is! String ||
          sim.isEmpty) {
        continue;
      }
      entries.add(LessonManifestEntry(id: id, file: file, name: name, sim: sim));
    }
    return entries;
  }

  /// 导入指定剧本（manifest entry → JSON + layout → EditableLessonModel）。
  ///
  /// 解析失败抛 [FormatException]（含 9 图校验失败 · 与 LessonPlan.fromJson
  /// 同契约 fail loud），由调用方弹窗展示错误。layout 缺失/损坏 → 自动布局。
  Future<EditableLessonModel> importByEntry(
    LessonManifestEntry entry, {
    bool Function(String sim, String scenarioId)? scenarioPlayable,
  }) async {
    final playable = scenarioPlayable ?? LessonSimHosts.scenarioPlayable();

    final raw = await _read('$_lessonsDir/${entry.file}');
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('课时 JSON 顶层不是对象');
    }
    // 校验（fail loud → 抛 FormatException）+ 布局还原（缺失 → 自动布局兜底）
    final plan = LessonPlan.fromJson(decoded, scenarioPlayable: playable);
    final savedLayout = await _readLayout(entry.id);
    // 已保存布局覆盖全部节点 → 直接采用（尊重用户手工排布）；否则用
    // LessonAutoLayout（entry 起 BFS 分层）填充缺失节点，避免全部堆叠在
    // 同一坐标点（M1）。已有坐标优先于自动布局结果。
    final hasFullLayout = plan.nodes.every((n) => savedLayout.containsKey(n.id));
    final layout = hasFullLayout
        ? savedLayout
        : {...LessonAutoLayout.layout(plan), ...savedLayout};

    return EditableLessonModel.fromLessonPlanJson(
      decoded,
      layout: layout,
    );
  }

  /// 读布局文件；缺失/损坏 → 返回空/部分 Map，由 [importByEntry] 结合
  /// [LessonAutoLayout] 兜底填充缺失节点坐标。
  Future<Map<String, Offset>> _readLayout(String lessonId) async {
    try {
      final raw = await _read('$_lessonsDir/$lessonId.layout.json');
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        debugPrint('layout 顶层不是对象，回退自动布局: $lessonId');
        return const {};
      }
      final nodes = decoded['nodes'];
      if (nodes is! Map<String, dynamic>) return const {};
      final layout = <String, Offset>{};
      for (final e in nodes.entries) {
        final v = e.value;
        if (v is Map<String, dynamic>) {
          layout[e.key] =
              Offset((v['x'] as num?)?.toDouble() ?? 0, (v['y'] as num?)?.toDouble() ?? 0);
        }
      }
      return layout;
    } catch (e) {
      debugPrint('layout 读取失败，回退自动布局: $e');
      return const {};
    }
  }
}
