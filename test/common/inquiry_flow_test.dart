import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/common/widgets/inquiry_flow.dart';

/// 五阶段状态机推导规则测试（IXD Spec v1.0 §6 状态流转条件总表）。
void main() {
  group('InquiryFlowController · guided 模式状态推导', () {
    test('初始：猜测 Active，其余全部 Locked（§用例 1）', () {
      final c = InquiryFlowController(hasPredictions: true, totalPredictions: 2);
      expect(c.statusOf(InquiryStage.prediction), StageStatus.active);
      expect(c.statusOf(InquiryStage.task), StageStatus.locked);
      expect(c.statusOf(InquiryStage.operation), StageStatus.locked);
      expect(c.statusOf(InquiryStage.logging), StageStatus.locked);
      expect(c.statusOf(InquiryStage.conclusion), StageStatus.locked);
      expect(c.currentStage, InquiryStage.prediction);
    });

    test('全部预测验证通过 → 猜测 Completed · 任务 Active · 自动流转（§用例 2）', () {
      final c = InquiryFlowController(hasPredictions: true, totalPredictions: 2);
      c.setVerifiedCount(2);
      expect(c.statusOf(InquiryStage.prediction), StageStatus.completed);
      expect(c.statusOf(InquiryStage.task), StageStatus.active);
      expect(c.currentStage, InquiryStage.task);
    });

    test('部分验证 → 猜测保持 Active', () {
      final c = InquiryFlowController(hasPredictions: true, totalPredictions: 3);
      c.setVerifiedCount(2);
      expect(c.statusOf(InquiryStage.prediction), StageStatus.active);
      expect(c.statusOf(InquiryStage.task), StageStatus.locked);
    });

    test('无预测题 → 猜测跳过：Completed + 节点隐藏（PRED-005 · §5.5）', () {
      final c = InquiryFlowController(hasPredictions: false);
      expect(c.statusOf(InquiryStage.prediction), StageStatus.completed);
      expect(c.stageVisible(InquiryStage.prediction), isFalse);
      expect(c.statusOf(InquiryStage.task), StageStatus.active);
      expect(c.currentStage, InquiryStage.task);
      expect(c.progress, (0, 4));
    });

    test('任务确认 → 任务 Completed · 操作 Active（TASK-001）', () {
      final c = InquiryFlowController(hasPredictions: false);
      c.setTaskConfirmed(true);
      expect(c.statusOf(InquiryStage.task), StageStatus.completed);
      expect(c.statusOf(InquiryStage.operation), StageStatus.active);
      expect(c.statusOf(InquiryStage.logging), StageStatus.locked);
      expect(c.currentStage, InquiryStage.operation);
    });

    test('未确认任务 → 操作 Locked（防跳步）', () {
      final c = InquiryFlowController(hasPredictions: true, totalPredictions: 1);
      c.setVerifiedCount(1);
      // 猜测完成但任务未确认
      expect(c.statusOf(InquiryStage.operation), StageStatus.locked);
    });

    test('首次记录 ≥1 行 → 记录 Active · 归纳解锁（LOG-001）· 操作保持 Active（OPR-003）', () {
      final c = InquiryFlowController(hasPredictions: false);
      c.setTaskConfirmed(true);
      c.setLogRowCount(1);
      expect(c.statusOf(InquiryStage.operation), StageStatus.active);
      expect(c.statusOf(InquiryStage.logging), StageStatus.active);
      expect(c.statusOf(InquiryStage.conclusion), StageStatus.active);
      expect(c.currentStage, InquiryStage.logging);
    });

    test('删除全部记录 → 归纳重新 Locked · 记录保持 Active（LOG-003 · §用例 6）', () {
      final c = InquiryFlowController(hasPredictions: false);
      c.setTaskConfirmed(true);
      c.setLogRowCount(2);
      c.setLogRowCount(0);
      expect(c.statusOf(InquiryStage.logging), StageStatus.active,
          reason: '曾记录过不回锁');
      expect(c.statusOf(InquiryStage.conclusion), StageStatus.locked);
    });

    test('提交结论 → 归纳 Completed · 探究闭环完成（CON-006）', () {
      final c = InquiryFlowController(hasPredictions: false);
      c.setTaskConfirmed(true);
      c.setLogRowCount(1);
      c.setConclusionSubmitted(true);
      expect(c.statusOf(InquiryStage.conclusion), StageStatus.completed);
      expect(c.completed, isTrue);
      expect(c.currentStage, InquiryStage.conclusion);
      expect(c.progress, (4, 4));
    });

    test('修改结论（submitted=false）→ 归纳回到 Active（CON-004 修改态）', () {
      final c = InquiryFlowController(hasPredictions: false);
      c.setTaskConfirmed(true);
      c.setLogRowCount(1);
      c.setConclusionSubmitted(true);
      c.setConclusionSubmitted(false);
      expect(c.statusOf(InquiryStage.conclusion), StageStatus.active);
      expect(c.completed, isFalse);
    });

    test('完整流程推进：猜测→任务→操作→记录→归纳（§2.1 状态机）', () {
      final c = InquiryFlowController(hasPredictions: true, totalPredictions: 1);
      c.setVerifiedCount(1);
      c.setTaskConfirmed(true);
      c.setLogRowCount(1);
      c.setConclusionSubmitted(true);
      expect(
        InquiryStage.values.map(c.statusOf).toList(),
        everyElement(StageStatus.completed),
      );
      expect(c.progress, (5, 5));
    });
  });

  group('InquiryFlowController · free 模式（§7.3）', () {
    test('free 模式：全部阶段 Active · 无锁定（§用例 10）', () {
      final c = InquiryFlowController(
          hasPredictions: true, totalPredictions: 2, mode: InquiryMode.free);
      expect(
        InquiryStage.values.map(c.statusOf).toList(),
        everyElement(StageStatus.active),
      );
    });

    test('运行中切换 free → 立即全解锁', () {
      final c = InquiryFlowController(hasPredictions: true, totalPredictions: 2);
      c.setMode(InquiryMode.free);
      expect(c.statusOf(InquiryStage.conclusion), StageStatus.active);
    });
  });

  group('InquiryFlowController · 聚焦与重置', () {
    test('focusOn 覆盖当前焦点（点「去写结论」场景）', () {
      final c = InquiryFlowController(hasPredictions: false);
      c.setTaskConfirmed(true);
      c.setLogRowCount(1);
      expect(c.currentStage, InquiryStage.logging);
      c.focusOn(InquiryStage.conclusion);
      expect(c.currentStage, InquiryStage.conclusion);
    });

    test('聚焦锁定阶段后因状态回退失效（删光记录后聚焦归纳）', () {
      final c = InquiryFlowController(hasPredictions: false);
      c.setTaskConfirmed(true);
      c.setLogRowCount(1);
      c.focusOn(InquiryStage.conclusion);
      expect(c.currentStage, InquiryStage.conclusion);
      c.setLogRowCount(0); // 归纳重新锁定 → 覆盖失效
      expect(c.currentStage, InquiryStage.logging);
    });

    test('reset：全部状态清零（场景切换 §7.1-8）', () {
      final c = InquiryFlowController(hasPredictions: true, totalPredictions: 1);
      c.setVerifiedCount(1);
      c.setTaskConfirmed(true);
      c.setLogRowCount(1);
      c.setConclusionSubmitted(true);
      c.reset(hasPredictions: false);
      expect(c.hasPredictions, isFalse);
      expect(c.statusOf(InquiryStage.prediction), StageStatus.completed);
      expect(c.statusOf(InquiryStage.task), StageStatus.active);
      expect(c.taskConfirmed, isFalse);
      expect(c.logRowCount, 0);
      expect(c.conclusionSubmitted, isFalse);
      expect(c.completed, isFalse);
    });

    test('通知仅在状态实际变化时触发（避免多余重建）', () {
      final c = InquiryFlowController(hasPredictions: true, totalPredictions: 2);
      var notified = 0;
      c.addListener(() => notified++);
      c.setVerifiedCount(1);
      expect(notified, 1);
      c.setVerifiedCount(1); // 无变化
      expect(notified, 1);
    });
  });
}
