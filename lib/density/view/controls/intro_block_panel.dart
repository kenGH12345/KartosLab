import 'package:flutter/material.dart';

import '../../../common/controls/kratos_combo_box.dart';
import '../../../common/controls/kratos_slider.dart';
import '../../controller/density_controller.dart';
import '../../density_constants.dart';
import '../../density_strings.dart';
import '../../interaction/pointer_drag.dart';
import '../../model/density_block.dart';
import '../../model/density_material.dart';
import '../../solver/density_relation.dart';

class IntroBlockPanel extends StatelessWidget {
  const IntroBlockPanel({
    super.key,
    required this.controller,
    required this.block,
  });

  final DensityController controller;
  final DensityBlock block;

  @override
  Widget build(BuildContext context) {
    final materials = [
      ...DensityMaterials.simpleMassMaterials,
      DensityMaterials.custom,
    ];
    final mass = DensityRelation.massOf(block);
    final liters = DensityConstants.litersFromCubicMeters(block.volume);
    final density = DensityRelation.densityOf(block);
    final massRange = DensityRelationRanges.massRange(block);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${DensityStrings.mass} ${block.tag}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(width: 8),
        KratosComboBox<DensityMaterialId>(
          items: [for (final m in materials) m.id],
          itemLabels: [
            for (final m in materials) DensityStrings.materialName(m.stringKey),
          ],
          value: block.materialId,
          onChanged: (id) => controller.setIntroMaterial(block.id, id),
          width: 120,
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 160,
          child: KratosSlider(
            label: DensityStrings.mass,
            unit: DensityStrings.kg,
            min: massRange.min,
            max: massRange.max,
            value: mass.clamp(massRange.min, massRange.max).toDouble(),
            step: 0.1,
            onChanged: (v) => controller.setIntroMass(block.id, v),
            compact: true,
          ),
        ),
        SizedBox(
          width: 160,
          child: KratosSlider(
            label: DensityStrings.volume,
            unit: DensityStrings.liters,
            min: DensityConstants.minVolumeLiters,
            max: DensityConstants.maxVolumeLiters,
            value: liters,
            step: DensityConstants.volumeSliderSnapLiters,
            onChanged: (v) => controller.setIntroVolumeLiters(block.id, v),
            compact: true,
          ),
        ),
        Text(
          '${(density / 1000).toStringAsFixed(2)} ${DensityStrings.kgPerL}',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
