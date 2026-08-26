// Dev-time semantic validator for AI-generated kratos scenarios.
//
// This is a Flutter test entry (NOT a pure-dart CLI) because every
// `<sim>/config/*_scenario.dart` transitively imports `package:flutter/material.dart`,
// which is unavailable to the standalone `dart run` VM. Run it via:
//
//   flutter test scripts/ai_scenario_gen/validate_test.dart \
//       --dart-define=SCENARIO_SIM=color_vision \
//       --dart-define=SCENARIO_PATH=/abs/path/to/scenario.json
//
// It routes the JSON to the sim-specific fromJson and fails the test (non-zero
// exit) if deserialization throws. This catches semantic errors a JSON Schema
// cannot. generate.py invokes exactly this command as its Dart gate.
//
// Invoked by scripts/ai_scenario_gen/generate.py as the second validation gate.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/molarity/config/molarity_scenario.dart';
import 'package:kratos/color_vision/config/color_vision_scenario.dart';
import 'package:kratos/circuit/config/circuit_scenario.dart';
import 'package:kratos/forces/config/forces_scenario.dart';
import 'package:kratos/optics/config/lab_scenario.dart';
import 'package:kratos/radio_waves/config/radio_waves_scenario.dart';
import 'package:kratos/sound/config/sound_scenario.dart';
import 'package:kratos/wave_interference/config/wave_interference_scenario.dart';

void main() {
  test('AI-generated scenario passes Dart semantic validation', () {
    final sim = const String.fromEnvironment('SCENARIO_SIM');
    final path = const String.fromEnvironment('SCENARIO_PATH');
    expect(sim, isNotEmpty, reason: 'SCENARIO_SIM dart-define is required');
    expect(path, isNotEmpty, reason: 'SCENARIO_PATH dart-define is required');

    final file = File(path);
    expect(file.existsSync(), isTrue, reason: 'scenario file not found: $path');

    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

    switch (sim) {
      case 'color_vision':
        ColorVisionScenario.fromJson(json);
      case 'circuit':
        CircuitScenario.fromJson(json);
      case 'forces':
        ForcesScenario.fromJson(json);
      case 'molarity':
        MolarityScenario.fromJson(json);
      case 'optics':
        LabScenario.fromJson(json);
      case 'radio_waves':
        RadioWavesScenario.fromJson(json);
      case 'sound':
        SoundScenario.fromJson(json);
      case 'wave_interference':
        WaveInterferenceScenario.fromJson(json);
      default:
        fail('unknown sim: $sim');
    }
  });
}
