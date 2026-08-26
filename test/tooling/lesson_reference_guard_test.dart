import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// T-P3-06 · 剧本引用守卫（AC-56/57/58 · CI 冗余层）。
///
/// 与 Dart 侧 D10 同口径的引用存在性 + 可完成性断言：
/// - 每个剧本节点引用的场景必须在对应 sim manifest 中（AC-56）
/// - 引用场景 objectives/successCriteria 非空且全部叶子 type ∈ 已实现集
/// - manifest entry 等值断言（D9）：entry.id == lessonId 且 entry.sim ==
///   entry 节点场景 sim（防 generate.py 写入与手写分叉）
/// - 红灯自证：构造引用不存在场景的内存剧本 → 守卫函数返回失败（AC-57）
/// - 附加断言：≥2 剧本 / ≥3 场景节点 / routes+unlock 剧本 / ≥1 混合 sim / nodeId 引用
void main() {
  /// sim → assets 子目录（与 generate.py SCENARIO_DIR_MAP 同口径；optics 平铺根）。
  const dirMap = {
    'circuit': 'circuit',
    'color_vision': 'color-vision',
    'forces': 'forces',
    'molarity': 'molarity',
    'optics': '',
    'radio_waves': 'radio-waves',
    'sound': 'sound',
    'wave_interference': 'wave-interference',
  };

  /// 各 sim 已实现叶子集（D10 同口径——与 lesson_sim_host.dart / generate.py 一致）。
  const implementedLeaves = {
    'circuit': {'circuitClosed', 'componentPowered', 'bulbBrightness', 'componentCount'},
    'color_vision': {'colorMatch'},
  };

  /// 剧本运行时宿主（D8）。
  const hostSims = {'circuit', 'color_vision'};

  String scenarioDir(String sim) {
    final sub = dirMap[sim]!;
    return sub.isEmpty ? 'assets/scenarios' : 'assets/scenarios/$sub';
  }

  List<String> _leaves(Object? cond) {
    if (cond is! Map<String, dynamic>) return const [];
    if (cond['type'] is String) return [cond['type'] as String];
    final out = <String>[];
    for (final key in ['all', 'any']) {
      final list = cond[key];
      if (list is List) {
        for (final sub in list) {
          out.addAll(_leaves(sub));
        }
      }
    }
    if (cond['not'] is Map<String, dynamic>) {
      out.addAll(_leaves(cond['not']));
    }
    return out;
  }

  /// 场景是否可用于剧本（存在 + 可完成 · D10）。
  bool _scenarioPlayableStatic(String sim, String scenarioId) {
    if (!hostSims.contains(sim)) return false;
    final dir = scenarioDir(sim);
    final manifestFile = File('$dir/manifest.json');
    if (!manifestFile.existsSync()) return false;
    final manifest =
        jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
    Map<String, dynamic>? entry;
    for (final e in (manifest['scenarios'] as List? ?? const [])) {
      final m = e as Map<String, dynamic>;
      if (m['id'] == scenarioId) {
        entry = m;
        break;
      }
    }
    if (entry == null) return false;
    final dataFile = File('$dir/${entry['file']}');
    if (!dataFile.existsSync()) return false;
    final data =
        jsonDecode(dataFile.readAsStringSync()) as Map<String, dynamic>;
    if (sim == 'color_vision') {
      if (data['screen'] != 'rgb') return false;
      final criteria = data['successCriteria'];
      if (criteria is! List || criteria.isEmpty) return false;
      final leaves = [for (final c in criteria) ..._leaves(c)];
      if (leaves.isEmpty) return false;
      if (leaves.any((t) => !implementedLeaves['color_vision']!.contains(t))) {
        return false;
      }
      if (leaves.where((t) => t == 'colorMatch').length > 1) return false;
      return true;
    }
    final obj = data['objectives'];
    if (obj is! Map<String, dynamic>) return false;
    final criteria = obj['successCriteria'];
    if (criteria is! List || criteria.isEmpty) return false;
    final leaves = [for (final c in criteria) ..._leaves(c)];
    if (leaves.isEmpty) return false;
    return leaves.every((t) => implementedLeaves['circuit']!.contains(t));
  }

  /// 守卫核心：剧本引用违规清单（空 = 通过）。独立函数供红灯自证复用。
  List<String> findReferenceViolations(Map<String, dynamic> lesson) {
    final problems = <String>[];
    final lessonId = lesson['lessonId'] ?? '?';
    final nodes = (lesson['nodes'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    for (final n in nodes) {
      final sc = n['scenario'];
      if (sc is! Map<String, dynamic>) continue; // 终点节点
      final sim = sc['sim'];
      final sid = sc['scenarioId'];
      if (sim is! String || sid is! String) {
        problems.add('$lessonId/${n['id']}: 场景引用缺 sim/scenarioId');
        continue;
      }
      if (!_scenarioPlayableStatic(sim, sid)) {
        problems.add('$lessonId/${n['id']}: 引用不可用场景 $sim/$sid');
      }
      // 条件叶子 nodeId 引用存在（D6 CI 层防线）
      final nodeIds = {for (final x in nodes) x['id'] as String?};
      void checkCond(Object? cond, String where) {
        if (cond is! Map<String, dynamic>) return;
        final type = cond['type'];
        if (type == 'nodeCompleted' || type == 'predictionScore') {
          final ref = (cond['params'] as Map?)?['nodeId'];
          if (ref is String && !nodeIds.contains(ref)) {
            problems.add('$lessonId/$where: 叶子 ${cond['id']} nodeId 悬空: $ref');
          }
        }
        for (final key in ['all', 'any']) {
          final list = cond[key];
          if (list is List) {
            for (final sub in list) {
              checkCond(sub, where);
            }
          }
        }
        if (cond['not'] is Map<String, dynamic>) {
          checkCond(cond['not'], where);
        }
      }

      final unlock = n['unlock'];
      if (unlock != null) checkCond(unlock, n['id']);
      final advance = n['advance'];
      if (advance is Map<String, dynamic>) {
        final routes = advance['routes'];
        if (routes is List) {
          for (var i = 0; i < routes.length; i++) {
            final w = (routes[i] as Map<String, dynamic>)['when'];
            if (w != null) checkCond(w, '${n['id']}.routes[$i]');
          }
        }
      }
    }
    return problems;
  }

  test('AC-56/58 + D9 · 全部注册剧本引用存在且 manifest 等值（CI 冗余层）', () {
    final manifestFile = File('assets/lessons/manifest.json');
    expect(manifestFile.existsSync(), isTrue, reason: 'lessons manifest 缺失');
    final manifest =
        jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
    final entries = (manifest['lessons'] as List).cast<Map<String, dynamic>>();
    expect(entries, isNotEmpty, reason: '剧本数量为 0 时守卫失败（防空转绿灯）');

    var totalScenarioNodes = 0;
    final simsCovered = <String>{};
    final hasRoutes = <String>{};
    final hasUnlock = <String>{};
    final mixedSims = <String>{};
    final allProblems = <String>[];

    for (final e in entries) {
      final file = File('assets/lessons/${e['file']}');
      expect(file.existsSync(), isTrue,
          reason: 'manifest 引用的剧本文件 ${e['file']} 缺失');
      final lesson =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

      // D9 等值断言：entry.id == lessonId
      expect(e['id'], lesson['lessonId'],
          reason: '${e['id']}: manifest entry.id 与剧本 lessonId 不一致');

      // 引用存在性 + 可完成性 + 叶子引用
      allProblems.addAll(findReferenceViolations(lesson));

      // 附加断言数据
      final nodes = (lesson['nodes'] as List).cast<Map<String, dynamic>>();
      final sceneNodes = nodes.where((n) => n['scenario'] is Map).toList();
      totalScenarioNodes += sceneNodes.length;
      final sims = {
        for (final n in sceneNodes)
          ((n['scenario'] as Map)['sim'] as String?) ?? '?'
      };
      simsCovered.addAll(sims);
      if (sims.length >= 2) mixedSims.add(e['id'] as String);
      for (final n in nodes) {
        final adv = n['advance'];
        if (adv is Map<String, dynamic> && adv['type'] == 'routes') {
          hasRoutes.add(e['id'] as String);
        }
        if (n['unlock'] != null) hasUnlock.add(e['id'] as String);
      }

      // D9：manifest entry.sim == entry 节点场景 sim（入口归属派生值）
      final entryId = lesson['entry'];
      final entryNode = nodes.firstWhere((n) => n['id'] == entryId);
      final entrySc = entryNode['scenario'];
      final derivedSim = entrySc is Map<String, dynamic>
          ? entrySc['sim']
          : (() {
              final first = nodes
                  .where((n) => n['scenario'] is Map<String, dynamic>)
                  .cast<Map<String, dynamic>>()
                  .firstOrNull;
              return first == null ? null : (first['scenario'] as Map)['sim'];
            })();
      expect(e['sim'], derivedSim,
          reason: '${e['id']}: manifest.sim 应与 D9 派生值一致（generate 写入与手写分叉防线）');
    }

    expect(allProblems, isEmpty, reason: '引用违规：\n  ${allProblems.join('\n  ')}');

    // AC-23/24/43/44/58 附加断言
    expect(simsCovered, containsAll(hostSims),
        reason: '试点剧本应覆盖 circuit + color_vision');
    expect(totalScenarioNodes, greaterThanOrEqualTo(9),
        reason: '各剧本 ≥3 场景节点（现有 5 剧本 × 3+）');
    expect(hasRoutes, isNotEmpty, reason: '应存在 routes 条件剧本（AC-43）');
    expect(hasUnlock, isNotEmpty, reason: '应存在 unlock 门禁剧本（AC-44）');
    expect(mixedSims, isNotEmpty, reason: '应存在 ≥1 条混合 sim 剧本（AC-58）');
  });

  test('AC-57 · 红灯自证：引用不存在场景 → 守卫函数返回违规', () {
    final lesson = {
      'lessonId': 'red-light-probe',
      'name': 'x',
      'version': '1.0',
      'description': 'x',
      'entry': 'n1',
      'nodes': [
        {
          'id': 'n1',
          'title': 'A',
          'scenario': {'sim': 'circuit', 'scenarioId': 'ghost-scenario'},
          'unlock': null,
          'advance': {'type': 'onCompleted', 'to': 'n-end'},
        },
        {
          'id': 'n-end',
          'title': 'End',
          'scenario': null,
          'unlock': null,
          'advance': null,
        },
      ],
    };
    final problems = findReferenceViolations(lesson);
    expect(problems, isNotEmpty,
        reason: '守卫必须能识别引用不存在场景（证明「场景删除→测试红灯」能力）');
    expect(problems.first, contains('ghost-scenario'));
  });
}
