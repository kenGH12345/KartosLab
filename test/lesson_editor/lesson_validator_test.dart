import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/scenario/lesson_plan.dart';
import 'package:kratos/lesson_editor/models/editable_lesson_model.dart';
import 'package:kratos/lesson_editor/validation/lesson_validator.dart';

void main() {
  bool playable(String sim, String scenarioId) => true;

  EditableLessonModel validModel() {
    return EditableLessonModel(
      lessonId: 'test-lesson',
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

  group('LessonValidator.validate（T13）', () {
    test('合法模型 → 通过', () {
      final r = LessonValidator.validate(validModel(), scenarioPlayable: playable);
      expect(r.isValid, isTrue);
      expect(r.errors, isEmpty);
    });

    test('缺 entry → 报错', () {
      final m = validModel().copyWith(entry: null);
      final r = LessonValidator.validate(m, scenarioPlayable: playable);
      expect(r.isValid, isFalse);
      expect(r.errors.join(), contains('entry'));
    });

    test('占位场景（sim 空）→ 报错', () {
      final m = validModel().copyWith(
        nodes: const [
          EditableNode(
            id: 'n1',
            title: 'x',
            scenario: LessonScenarioRef(sim: '', scenarioId: ''),
            advance: LessonAdvance(type: 'onCompleted', to: 'n2'),
          ),
          EditableNode(id: 'n2', title: 'end'),
        ],
      );
      final r = LessonValidator.validate(m, scenarioPlayable: playable);
      expect(r.isValid, isFalse);
      expect(r.errors.join(), contains('n1'));
    });

    test('悬空 advance.to（9 条图校验）→ 报错', () {
      final m = validModel().copyWith(
        nodes: const [
          EditableNode(
            id: 'n1',
            title: 'x',
            scenario: LessonScenarioRef(sim: 'circuit', scenarioId: 'rgb'),
            advance: LessonAdvance(type: 'onCompleted', to: 'ghost'),
          ),
          EditableNode(id: 'n2', title: 'end'),
        ],
      );
      final r = LessonValidator.validate(m, scenarioPlayable: playable);
      expect(r.isValid, isFalse);
      expect(r.errors.join(), contains('ghost'));
    });

    test('终点节点带 advance（二元绑定）→ 报错', () {
      final m = validModel().copyWith(
        nodes: const [
          EditableNode(
            id: 'n1',
            title: 'x',
            scenario: LessonScenarioRef(sim: 'circuit', scenarioId: 'rgb'),
            advance: LessonAdvance(type: 'onCompleted', to: 'n2'),
          ),
          EditableNode(
            id: 'n2',
            title: 'end',
            advance: LessonAdvance(type: 'next'),
          ),
        ],
      );
      final r = LessonValidator.validate(m, scenarioPlayable: playable);
      expect(r.isValid, isFalse);
      expect(r.errors.join(), contains('n2'));
    });

    test('空剧本 → 报 entry 缺失（不走到图校验）', () {
      const m = EditableLessonModel();
      final r = LessonValidator.validate(m, scenarioPlayable: playable);
      expect(r.isValid, isFalse);
      expect(r.errors.join(), contains('entry'));
    });
  });
}
