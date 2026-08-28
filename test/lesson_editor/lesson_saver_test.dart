import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/scenario/lesson_plan.dart';
import 'package:kratos/lesson_editor/models/editable_lesson_model.dart';
import 'package:kratos/lesson_editor/validation/lesson_saver.dart';

void main() {
  late Directory tmp;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('lesson_saver_test_');
  });

  tearDown(() {
    tmp.deleteSync(recursive: true);
  });

  EditableLessonModel model({String lessonId = 'test-lesson'}) {
    return EditableLessonModel(
      lessonId: lessonId,
      name: '测试课时',
      entry: 'n1',
      nodes: const [
        EditableNode(
          id: 'n1',
          title: '场景1',
          scenario: LessonScenarioRef(sim: 'circuit', scenarioId: 'rgb'),
          advance: LessonAdvance(type: 'onCompleted', to: 'n2'),
        ),
        EditableNode(id: 'n2', title: '终点'),
      ],
      layout: const {'n1': Offset(0, 0), 'n2': Offset(0, 100)},
    );
  }

  group('LessonSaver.save（T16）', () {
    test('写入三件：json + layout.json + manifest', () async {
      final saver = LessonSaver(lessonsDir: tmp.path);
      final err = await saver.save(model());
      expect(err, isNull);

      // 1. 剧本 JSON
      final planJson =
          jsonDecode(await File('${tmp.path}/test-lesson.json').readAsString())
              as Map<String, dynamic>;
      expect(planJson['lessonId'], 'test-lesson');
      expect(planJson['nodes'], hasLength(2));
      expect(planJson.containsKey('layout'), isFalse); // 布局不进入 schema 契约

      // 2. layout JSON
      final layoutJson = jsonDecode(
              await File('${tmp.path}/test-lesson.layout.json').readAsString())
          as Map<String, dynamic>;
      final nodes = layoutJson['nodes'] as Map<String, dynamic>;
      expect(nodes['n1'], {'x': 0, 'y': 0});
      expect(nodes['n2'], {'x': 0, 'y': 100});

      // 3. manifest
      final manifest = jsonDecode(
              await File('${tmp.path}/manifest.json').readAsString())
          as Map<String, dynamic>;
      final lessons = manifest['lessons'] as List;
      expect(lessons, hasLength(1));
      final entry = lessons.first as Map<String, dynamic>;
      expect(entry['id'], 'test-lesson');
      expect(entry['file'], 'test-lesson.json');
      expect(entry['name'], '测试课时');
      expect(entry['sim'], 'circuit'); // entry 节点 sim
    });

    test('同 lessonId 保存 → manifest 覆盖不重复', () async {
      final saver = LessonSaver(lessonsDir: tmp.path);
      await saver.save(model());
      await saver.save(model(lessonId: 'test-lesson'));
      final manifest = jsonDecode(
              await File('${tmp.path}/manifest.json').readAsString())
          as Map<String, dynamic>;
      expect(manifest['lessons'] as List, hasLength(1));
    });

    test('不同 lessonId → manifest 追加', () async {
      final saver = LessonSaver(lessonsDir: tmp.path);
      await saver.save(model());
      await saver.save(model(lessonId: 'second'));
      final manifest = jsonDecode(
              await File('${tmp.path}/manifest.json').readAsString())
          as Map<String, dynamic>;
      expect(manifest['lessons'] as List, hasLength(2));
    });

    test('目录不存在 → 返回错误消息', () async {
      final saver = LessonSaver(lessonsDir: '${tmp.path}/nope');
      final err = await saver.save(model());
      expect(err, isNotNull);
      expect(err, contains('保存目录不存在'));
    });

    test('布局坐标写入 layout.json（含拖动后的位置）', () async {
      final saver = LessonSaver(lessonsDir: tmp.path);
      await saver.save(
        model().copyWith(layout: const {'n1': Offset(40, 20), 'n2': Offset(200, 300)}),
      );
      final layoutJson = jsonDecode(
              await File('${tmp.path}/test-lesson.layout.json').readAsString())
          as Map<String, dynamic>;
      final nodes = layoutJson['nodes'] as Map<String, dynamic>;
      expect(nodes['n1'], {'x': 40, 'y': 20});
      expect(nodes['n2'], {'x': 200, 'y': 300});
    });
  });
}
