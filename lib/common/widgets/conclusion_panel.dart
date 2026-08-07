import 'package:flutter/material.dart';

/// 结论归纳面板：两阶段状态机。
///
/// 阶段① 输入：文本框 + 提交按钮（参考结论不可见 —— "结论先消失"）
/// 阶段② 对照：参考结论 + 学生结论并排展示（参考结论展开后不可收回）
///
/// [referenceConclusion] 为 null 时退化为仅自由输入（无对照功能）。
class ConclusionPanel extends StatefulWidget {
  const ConclusionPanel({
    super.key,
    required this.question,
    this.referenceConclusion,
    this.compact = false,
  });

  final String question;
  final String? referenceConclusion;
  final bool compact;

  @override
  State<ConclusionPanel> createState() => _ConclusionPanelState();
}

class _ConclusionPanelState extends State<ConclusionPanel> {
  final TextEditingController _ctrl = TextEditingController();
  bool _submitted = false;
  bool _editing = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text('请先写下你的发现，再提交结论', style: TextStyle(fontSize: 12)), duration: Duration(seconds: 2)),
        );
      return;
    }
    setState(() {
      _submitted = true;
      _editing = false;
    });
  }

  void _startEdit() => setState(() => _editing = true);

  void _cancelEdit() => setState(() => _editing = false);

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;
    final textSize = compact ? 11.0 : 13.0;
    final hasReference = widget.referenceConclusion != null;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: const Color(0xFFFEFCE8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFFDE68A)),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 8 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFFF59E0B)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('我的发现',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: textSize, fontWeight: FontWeight.w800, color: const Color(0xFF78350F))),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(widget.question, style: TextStyle(fontSize: textSize - 1, color: const Color(0xFF92400E), height: 1.4)),
            const SizedBox(height: 8),
            if (!_submitted || _editing)
              TextField(
                controller: _ctrl,
                maxLines: 3,
                minLines: 2,
                decoration: InputDecoration(
                  hintText: '通过刚才的实验数据，你发现了什么规律？',
                  hintStyle: TextStyle(fontSize: textSize - 1, color: const Color(0xFFD6A35C)),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFFDE68A)),
                  ),
                ),
                style: TextStyle(fontSize: textSize),
              ),
            if (!_submitted && hasReference)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('提示：先自己归纳，提交后即可对照参考结论。',
                    style: TextStyle(fontSize: textSize - 2, color: const Color(0xFFA16207), fontStyle: FontStyle.italic)),
              ),
            const SizedBox(height: 8),
            if (!_submitted)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: compact ? 4 : 8),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: Text('提交我的结论', style: TextStyle(fontSize: textSize)),
                ),
              )
            else if (_submitted) ...[
              // 学生结论展示
              _conclusionBlock(
                '你的结论',
                _ctrl.text,
                icon: Icons.person_outline,
                color: const Color(0xFFF59E0B),
                textSize: textSize,
              ),
              if (_editing) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: _cancelEdit, child: const Text('取消', style: TextStyle(fontSize: 11))),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text('更新', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ] else
                  Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _startEdit,
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: const Text('修改结论', style: TextStyle(fontSize: 11)),
                  ),
                ),
              // 参考结论对照（提交后展开 · 不可收回）
              if (hasReference) ...[
                const SizedBox(height: 6),
                _conclusionBlock(
                  '参考结论',
                  widget.referenceConclusion!,
                  icon: Icons.menu_book_outlined,
                  color: const Color(0xFF10B981),
                  textSize: textSize,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _conclusionBlock(String title, String text, {required IconData icon, required Color color, required double textSize}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(title, style: TextStyle(fontSize: textSize - 1, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          Text(text, style: TextStyle(fontSize: textSize - 1, color: const Color(0xFF334155), height: 1.4)),
        ],
      ),
    );
  }
}
