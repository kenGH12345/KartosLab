import 'package:flutter/material.dart';

import '../optics/config/learning_objective.dart';
import '../optics/models/optics_world.dart';
import '../optics/solvers/optics_solver.dart';

class ObjectivePanel extends StatefulWidget {
  const ObjectivePanel({
    super.key,
    required this.objectives,
    required this.world,
    this.solved,
  });

  final LearningObjective? objectives;
  final OpticsWorld world;
  final SolvedOptics? solved;

  @override
  State<ObjectivePanel> createState() => _ObjectivePanelState();
}

class _ObjectivePanelState extends State<ObjectivePanel> {
  final Set<int> _expandedHints = {};

  @override
  Widget build(BuildContext context) {
    final objectives = widget.objectives;

    if (objectives == null || objectives.successCriteria.isEmpty) {
      return const Center(
        child: Text(
          '暂无教学目标',
          style: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 14,
          ),
        ),
      );
    }

    final criteriaList = objectives.successCriteria;
    final total = criteriaList.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProgressBar(objectives.description, total),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: total,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final criterion = criteriaList[index];
              return _CriterionCard(
                criterion: criterion,
                index: index,
                expanded: _expandedHints.contains(index),
                onToggleHints: () {
                  setState(() {
                    if (_expandedHints.contains(index)) {
                      _expandedHints.remove(index);
                    } else {
                      _expandedHints.add(index);
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(String title, int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFF0FDF4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.isNotEmpty ? title : '学习目标',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF166534),
                ),
              ),
              Text(
                '$total 项',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF166534),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CriterionCard extends StatelessWidget {
  const _CriterionCard({
    required this.criterion,
    required this.index,
    required this.expanded,
    required this.onToggleHints,
  });

  final SuccessCriterion criterion;
  final int index;
  final bool expanded;
  final VoidCallback onToggleHints;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.radio_button_unchecked_rounded,
                  color: Color(0xFF9CA3AF),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TermRichText(
                        text: criterion.description,
                        baseStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 光学教学面板的术语表：把界面里出现的物理符号翻译成中文名词。
/// 遇到新学科（力学/电学）时再抽公共，遵循"最小化"原则。
const Map<String, String> _kOpticsGlossary = {
  '2f': '二倍焦距（= 2 × 焦距）',
  '2F': '二倍焦距（= 2 × 焦距）',
  'f': '焦距（focal length）',
  'F': '焦点 / 焦距',
  'u': '物距（object distance，物到透镜的距离）',
  'v': '像距（image distance，像到透镜的距离）',
};

/// 识别 [_kOpticsGlossary] 中的术语并渲染为带 Tooltip 的富文本。
/// 命中术语用虚线下划，长按或鼠标悬停显示中文解释。
class _TermRichText extends StatelessWidget {
  const _TermRichText({required this.text, required this.baseStyle});

  final String text;
  final TextStyle baseStyle;

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    // 按术语键从长到短排序，避免 "2f" 被 "f" 抢先匹配。
    final terms = _kOpticsGlossary.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    var i = 0;
    while (i < text.length) {
      String? hit;
      for (final t in terms) {
        if (i + t.length <= text.length && text.substring(i, i + t.length) == t) {
          // 边界保护：如果左右侧仍为同类符号字符，跳过（避免误伤单词内的字母）。
          final leftOk = i == 0 || !_isSymbolChar(text[i - 1]);
          final rightOk = i + t.length == text.length ||
              !_isSymbolChar(text[i + t.length]);
          if (leftOk && rightOk) {
            hit = t;
            break;
          }
        }
      }
      if (hit != null) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Tooltip(
              message: _kOpticsGlossary[hit]!,
              triggerMode: TooltipTriggerMode.tap,
              child: Text(
                hit,
                style: baseStyle.copyWith(
                  color: const Color(0xFF166534),
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dashed,
                  decorationColor: const Color(0x66166534),
                ),
              ),
            ),
          ),
        );
        i += hit.length;
      } else {
        spans.add(TextSpan(text: text[i], style: baseStyle));
        i += 1;
      }
    }
    return Text.rich(TextSpan(children: spans));
  }

  static bool _isSymbolChar(String c) {
    // 认为英文字母 / 数字与术语属于同一"词"，避免识别到单词内部的字母。
    return RegExp(r'[A-Za-z0-9]').hasMatch(c);
  }
}
