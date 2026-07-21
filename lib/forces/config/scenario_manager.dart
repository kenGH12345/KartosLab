import 'dart:convert';
import 'package:flutter/services.dart';
import 'forces_scenario.dart';

class ForcesScenarioManager {
  final List<ForcesScenario> _scenarios = [];

  List<ForcesScenario> get scenarios => List.unmodifiable(_scenarios);

  Future<void> loadScenarios() async {
    final manifestStr = await rootBundle.loadString('assets/scenarios/forces/manifest.json');
    final manifest = jsonDecode(manifestStr) as Map<String, dynamic>;
    final list = manifest['scenarios'] as List<dynamic>;

    _scenarios.clear();
    for (final entry in list) {
      final e = entry as Map<String, dynamic>;
      final file = e['file'] as String;
      final src = await rootBundle.loadString('assets/scenarios/forces/$file');
      final data = jsonDecode(src) as Map<String, dynamic>;
      _scenarios.add(ForcesScenario.fromJson(data));
    }
  }

  ForcesScenario loadScenario(String scenarioId) {
    final s = _scenarios.firstWhere((s) => s.scenarioId == scenarioId);
    return s;
  }

  ForcesScenario? tryLoad(String scenarioId) {
    try {
      return _scenarios.firstWhere((s) => s.scenarioId == scenarioId);
    } catch (_) {
      return null;
    }
  }
}
