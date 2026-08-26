import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// T-P3-02 · lesson.schema.json 校验测试（正例全过 + 反例拒绝）。
///
/// 校验引擎：python jsonschema（与 generate.py 同源）——
/// `scripts/ai_scenario_gen/validate_lesson_schema.py`（测试与工具共享单一
/// 入口，永不漂移）。结构校验在此；图校验（可达性/D5/D7/引用）在 Dart 层。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const script = 'scripts/ai_scenario_gen/validate_lesson_schema.py';

  ProcessResult runScript(List<String> args) {
    return Process.runSync('python', [script, ...args]);
  }

  /// 反例临时文件（测试后清理）。
  final tmpFiles = <String>[];
  tearDownAll(() {
    for (final f in tmpFiles) {
      final file = File(f);
      if (file.existsSync()) file.deleteSync();
    }
  });

  String writeTempLesson(Map<String, dynamic> json, String label) {
    final f = '${Directory.systemTemp.path}/lesson_schema_$label.json';
    File(f).writeAsStringSync(jsonEncode(json), encoding: utf8);
    tmpFiles.add(f);
    return f;
  }

  Map<String, dynamic> baseLesson() => {
        'lessonId': 'schema-pos',
        'name': '正例',
        'version': '1.0',
        'description': 'x',
        'entry': 'a',
        'nodes': [
          {
            'id': 'a',
            'title': 'A',
            'scenario': {'sim': 'circuit', 'scenarioId': 'controlled-switch'},
            'advance': {'type': 'onCompleted', 'to': 'n-end'},
          },
          {'id': 'n-end', 'title': '完', 'scenario': null, 'advance': null},
        ],
      };

  test('AC-46 · schema 文件存在且 jsonschema 可构造（无输入 exit 0）', () {
    expect(File('schemas/lesson.schema.json').existsSync(), isTrue);
    final r = runScript([]);
    expect(r.exitCode, 0, reason: 'stdout:\n${r.stdout}\nstderr:\n${r.stderr}');
  });

  test('AC-47 · assets/lessons/ 全部试点剧本通过校验（5/5 · 含混合与条件）', () {
    final dir = Directory('assets/lessons');
    final lessons = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json') && !f.path.endsWith('manifest.json'))
        .map((f) => f.path)
        .toList();
    expect(lessons, hasLength(5), reason: '应有 5 条试点剧本');

    final r = runScript(lessons);
    expect(r.exitCode, 0, reason: 'stdout:\n${r.stdout}\nstderr:\n${r.stderr}');
  });

  group('AC-48 + D1 · 反例拒绝', () {
    void expectRejected(Map<String, dynamic> json, String label,
        Pattern messageHint) {
      final f = writeTempLesson(json, label);
      final r = runScript([f]);
      expect(r.exitCode, isNot(0),
          reason: '反例 $label 应被 schema 拒绝（exit 非零）');
      expect('${r.stdout}', contains(messageHint));
    }

    test('缺 entry 顶层字段', () {
      final j = baseLesson()..remove('entry');
      expectRejected(j, 'no_entry', "'entry'");
    });

    test('advance.type 非法值', () {
      final j = baseLesson();
      (j['nodes'] as List)[0]['advance'] = {'type': 'teleport', 'to': 'x'};
      expectRejected(j, 'bad_type', 'teleport');
    });

    test('叶子 type 非法值', () {
      final j = baseLesson();
      (j['nodes'] as List)[0]['unlock'] = {
        'id': 'u1',
        'type': 'alienLeaf',
        'description': 'x',
        'params': {'nodeId': 'a'},
      };
      expectRejected(j, 'bad_leaf', 'alienLeaf');
    });

    test('scenario.sim 非试点（molarity）', () {
      final j = baseLesson();
      (j['nodes'] as List)[0]['scenario'] = {
        'sim': 'molarity',
        'scenarioId': 'x',
      };
      expectRejected(j, 'bad_sim', 'molarity');
    });

    test('routes 为空数组', () {
      final j = baseLesson();
      (j['nodes'] as List)[0]['advance'] = {'type': 'routes', 'routes': []};
      expectRejected(j, 'empty_routes', 'routes');
    });

    test('D1 · 叶子缺 id（oneOf 任一分支不匹配 → 通用 oneOf 错误）', () {
      final j = baseLesson();
      (j['nodes'] as List)[0]['unlock'] = {
        'type': 'nodeCompleted',
        'description': 'x',
        'params': {'nodeId': 'a'},
      };
      expectRejected(j, 'leaf_no_id', 'is not valid under any');
    });

    test('D1 · 叶子缺 description', () {
      final j = baseLesson();
      (j['nodes'] as List)[0]['unlock'] = {
        'id': 'u1',
        'type': 'nodeCompleted',
        'params': {'nodeId': 'a'},
      };
      expectRejected(j, 'leaf_no_desc', 'is not valid under any');
    });
    // 注：D5 二元绑定（非终点必须有 advance）属图校验（Dart 层
    // LessonPlan.fromJson）——schema 只做结构校验，不在本文件重复断言。
  });
}
