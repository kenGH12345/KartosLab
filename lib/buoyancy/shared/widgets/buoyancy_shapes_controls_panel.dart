import 'package:flutter/material.dart';

import '../../domain/material/buoyancy_material.dart';
import '../../domain/shape/shape_geometry.dart';
import '../../rendering/runtime/buoyancy_play_area.dart';
import '../../shapes/model/buoyancy_shapes_model.dart';

/// Source: `MaterialControlNode` + `ShapeSizeControlNode` (A/B).
class BuoyancyShapesControlsPanel extends StatelessWidget {
  const BuoyancyShapesControlsPanel({
    super.key,
    required this.model,
    required this.onMaterial,
    required this.onShape,
    required this.onRatios,
  });

  final BuoyancyShapesModel model;
  final ValueChanged<BuoyancyMaterial> onMaterial;
  final void Function(String which, MassShapeKind shape) onShape;
  final void Function(String which, double width, double height) onRatios;

  String _matLabel(BuoyancyMaterial m) =>
      m.id[0].toUpperCase() + m.id.substring(1);

  @override
  Widget build(BuildContext context) {
    final mats = BuoyancyShapesModel.availableMaterials;
    final selected = mats.firstWhere(
      (m) => m.id == model.material.id,
      orElse: () => mats.first,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        BuoyancyPanel(
          child: SizedBox(
            width: 210,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Material',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                DropdownButton<BuoyancyMaterial>(
                  isExpanded: true,
                  isDense: true,
                  value: selected,
                  items: [
                    for (final m in mats)
                      DropdownMenuItem(value: m, child: Text(_matLabel(m))),
                  ],
                  onChanged: (v) {
                    if (v != null) onMaterial(v);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        _ShapeSizePanel(
          tag: 'A',
          tagColor: const Color(0xFF2F59A6),
          slot: model.objectA,
          onShape: (s) => onShape('A', s),
          onRatios: (w, h) => onRatios('A', w, h),
        ),
        if (model.objectB.mass.visible) ...[
          const SizedBox(height: 5),
          _ShapeSizePanel(
            tag: 'B',
            tagColor: const Color(0xFFED3732),
            slot: model.objectB,
            onShape: (s) => onShape('B', s),
            onRatios: (w, h) => onRatios('B', w, h),
          ),
        ],
      ],
    );
  }
}

class _ShapeSizePanel extends StatelessWidget {
  const _ShapeSizePanel({
    required this.tag,
    required this.tagColor,
    required this.slot,
    required this.onShape,
    required this.onRatios,
  });

  final String tag;
  final Color tagColor;
  final ShapesObjectSlot slot;
  final ValueChanged<MassShapeKind> onShape;
  final void Function(double width, double height) onRatios;

  @override
  Widget build(BuildContext context) {
    return BuoyancyPanel(
      child: SizedBox(
        width: 210,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tagColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(tag,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Text('Shape',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: tagColor)),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final s in kShapesCatalog)
                  ChoiceChip(
                    label: Text(s.name, style: const TextStyle(fontSize: 10)),
                    selected: slot.shape == s,
                    visualDensity: VisualDensity.compact,
                    onSelected: (_) => onShape(s),
                  ),
              ],
            ),
            Text('Width ${(slot.widthRatio * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 11)),
            Slider(
              value: slot.widthRatio,
              activeColor: tagColor,
              onChanged: (w) => onRatios(w, slot.heightRatio),
            ),
            Text('Height ${(slot.heightRatio * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 11)),
            Slider(
              value: slot.heightRatio,
              activeColor: tagColor,
              onChanged: (h) => onRatios(slot.widthRatio, h),
            ),
          ],
        ),
      ),
    );
  }
}
