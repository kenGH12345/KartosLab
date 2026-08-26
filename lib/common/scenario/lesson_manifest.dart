import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'lesson_plan.dart';

/// lessons manifest 单条注册项。
@immutable
class LessonManifestEntry {
  const LessonManifestEntry({
    required this.id,
    required this.file,
    required this.name,
    required this.sim,
  });

  /// 剧本 id（= lessonId，守卫测试等值断言）。
  final String id;

  /// 相对 assets/lessons/ 的文件名。
  final String file;

  /// 课时显示名（入口卡片用）。
  final String name;

  /// 入口归属 sim（D9）：① 首页入口卡片分组挂载依据；② 混合 sim 剧本取
  /// entry 节点的 scenario.sim（入口归属与首节点体验一致）。
  /// 仅作分组/挂载用——运行态各节点宿主由 node.scenario.sim 经
  /// LessonSimHosts.dispatch() 逐节点决定，与本字段解耦。
  final String sim;
}

/// lessons manifest 加载器：读注册表 → 逐剧本加载解析 → 课时级降级。
///
/// 资源读取经 [assetLoader] 注入（默认 rootBundle），测试可注入内存/
/// 文件实现而不依赖 Flutter binding（T-P1-03 测试可测性约定）。
class LessonManifestLoader {
  LessonManifestLoader({Future<String> Function(String path)? assetLoader})
      : _loadString = assetLoader ?? rootBundle.loadString;

  static const String manifestPath = 'assets/lessons/manifest.json';
  static const String lessonsDir = 'assets/lessons/';

  final Future<String> Function(String path) _loadString;

  /// 仅读 manifest 注册表（入口卡片展示用，不解析剧本本体——延迟解析降开销）。
  ///
  /// manifest 本身缺失或损坏 → 返回空列表（首页无课时入口，传统模式
  /// 不受影响，AC-17 / AC-14 降级路径）。单条 entry 字段非法 → 跳过该条。
  Future<List<LessonManifestEntry>> loadEntries() async {
    final Map<String, dynamic> json;
    try {
      final raw = await _loadString(manifestPath);
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        debugPrint('lessons manifest 顶层不是对象');
        return const [];
      }
      json = decoded;
    } catch (e) {
      debugPrint('lessons manifest 缺失或损坏，返回空列表: $e');
      return const [];
    }

    final rawLessons = json['lessons'];
    if (rawLessons is! List) {
      debugPrint('lessons manifest 缺少 lessons 数组');
      return const [];
    }

    final entries = <LessonManifestEntry>[];
    for (final raw in rawLessons) {
      if (raw is! Map<String, dynamic>) {
        debugPrint('lessons manifest 含非对象条目，跳过: $raw');
        continue;
      }
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
        debugPrint('lessons manifest 条目字段非法，跳过: $raw');
        continue;
      }
      entries
          .add(LessonManifestEntry(id: id, file: file, name: name, sim: sim));
    }
    return entries;
  }

  /// 加载全部课时。单课时失败（文件缺失 / JSON 损坏 / LessonPlan.fromJson
  /// 抛 FormatException）→ debugPrint 警告 + 跳过该课时，不抛出、不阻塞其他
  /// 课时（AC-6 / AC-15 课时级降级）。
  ///
  /// catch 宽类型 `Exception`（评审 Minor-4 约定）：防 TypeError 等非
  /// FormatException 穿透课时级降级直达入口点击处。
  Future<List<LessonPlan>> loadAll({
    required bool Function(String sim, String scenarioId) scenarioPlayable,
  }) async {
    final entries = await loadEntries();
    final plans = <LessonPlan>[];
    for (final e in entries) {
      try {
        final raw = await _loadString('$lessonsDir${e.file}');
        final decoded = jsonDecode(raw);
        if (decoded is! Map<String, dynamic>) {
          throw FormatException('课时 JSON 顶层不是对象');
        }
        plans.add(LessonPlan.fromJson(decoded,
            scenarioPlayable: scenarioPlayable));
      } catch (err) {
        debugPrint('课时 ${e.id} 加载失败，跳过（课时级降级）: $err');
      }
    }
    return plans;
  }
}
