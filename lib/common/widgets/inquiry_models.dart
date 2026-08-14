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

  /// 预测题（做中学"猜测→验证"闭环）：操作前选答案，操作后对照判定。
  final List<InquiryPrediction> predictions;

  const InquiryTask({
    required this.question,
    this.steps = const [],
    this.referenceConclusion,
    this.snapshotColumns = const [],
    this.predictions = const [],
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
        predictions: (json['predictions'] as List<dynamic>? ?? const [])
            .map((e) => InquiryPrediction.fromJson(e as Map<String, dynamic>))
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
        if (predictions.isNotEmpty)
          'predictions':
              predictions.map((e) => e.toJson()).toList(growable: false),
      };
}

/// 预测题：选项式猜测，操作后对照正确答案判定对错。
@immutable
class InquiryPrediction {
  final String id;
  final String question;

  /// 选项（覆盖合理方向：增大/减小/不变等，避免歧义）。
  final List<String> options;

  /// 正确答案索引（0-based，对应 [options]）。
  final int answer;

  /// 验证后展示的答案解析。
  final String? explanation;

  const InquiryPrediction({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
    this.explanation,
  });

  factory InquiryPrediction.fromJson(Map<String, dynamic> json) =>
      InquiryPrediction(
        id: json['id'] as String,
        question: json['question'] as String,
        options: (json['options'] as List<dynamic>).cast<String>(),
        answer: json['answer'] as int,
        explanation: json['explanation'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options,
        'answer': answer,
        if (explanation != null) 'explanation': explanation,
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
