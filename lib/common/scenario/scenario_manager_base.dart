import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Generic scenario manager base class.
///
/// Extracted from 3 existing implementations (optics 204 lines, circuit 161 lines,
/// forces 38 lines) via 3-Time Rule.
///
/// ## Type Parameters
/// - **TScenario**: the scenario data class (e.g. `LabScenario`, `CircuitScenario`).
/// - **TState**: the domain state constructed from a scenario (e.g. `OpticsWorld`, `CircuitState`).
///
/// ## Subclass Contract
/// Must provide:
/// - [manifestPath] -- asset path to manifest JSON
/// - [scenarioPath] -- asset path template for individual scenario files
/// - [fromJson] -- tear-off to scenario factory/constructor
/// - [scenarioId] -- tear-off to read id from a parsed scenario
/// - [buildInitialState] -- domain-specific state construction from a scenario
///
/// May override:
/// - [entryKey] -- if manifest uses a key other than `'id'` (e.g. forces uses `'file'`)
/// - [validateConstraints] -- if the sim has constraints
/// - [checkObjectives] -- if the sim has learning objectives
///
/// Base provides:
/// - [scenarios] -- immutable view of all loaded scenarios
/// - [loadScenarios] -- manifest reading + individual JSON loading + single-failure skip
/// - [findById] -- lookup by scenario ID
/// - [loadScenario] -- find + build initial state
abstract class ScenarioManagerBase<TScenario, TState> {
  final List<TScenario> _scenarios = [];

  // ---------------------------------------------------------------------------
  // Subclass must provide
  // ---------------------------------------------------------------------------

  /// Asset path to the manifest JSON file.
  String get manifestPath;

  /// Build the asset path for a scenario file from the manifest entry key.
  String scenarioPath(String entryKey);

  /// Tear-off to the scenario factory constructor.
  TScenario Function(Map<String, dynamic>) get fromJson;

  /// Tear-off to read the scenario identifier from a parsed scenario instance.
  String Function(TScenario) get scenarioId;

  /// Construct domain-specific state from a parsed scenario.
  TState Function(TScenario) get buildInitialState;

  // ---------------------------------------------------------------------------
  // Subclass may override
  // ---------------------------------------------------------------------------

  /// Extract the entry key from a manifest entry dict.
  ///
  /// Default returns `entry['id']` (convention used by optics and circuit).
  String entryKey(Map<String, dynamic> entry) => entry['id'] as String;

  /// Validate constraints against the given state.
  /// Default returns empty -- override for sims that have constraints.
  List<dynamic> validateConstraints(TState state) => [];

  /// Check if learning objectives are achieved.
  /// Default returns true -- override for sims that have objectives.
  bool checkObjectives(TState state) => true;

  // ---------------------------------------------------------------------------
  // Provided by base
  // ---------------------------------------------------------------------------

  /// Immutable view of all loaded scenarios.
  List<TScenario> get scenarios => List.unmodifiable(_scenarios);

  /// Load all scenarios from the manifest.
  Future<void> loadScenarios() async {
    try {
      final manifestStr = await rootBundle.loadString(manifestPath);
      final manifest = jsonDecode(manifestStr) as Map<String, dynamic>;
      final entries = (manifest['scenarios'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

      _scenarios.clear();
      for (final entry in entries) {
        final key = entryKey(entry);
        try {
          final jsonStr = await rootBundle.loadString(scenarioPath(key));
          final scenario =
              fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
          _scenarios.add(scenario);
        } catch (e) {
          debugPrint('Failed to load scenario $key: $e');
        }
      }
    } catch (e) {
      debugPrint('Failed to load scenarios manifest: $e');
    }
  }

  /// Find a scenario by its id. Returns null if not found.
  TScenario? findById(String id) {
    try {
      return _scenarios.firstWhere((s) => scenarioId(s) == id);
    } catch (_) {
      return null;
    }
  }

  /// Load and build initial state for the scenario with the given [id].
  TState loadScenario(String id) {
    final scenario = findById(id);
    if (scenario == null) {
      throw Exception('Scenario not found: $id');
    }
    return buildInitialState(scenario);
  }
}
