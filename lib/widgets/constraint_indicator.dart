import 'package:flutter/material.dart';

import '../optics/config/constraint.dart';
import '../optics/models/optics_world.dart';

class ConstraintIndicator extends StatelessWidget {
  const ConstraintIndicator({
    super.key,
    required this.constraint,
    required this.world,
  });

  final Constraint constraint;
  final OpticsWorld world;

  @override
  Widget build(BuildContext context) {
    final valid = constraint.validate(world);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: valid ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: valid ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            valid
                ? Icons.check_circle_outline_rounded
                : Icons.error_outline_rounded,
            color: valid ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              constraint.description,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: valid ? const Color(0xFF166534) : const Color(0xFF991B1B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConstraintList extends StatelessWidget {
  const ConstraintList({
    super.key,
    required this.constraints,
    required this.world,
  });

  final List<Constraint> constraints;
  final OpticsWorld world;

  @override
  Widget build(BuildContext context) {
    if (constraints.isEmpty) {
      return const Center(
        child: Text(
          '暂无约束条件',
          style: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: constraints.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final constraint = constraints[index];
        return ConstraintIndicator(
          constraint: constraint,
          world: world,
        );
      },
    );
  }
}
