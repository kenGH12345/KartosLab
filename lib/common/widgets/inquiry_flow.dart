import 'package:flutter/material.dart';

/// 做中学五阶段（IXD Spec v1.0 §2.1 状态机）。
enum InquiryStage {
  prediction('先猜一猜', Icons.psychology),
  task('探究任务', Icons.assignment),
  operation('动手实验', Icons.touch_app),
  logging('实验记录', Icons.table_chart),
  conclusion('我的发现', Icons.lightbulb);

  const InquiryStage(this.title, this.icon);

  /// 阶段标题（卡片 Header 与提示文案用）。
  final String title;
  final IconData icon;
}

/// 阶段生命周期状态（IXD Spec v1.0 §2.2）。
enum StageStatus {
  /// 灰色折叠 · 点击抖动提示"请先完成上一阶段"。
  locked,

  /// 蓝色高亮展开 · 当前聚焦区域，完全可操作。
  active,

  /// 绿色折叠 · 点击展开只读回顾。
  completed,
}

/// 探究模式（IXD Spec v1.0 §7.3）。
///
/// [guided] 强引导（默认）：一次一阶段，渐进解锁。
/// [free] 自由模式：全部阶段 Active，进度条仅指示不导航。
enum InquiryMode { guided, free }

/// 五阶段状态机控制器（IXD Spec v1.0 §9.3 · Drawer 级 ChangeNotifier）。
///
/// 状态推导规则（§6 状态流转条件总表）：
/// - 猜测：全部预测题验证通过 → completed（无预测题时跳过，节点隐藏 §5.5）
/// - 任务：猜测完成后解锁；手动点「开始实验」→ completed
/// - 操作：任务确认后解锁；保持 Active 不自动折叠（OPR-003）
/// - 记录：首次记录 ≥1 行后解锁；删除全部后归纳重新锁定但记录保持 Active（LOG-003）
/// - 归纳：记录 ≥1 行后解锁；提交 → completed，探究闭环完成
class InquiryFlowController extends ChangeNotifier {
  InquiryFlowController({
    bool hasPredictions = false,
    int totalPredictions = 0,
    InquiryMode mode = InquiryMode.guided,
  })  : _hasPredictions = hasPredictions,
        _totalPredictions = totalPredictions,
        _mode = mode;

  bool _hasPredictions;
  int _totalPredictions;
  InquiryMode _mode;

  int _verifiedCount = 0;
  bool _taskConfirmed = false;

  /// 曾记录过 ≥1 行（删除全部后不回退——记录卡保持 Active，LOG-003）。
  bool _loggingActivated = false;
  int _logRowCount = 0;
  bool _conclusionSubmitted = false;

  /// 用户主动聚焦的阶段（如点击「去写结论」）。
  ///
  /// 优先级高于自动推导——一旦用户主动选定，焦点不再被新解锁阶段抢走；
  /// 仅当所指阶段回退为 locked 时失效（见 [_dropStaleOverride]）。
  InquiryStage? _focusOverride;

  // ---------- 派生状态 ----------

  bool get hasPredictions => _hasPredictions;

  /// 猜测阶段完成：无预测题（跳过）或全部验证通过（PRED-005）。
  bool get predictionDone =>
      !_hasPredictions || _verifiedCount >= _totalPredictions;

  bool get taskConfirmed => _taskConfirmed;

  /// 记录卡是否已解锁（首次记录 ≥1 行）。
  bool get loggingActivated => _loggingActivated;

  int get logRowCount => _logRowCount;

  bool get conclusionSubmitted => _conclusionSubmitted;

  /// 探究闭环完成（CON-006）。
  bool get completed => _conclusionSubmitted;

  InquiryMode get mode => _mode;

