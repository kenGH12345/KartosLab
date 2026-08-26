import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// T-P3-04/05 e2e · generate.py --lesson 全链路自动化验证。
///
/// 经 Dart `Process.run` 的 input 参数直接传子进程 stdin（UTF-8，无 shell
/// 管道编码问题——绕开 Windows PowerShell/cmd 的 GBK 管道坑，该坑记录见
/// requirements/req-lesson-runtime/notes.md）。本文件永久入 CI（`flutter test`）。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const gen = 'scripts/ai_scenario_gen/generate.py';
  final tmpFiles = <String>[];
  tearDownAll(() {
    for (final f in tmpFiles) {
      final file = File(f);
      if (file.existsSync()) file.deleteSync();
    }
    // 自清理 --write 产物（防污染 assets/lessons 与 schema/守卫测试）
    final written = File('assets/lessons/gen-e2e-test.json');
    if (written.existsSync()) written.deleteSync();
    final mf = File('assets/lessons/manifest.json');
    if (mf.existsSync()) {
      final manifest =
          jsonDecode(mf.readAsStringSync()) as Map<String, dynamic>;
      (manifest['lessons'] as List)
          .removeWhere((e) => (e as Map)['id'] == 'gen-e2e-test');
      mf.writeAsStringSync(jsonEncode(manifest), encoding: utf8);
    }
  });

  /// 经 Process.start 手动写 stdin（UTF-8 直传子进程，无 shell 管道编码问题）。
  Future<ProcessResult> runGen(List<String> args, {String? input}) async {
    final proc = await Process.start(
        'python', [gen, '--lesson', '--topic', 'e2e', ...args]);
    if (input != null) {
      proc.stdin.write(input);
    }
    await proc.stdin.close();
    final out = await proc.stdout.transform(utf8.decoder).join();
    final err = await proc.stderr.transform(utf8.decoder).join();
    final code = await proc.exitCode;
    return ProcessResult(0, code, out, err);
  }

  String readLesson(String name) {
    final f = '${Directory.systemTemp.path}/lesson_gen_$name.json';
    tmpFiles.add(f);
    return f;
  }

  test('AC-52 + T-P3-05 · --print-prompt 含注入清单且无占位符残留', () async {
    final r = await runGen(['--print-prompt']);
    expect(r.exitCode, 0, reason: 'stdout:\n${r.stdout}');
    final out = '${r.stdout}';
    expect(out, isNot(contains('{{SCENARIO_IDS}}')), reason: '占位符应被替换');
    // 清单含可完成场景、剔除不可完成场景（预过滤）
    expect(out, contains('`controlled-switch`'));
    expect(out, contains('rgb-challenge-basic'));
    expect(out, isNot(contains('rgb-dark-room')), reason: '不可完成场景应剔除');
    expect(out, contains('被排除'));
  });

  test('AC-53/54 · 正例 stdin → 落盘 + manifest 追加（D9 sim 派生）', () async {
    final tmp = readLesson('pos');
    File(tmp).writeAsStringSync(jsonEncode({
      'lessonId': 'gen-e2e-test',
      'name': 'E2E Test',
      'version': '1.0',
      'description': 'e2e',
      'entry': 'n1',
      'nodes': [
        {
          'id': 'n1',
          'title': 'A',
          'scenario': {
            'sim': 'circuit',
            'scenarioId': 'controlled-switch',
          },
          'unlock': null,
          'advance': {'type': 'onCompleted', 'to': 'n2'},
        },
        {
          'id': 'n2',
          'title': 'B',
          'scenario': {
            'sim': 'circuit',
            'scenarioId': 'open-circuit-debug',
          },
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
    }), encoding: utf8);

    final r = await runGen(['--from-stdin', '--skip-dart', '--write'],
        input: File(tmp).readAsStringSync());
    expect(r.exitCode, 0, reason: 'stdout:\n${r.stdout}\nstderr:\n${r.stderr}');
    expect('${r.stdout}', contains('WROTE'));

    // 落盘 + manifest 追加（含 D9 sim=entry 节点 sim）
    expect(File('assets/lessons/gen-e2e-test.json').existsSync(), isTrue);
    final manifest = jsonDecode(
            File('assets/lessons/manifest.json').readAsStringSync())
        as Map<String, dynamic>;
    final entries = (manifest['lessons'] as List).cast<Map<String, dynamic>>();
    final entry = entries.firstWhere((e) => e['id'] == 'gen-e2e-test');
    expect(entry['sim'], 'circuit', reason: 'D9：sim = entry 节点 scenario.sim');
    expect(entry['name'], 'E2E Test');
  });

  test('AC-55 · 引用不存在场景 → 拒绝（exit 非零 + 报错信息）', () async {
    final tmp = readLesson('badref');
    File(tmp).writeAsStringSync(jsonEncode({
      'lessonId': 'gen-e2e-badref',
      'name': 'Bad Ref',
      'version': '1.0',
      'description': 'e2e bad ref',
      'entry': 'n1',
      'nodes': [
        {
          'id': 'n1',
          'title': 'Ghost',
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
    }), encoding: utf8);

    final r = await runGen(['--from-stdin', '--skip-dart'],
        input: File(tmp).readAsStringSync());
    expect(r.exitCode, isNot(0), reason: '引用幻觉应被拒绝');
    expect('${r.stdout}${r.stderr}', contains('unavailable scenarios'));
  });

  test('AC-53 · schema 违规（advance.type 非法）→ 拒绝', () async {
    final tmp = readLesson('badschema');
    File(tmp).writeAsStringSync(jsonEncode({
      'lessonId': 'gen-e2e-badschema',
      'name': 'Bad Schema',
      'version': '1.0',
      'description': 'e2e bad schema',
      'entry': 'n1',
      'nodes': [
        {
          'id': 'n1',
          'title': 'A',
          'scenario': {
            'sim': 'circuit',
            'scenarioId': 'controlled-switch',
          },
          'unlock': null,
          'advance': {'type': 'teleport', 'to': 'n-end'},
        },
        {
          'id': 'n-end',
          'title': 'End',
          'scenario': null,
          'unlock': null,
          'advance': null,
        },
      ],
    }), encoding: utf8);

    final r = await runGen(['--from-stdin', '--skip-dart'],
        input: File(tmp).readAsStringSync());
    expect(r.exitCode, isNot(0), reason: 'schema 违规应被拒绝');
    expect('${r.stdout}${r.stderr}', contains('LESSON SCHEMA VALIDATION FAILED'));
  });
}
