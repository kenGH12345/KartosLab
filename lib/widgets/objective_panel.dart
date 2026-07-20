import 'package:flutter/material.dart';

import '../optics/config/learning_objective.dart';
import '../optics/config/lab_scenario.dart';
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
                      Text(
                        criterion.description,
                        style: const TextStyle(
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
