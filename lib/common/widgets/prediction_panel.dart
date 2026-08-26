import 'dart:async';

import 'package:flutter/material.dart';

import 'inquiry_models.dart';

/// 预测题面板：做中学"猜测→验证"闭环（IXD Spec v1.0 §4.1）。
///
/// 两种模式：
/// - 推进模式（默认）：一次只显示一题；验证后显示判定 1.5s 自动下一题
///   （PRED-002）；全部验证后触发 [onAllVerified]（PRED-004 阶段流转）。
/// - 回顾模式（[review] = true）：Completed 阶段展开时只读展示全部题目与判定。
///
/// 选择与验证状态保留在 State（InquiryDrawer 以 Offstage 保持 State）。
class PredictionPanel extends StatefulWidget {
  const PredictionPanel({
    super.key,
    required this.predictions,
    this.onVerifiedChanged,
    this.onResultChanged,
    this.onAllVerified,
    this.review = false,
  });

  final List<InquiryPrediction> predictions;

  /// 已验证题数变化回调（进度联动 · null 时兼容旧调用方）。
  final ValueChanged<int>? onVerifiedChanged;

  /// 已验证数 + 答对数变化回调（Completed 摘要「答对 X/N」用）。
  final void Function(int verified, int correct)? onResultChanged;

  /// 全部题目验证完成回调（阶段流转触发 · §9.2 PredictionPanel 改造点）。
  final VoidCallback? onAllVerified;

  /// 回顾模式：Completed 阶段只读展示全部题目与判定结果。
  final bool review;

  @override
  State<PredictionPanel> createState() => _PredictionPanelState();
}

class _PredictionPanelState extends State<PredictionPanel> {
  final Map<String, int> _selected = {};
  final Set<String> _verified = {};
  int _current = 0;

  /// 验证后的判定展示计时器（1.5s 后推进下一题 · PRED-002）。
  Timer? _advanceTimer;

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  /// 已验证题中答对的数量。
  int get _correct => widget.predictions
      .where((p) => _verified.contains(p.id) && _selected[p.id] == p.answer)
      .length;

  void _notify() {
    widget.onVerifiedChanged?.call(_verified.length);
    widget.onResultChanged?.call(_verified.length, _correct);
  }

  void _verify() {
    final p = widget.predictions[_current];
    final isLast = _verified.length + 1 == widget.predictions.length;
    setState(() => _verified.add(p.id));
    // PRED-002：判定结果展示 1.5s 后再推进（通知进度/下一题/阶段流转），
    // 避免验证瞬间卡片折叠吞掉反馈。
    _advanceTimer?.cancel();
    _advanceTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _notify();
      if (isLast) {
        // PRED-004：全部验证完成 → 触发阶段流转（上层折叠卡片）
        widget.onAllVerified?.call();
      } else {
        setState(() => _current++);
      }
    });
  }

  void _select(int option) {
    final p = widget.predictions[_current];
    setState(() => _selected[p.id] = option);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.predictions.isEmpty) return const SizedBox.shrink();
    if (widget.review) return _buildReview(context);
    return _buildActive(context);
  }

  // ---------- 推进模式（Active 阶段） ----------

  Widget _buildActive(BuildContext context) {
    final theme = Theme.of(context);
    final p = widget.predictions[_current];
    final verified = _verified.contains(p.id);
    final selected = _selected[p.id];
    final total = widget.predictions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.psychology_alt,
                size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text('第 ${_current + 1}/$total 题',
                style: theme.textTheme.labelMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _verified.isEmpty
                    ? '先猜一猜，做完实验点「验证」'
                    : '已验证 ${_verified.length}/$total',
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey.shade500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(p.question, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (var i = 0; i < p.options.length; i++)
              ChoiceChip(
                label: Text(p.options[i]),
                selected: selected == i,
                visualDensity: VisualDensity.compact,
                onSelected: verified
                    ? null // 判定展示期间锁定选项（防误触改答案）
                    : (v) {
                        if (v) _select(i);
                      },
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (!verified)
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(
              // PRED-001：未选选项时验证按钮禁用
              onPressed: selected == null ? null : _verify,
              icon: const Icon(Icons.fact_check_outlined, size: 16),
              label: const Text('验证我的猜测'),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                textStyle: theme.textTheme.labelMedium,
              ),
            ),
          )
        else
          _verifyResult(theme, p, selected),
      ],
    );
  }

  Widget _verifyResult(ThemeData theme, InquiryPrediction p, int? selected) {
    final isCorrect = selected == p.answer;
    final color =
        isCorrect ? const Color(0xFF1E7E46) : const Color(0xFFB3261E);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFE8F5EE) : const Color(0xFFFBEAE9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(isCorrect ? Icons.check_circle : Icons.cancel,
                size: 16, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                isCorrect
                    ? '猜对了！'
                    : '猜错了。正确答案是「${p.options[p.answer]}」。',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: color, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
          if (p.explanation != null) ...[
            const SizedBox(height: 4),
            Text('原因：${p.explanation}',
                style: theme.textTheme.bodySmall),
          ],
          if (_current < widget.predictions.length - 1) ...[
            const SizedBox(height: 2),
            Text('即将进入下一题…',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey.shade500, fontSize: 10)),
          ],
        ],
      ),
    );
  }

  // ---------- 回顾模式（Completed 阶段只读） ----------

  Widget _buildReview(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < widget.predictions.length; i++)
          _ReviewTile(
            prediction: widget.predictions[i],
            index: i,
            selected: _selected[widget.predictions[i].id],
          ),
        if (_verified.length < widget.predictions.length)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('（${widget.predictions.length - _verified.length} 题未验证）',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey.shade500)),
          ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.prediction,
    required this.index,
    required this.selected,
  });

  final InquiryPrediction prediction;
  final int index;
  final int? selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verified = selected != null;
    final isCorrect = selected == prediction.answer;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                !verified
                    ? Icons.help_outline
                    : isCorrect
                        ? Icons.check_circle
                        : Icons.cancel,
                size: 14,
                color: !verified
                    ? Colors.grey.shade400
                    : isCorrect
                        ? const Color(0xFF1E7E46)
                        : const Color(0xFFB3261E),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '第 ${index + 1} 题 · ${prediction.question}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          if (selected != null) ...[
            const SizedBox(height: 2),
            Text(
              isCorrect
                  ? '你的答案「${prediction.options[selected!]}」· 正确'
                  : '你的答案「${prediction.options[selected!]}」· 正确答案是「${prediction.options[prediction.answer]}」',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isCorrect ? const Color(0xFF1E7E46) : const Color(0xFFB3261E),
              ),
            ),
          ],
          if (prediction.explanation != null && verified) ...[
            const SizedBox(height: 2),
            Text('原因：${prediction.explanation}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey.shade600, fontSize: 10)),
          ],
        ],
      ),
    );
  }
}
