import 'package:flutter/material.dart';

import 'inquiry_models.dart';

/// 预测题面板：做中学"猜测→验证"闭环。
///
/// 学生操作前先选预测答案（猜测），操作实验后点「验证」对照正确答案。
/// 选择与验证状态保留在 State（InquiryDrawer 以 Offstage 保持 State）。
class PredictionPanel extends StatefulWidget {
  const PredictionPanel({super.key, required this.predictions});

  final List<InquiryPrediction> predictions;

  @override
  State<PredictionPanel> createState() => _PredictionPanelState();
}

class _PredictionPanelState extends State<PredictionPanel> {
  final Map<String, int> _selected = {};
  final Set<String> _verified = {};

  @override
  Widget build(BuildContext context) {
    if (widget.predictions.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF6EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8D9BF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.psychology_alt,
                size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text('先猜一猜', style: theme.textTheme.titleSmall),
          ]),
          const SizedBox(height: 4),
          Text(
            '操作前先预测答案，做完实验点「验证」对照结果。',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < widget.predictions.length; i++) ...[
            _PredictionTile(
              prediction: widget.predictions[i],
              index: i,
              selected: _selected[widget.predictions[i].id],
              verified: _verified.contains(widget.predictions[i].id),
              onSelect: (v) => setState(() {
                _selected[widget.predictions[i].id] = v;
              }),
              onVerify: () => setState(() {
                _verified.add(widget.predictions[i].id);
              }),
            ),
            if (i != widget.predictions.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _PredictionTile extends StatelessWidget {
  const _PredictionTile({
    required this.prediction,
    required this.index,
    required this.selected,
    required this.verified,
    required this.onSelect,
    required this.onVerify,
  });

  final InquiryPrediction prediction;
  final int index;
  final int? selected;
  final bool verified;
  final ValueChanged<int> onSelect;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3E0D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('第 ${index + 1} 题 · ${prediction.question}',
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (var i = 0; i < prediction.options.length; i++)
                ChoiceChip(
                  label: Text(prediction.options[i]),
                  selected: selected == i,
                  visualDensity: VisualDensity.compact,
                  onSelected: (v) {
                    if (v) onSelect(i);
                  },
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (!verified)
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: selected == null ? null : onVerify,
                icon: const Icon(Icons.fact_check_outlined, size: 16),
                label: const Text('验证我的猜测'),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  textStyle: theme.textTheme.labelMedium,
                ),
              ),
            )
          else
            _verifyResult(theme),
        ],
      ),
    );
  }

  Widget _verifyResult(ThemeData theme) {
    final isCorrect = selected == prediction.answer;
    final color = isCorrect
        ? const Color(0xFF1E7E46)
        : const Color(0xFFB3261E);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            isCorrect ? const Color(0xFFE8F5EE) : const Color(0xFFFBEAE9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(isCorrect ? Icons.check_circle : Icons.cancel,
                size: 18, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                isCorrect
                    ? '猜对了！'
                    : '猜错了。正确答案是「${prediction.options[prediction.answer]}」。',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
          if (prediction.explanation != null) ...[
            const SizedBox(height: 4),
            Text('原因：${prediction.explanation}',
                style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
