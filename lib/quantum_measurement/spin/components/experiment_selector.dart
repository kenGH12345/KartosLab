/// Experiment 1–6 + Custom selector (ComboBox-style list, not Material Dropdown).
library;

import 'package:flutter/material.dart';

import '../model/spin_model.dart';

class ExperimentSelector extends StatelessWidget {
  const ExperimentSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final SpinExperiment value;
  final ValueChanged<SpinExperiment> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: () => _openMenu(context),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          constraints: const BoxConstraints(minWidth: 220),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black54),
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value.label, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_drop_down, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openMenu(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null) return;
    final pos = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final selected = await showMenu<SpinExperiment>(
      context: context,
      position: pos,
      items: [
        for (final e in SpinExperiment.values)
          PopupMenuItem(value: e, child: Text(e.label)),
      ],
    );
    if (selected != null) onChanged(selected);
  }
}
