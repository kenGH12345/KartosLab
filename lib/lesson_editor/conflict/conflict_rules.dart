import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// 冲突规则集（T19 · F14 · T5 · AC-18/AC-21）。
///
/// 加载 `assets/editor/sim_conflict_rules.json`：
/// - `allowedCombos`：白名单 sim 组合（无序匹配），默认含 circuit↔color_vision
///   → 已验收混合剧本（AC-58 同型）零警告（AC-21）
/// - `warnCombos`：教学语义冲突组合（有序 from→to）+ reason
///
/// 加载失败 → 降级态（[isDegraded] = true）：仅保留数据传递冲突检查
/// （C8 · 失败降级不 crash）。未知组合（不在 allowed 亦不在 warn）→
/// 保守放行不报错（交互指南 §4.5）。
@immutable
class ConflictRuleSet {
  const ConflictRuleSet({
    this.version = '1',
    this.allowedCombos = const [],
    this.warnCombos = const [],
    this.isDegraded = false,
  });

  final String version;
  final List<(String, String)> allowedCombos;
  final List<WarnCombo> warnCombos;

  /// 规则表加载失败（降级态）。
  final bool isDegraded;

  /// 加载规则表；[loadString] 可注入（测试用）。失败 → 降级态不抛出。
  static Future<ConflictRuleSet> load({Future<String> Function(String)? loadString}) async {
    try {
      final raw = loadString != null
          ? await loadString('assets/editor/sim_conflict_rules.json')
          : await rootBundle.loadString('assets/editor/sim_conflict_rules.json');
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const ConflictRuleSet(isDegraded: true);
      }
      final allowed = <(String, String)>[];
      final rawAllowed = decoded['allowedCombos'];
      if (rawAllowed is List) {
        for (final pair in rawAllowed) {
          if (pair is List && pair.length == 2 && pair[0] is String && pair[1] is String) {
            allowed.add((pair[0] as String, pair[1] as String));
          }
        }
      }
      final warns = <WarnCombo>[];
      final rawWarns = decoded['warnCombos'];
      if (rawWarns is List) {
        for (final w in rawWarns) {
          if (w is Map<String, dynamic> &&
              w['from'] is String &&
              w['to'] is String) {
            warns.add(
              WarnCombo(
                from: w['from'] as String,
                to: w['to'] as String,
                reason: (w['reason'] as String?) ?? '教学衔接需人工确认',
              ),
            );
          }
        }
      }
      return ConflictRuleSet(
        version: (decoded['version'] as String?) ?? '1',
        allowedCombos: allowed,
        warnCombos: warns,
      );
    } catch (e) {
      debugPrint('sim_conflict_rules.json 加载失败，降级为仅数据传递检查: $e');
      return const ConflictRuleSet(isDegraded: true);
    }
  }

  /// from→to 是否白名单放行（无序匹配，AC-21）。
  bool isAllowed(String a, String b) {
    for (final (x, y) in allowedCombos) {
      if ((x == a && y == b) || (x == b && y == a)) return true;
    }
    return false;
  }

  /// 查教学语义冲突（有序 from→to）。未命中返回 null。
  WarnCombo? findWarn(String from, String to) {
    for (final w in warnCombos) {
      if (w.from == from && w.to == to) return w;
    }
    return null;
  }
}

/// 教学语义冲突规则条目（warnCombos 元素）。
@immutable
class WarnCombo {
  const WarnCombo({required this.from, required this.to, required this.reason});

  final String from;
  final String to;
  final String reason;
}
