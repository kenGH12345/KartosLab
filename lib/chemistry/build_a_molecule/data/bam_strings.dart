import 'dart:convert';

import 'package:flutter/services.dart';

/// Build-a-Molecule display names — Chinese defaults (PHASE 6).
///
/// Loads `strings_zh.json` by default; English asset retained for archaeology.
class BamStrings {
  BamStrings._();

  static Map<String, String> _values = {};
  static bool _loaded = false;

  static bool get isLoaded => _loaded;

  static Future<void> load([
    String assetPath = 'assets/data/build_a_molecule/strings_zh.json',
  ]) async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final map = <String, String>{};
    for (final entry in decoded.entries) {
      final value = entry.value;
      if (value is Map && value['value'] is String) {
        map[entry.key] = value['value'] as String;
      } else if (value is String) {
        map[entry.key] = value;
      }
    }
    _values = map;
    _loaded = true;
  }

  static String? lookup(String camelCaseKey) => _values[camelCaseKey];

  static String get(String camelCaseKey, [String? fallback]) =>
      _values[camelCaseKey] ?? fallback ?? camelCaseKey;

  /// PhET `StringUtils.fillIn` — replaces `{{key}}` tokens.
  static String fillIn(String pattern, Map<String, Object?> values) {
    var result = pattern;
    for (final entry in values.entries) {
      result = result.replaceAll('{{${entry.key}}}', '${entry.value ?? ''}');
    }
    return result;
  }
}
