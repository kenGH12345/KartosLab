import 'package:flutter/foundation.dart';

/// 探究任务数据模型（对应 scenario JSON `inquiryTask` 顶层字段）。
///
/// 由各 sim 的 scenario model 在 fromJson 时解析并持有。
/// 三组件（InquiryTaskPanel / ExperimentLogger / ConclusionPanel）
/// 共享本模型，避免循环依赖。
@immutable
class InquiryTask {
  final String question;
  final List<InquiryStep> steps;
  final String? referenceConclusion;
  final List<InquirySnapshotColumn> snapshotColumns;

  const InquiryTask({
    required this.question,
    this.steps = const [],
    this.referenceConclusion,
    this.snapshotColumns = const [],
  });

  factory InquiryTask.fromJson(Map<String, dynamic> json) => InquiryTask(
        question: json['question'] as String,
        steps: (json['steps'] as List<dynamic>? ?? const [])
            .map((e) => InquiryStep.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
        referenceConclusion: json['referenceConclusion'] as String?,
        snapshotColumns:
            (json['snapshotColumns'] as List<dynamic>? ?? const [])
                .map((e) => InquirySnapshotColumn.fromJson(e as Map<String, dynamic>))
                .toList(growable: false),
      );

  Map<String, dynamic> toJson() => {
        'question': question,
        if (steps.isNotEmpty)
          'steps': steps.map((e) => e.toJson()).toList(growable: false),
        if (referenceConclusion != null)
          'referenceConclusion': referenceConclusion,
        if (snapshotColumns.isNotEmpty)
          'snapshotColumns':
              snapshotColumns.map((e) => e.toJson()).toList(growable: false),
      };
}

/// 探究分步指引。
@immutable
class InquiryStep {
  final String id;
  final String instruction;
  final String? hint;

  const InquiryStep({required this.id, required this.instruction, this.hint});

  factory InquiryStep.fromJson(Map<String, dynamic> json) => InquiryStep(
        id: json['id'] as String,
        instruction: json['instruction'] as String,
        hint: json['hint'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'instruction': instruction,
        if (hint != null) 'hint': hint,
      };
}

/// 实验记录表列定义。
///
/// [source] 区分参数（'param'）与读数（'reading'）两类，用于表头视觉区分。
@immutable
class InquirySnapshotColumn {
  final String key;
  final String label;
  final String source;

  const InquirySnapshotColumn({
    required this.key,
    required this.label,
    this.source = 'reading',
  });

  factory InquirySnapshotColumn.fromJson(Map<String, dynamic> json) =>
      InquirySnapshotColumn(
        key: json['key'] as String,
        label: json['label'] as String,
        source: json['source'] as String? ?? 'reading',
      );

  Map<String, dynamic> toJson() => {'key': key, 'label': label, 'source': source};
}
