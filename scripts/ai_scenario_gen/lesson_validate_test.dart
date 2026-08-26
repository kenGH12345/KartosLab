// Dev-time semantic validator for AI-generated kratos lessons (lesson plans).
//
// Mirrors `validate_test.dart` (scenario gate) but for lesson JSON: it runs the
// full Dart graph validation (LessonPlan.fromJson: entry reachability, D5/D7
// invariants, route/leaf refs) **plus** the scenarioPlayable gate (D10:
// referenced scenes must exist and be completable). JSON Schema cannot express
// these; generate.py --lesson invokes exactly this command as its Dart gate.
//
//   flutter test scripts/ai_scenario_gen/lesson_validate_test.dart \
//       --dart-define=LESSON_PATH=/abs/path/to/lesson.json
//
// NOTE: needs rootBundle (real scenario manifests) → TestWidgetsFlutterBinding.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/common/scenario/lesson_plan.dart';
import 'package:kratos/common/scenario/lesson_sim_host.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AI-generated lesson passes Dart semantic validation (graph + D10)', () async {
    final path = const String.fromEnvironment('LESSON_PATH');
    expect(path, isNotEmpty, reason: 'LESSON_PATH dart-define is required');

    final file = File(path);
    expect(file.existsSync(), isTrue, reason: 'lesson file not found: $path');

    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

    // D10 gate: real manifests must be loaded for scenarioPlayable to resolve.
    await LessonSimHosts.ensureManagersLoaded();

    // Throws FormatException on any graph/D5/D7/reference violation.
    LessonPlan.fromJson(json,
        scenarioPlayable: LessonSimHosts.scenarioPlayable());
  });
}