  /// 阶段状态推导（每次读取即时计算，无需缓存失效管理）。
  StageStatus statusOf(InquiryStage stage) {
    if (_mode == InquiryMode.free) return StageStatus.active;
    switch (stage) {
      case InquiryStage.prediction:
        return predictionDone ? StageStatus.completed : StageStatus.active;
      case InquiryStage.task:
        if (!predictionDone) return StageStatus.locked;
        return _taskConfirmed ? StageStatus.completed : StageStatus.active;
      case InquiryStage.operation:
        if (!_taskConfirmed) return StageStatus.locked;
        return _conclusionSubmitted ? StageStatus.completed : StageStatus.active;
      case InquiryStage.logging:
        if (!_loggingActivated) return StageStatus.locked;
        return _conclusionSubmitted ? StageStatus.completed : StageStatus.active;
      case InquiryStage.conclusion:
        if (!_loggingActivated || _logRowCount < 1) return StageStatus.locked;
        return _conclusionSubmitted ? StageStatus.completed : StageStatus.active;
    }
  }

  /// 当前焦点阶段：进度条指示 + 自动滚动定位（§5.1「当前：X」）。
  ///
  /// 默认取"最新解锁阶段"；[focusOn] 可临时覆盖（如点「去写结论」）。
  InquiryStage get currentStage {
    if (_focusOverride != null) return _focusOverride!;
    if (_conclusionSubmitted) return InquiryStage.conclusion;
    if (_loggingActivated) return InquiryStage.logging;
    if (_taskConfirmed) return InquiryStage.operation;
    if (predictionDone) return InquiryStage.task;
    return InquiryStage.prediction;
  }

  /// 进度条节点是否可见：无预测题时隐藏猜测节点（§5.5 动态节点数）。
  bool stageVisible(InquiryStage stage) =>
      stage != InquiryStage.prediction || _hasPredictions;

  /// 已完成节点数（进度条「X/N 已完成」）。
  (int, int) get progress {
    final stages = InquiryStage.values.where(stageVisible);
    final done =
        stages.where((s) => statusOf(s) == StageStatus.completed).length;
    return (done, stages.length);
  }

  // ---------- 事件（由各阶段组件回调） ----------

  /// 预测题已验证数变化（PredictionPanel.onVerifiedChanged）。
  void setVerifiedCount(int count) {
    if (_verifiedCount == count) return;
    _verifiedCount = count;
    notifyListeners();
  }

  /// 任务确认（点击「我已了解任务，开始实验」· TASK-001）。
  void setTaskConfirmed(bool value) {
    if (_taskConfirmed == value) return;
    _taskConfirmed = value;
    notifyListeners();
  }

  /// 记录行数变化（ExperimentLogger.onRowsChanged）。
  void setLogRowCount(int count) {
    final wasActivated = _loggingActivated;
    if (count >= 1) _loggingActivated = true;
    if (_logRowCount == count && wasActivated == _loggingActivated) return;
    _logRowCount = count;
    _dropStaleOverride();
    notifyListeners();
  }

  /// 结论提交状态变化（ConclusionPanel.onSubmittedChanged）。
  void setConclusionSubmitted(bool value) {
    if (_conclusionSubmitted == value) return;
    _conclusionSubmitted = value;
    _dropStaleOverride();
    notifyListeners();
  }

  /// 用户主动聚焦某阶段（进度条节点点击 / 「去写结论」按钮）。
  void focusOn(InquiryStage stage) {
    _focusOverride = stage;
    notifyListeners();
  }

  /// 模式切换（§7.3 教师端自由模式）。
  void setMode(InquiryMode value) {
    if (_mode == value) return;
    _mode = value;
    notifyListeners();
  }

  /// 场景切换：全部探究状态重置（§7.1-8）。
  void reset({
    required bool hasPredictions,
    int totalPredictions = 0,
  }) {
    _hasPredictions = hasPredictions;
    _totalPredictions = totalPredictions;
    _verifiedCount = 0;
    _taskConfirmed = false;
    _loggingActivated = false;
    _logRowCount = 0;
    _conclusionSubmitted = false;
    _focusOverride = null;
    notifyListeners();
  }

  /// 聚焦覆盖失效规则：指向的阶段已 locked（如删光记录后归纳重新锁定）。
  void _dropStaleOverride() {
    final focus = _focusOverride;
    if (focus == null) return;
    if (statusOf(focus) == StageStatus.locked) _focusOverride = null;
  }
}
