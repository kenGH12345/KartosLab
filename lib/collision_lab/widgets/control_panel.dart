import 'package:flutter/material.dart';

import '../collision_lab_colors.dart';
import '../collision_lab_strings.dart';
import '../controller/collision_lab_controller.dart';
import '../model/inelastic_preset.dart';
import '../model/play_area.dart';

/// Control availability flags per PhET screen.
class ControlPanelConfig {
  const ControlPanelConfig({
    this.showReflecting = true,
    this.showPaths = false,
    this.showElasticity = true,
    this.showChangeInMomentum = false,
    this.showBallsPicker = false,
    this.showGridCheckbox = false,
    this.showStickSlip = false,
    this.showPresets = false,
  });

  final bool showReflecting;
  final bool showPaths;
  final bool showElasticity;
  final bool showChangeInMomentum;
  final bool showBallsPicker;
  final bool showGridCheckbox;
  final bool showStickSlip;
  final bool showPresets;

  static const intro = ControlPanelConfig(
    showReflecting: false,
    showPaths: false,
    showElasticity: true,
    showChangeInMomentum: true,
    showBallsPicker: false,
    showGridCheckbox: false,
  );

  static const explore1d = ControlPanelConfig(
    showReflecting: true,
    showPaths: false,
    showElasticity: true,
    showBallsPicker: true,
    showGridCheckbox: false,
  );

  static const explore2d = ControlPanelConfig(
    showReflecting: true,
    showPaths: true,
    showElasticity: true,
    showBallsPicker: true,
    showGridCheckbox: true,
  );

  static const inelastic = ControlPanelConfig(
    showReflecting: true,
    showPaths: true,
    showElasticity: false,
    showStickSlip: true,
    showPresets: true,
    showGridCheckbox: true,
  );
}

class ControlPanel extends StatelessWidget {
  const ControlPanel({
    super.key,
    required this.controller,
    required this.config,
  });

  final CollisionLabController controller;
  final ControlPanelConfig config;

  @override
  Widget build(BuildContext context) {
    final model = controller.model;
    final view = controller.view;
    final bs = model.ballSystem;
    final pa = model.playArea;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: CollisionLabColors.panelFill,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: CollisionLabColors.panelStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (config.showBallsPicker || config.showGridCheckbox)
            _TopRightExtras(
              controller: controller,
              config: config,
            ),
          if (config.showPresets) ...[
            const Text('Preset', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            DropdownButton<InelasticPreset>(
              isExpanded: true,
              value: bs.inelasticPreset,
              items: [
                for (final p in InelasticPreset.values)
                  DropdownMenuItem(value: p, child: Text(_presetLabel(p))),
              ],
              onChanged: (p) {
                if (p != null) controller.setPreset(p);
              },
            ),
            const SizedBox(height: 6),
          ],
          _check(CollisionLabStrings.velocity, view.velocityVectorVisible,
              controller.setVelocityVectors),
          _check(CollisionLabStrings.momentum, view.momentumVectorVisible,
              controller.setMomentumVectors),
          _check(CollisionLabStrings.centerOfMass, bs.centerOfMassVisible,
              controller.setCenterOfMass),
          if (config.showChangeInMomentum)
            _check(
              CollisionLabStrings.changeInMomentum,
              bs.changeInMomentumVisible,
              controller.setChangeInMomentum,
            ),
          _check(CollisionLabStrings.kineticEnergy, view.kineticEnergyVisible,
              controller.setKineticEnergy),
          _check(CollisionLabStrings.values, view.valuesVisible,
              controller.setValues),
          if (config.showReflecting)
            _check(CollisionLabStrings.reflectingBorder, pa.reflectingBorder,
                controller.setReflectingBorder),
          if (config.showPaths)
            _check(CollisionLabStrings.paths, bs.pathsVisible,
                controller.setPathsVisible),
          const Divider(height: 16),
          if (config.showElasticity) ...[
            Text(
              '${CollisionLabStrings.elasticity}: ${pa.elasticityPercent.toInt()}%',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Slider(
              value: pa.elasticityPercent,
              min: pa.elasticityEnabledMin,
              max: 100,
              divisions: ((100 - pa.elasticityEnabledMin) / 5).round(),
              onChanged: controller.setElasticity,
            ),
          ],
          if (config.showStickSlip) ...[
            Text(
              '${CollisionLabStrings.elasticity} = 0%',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text(CollisionLabStrings.stick),
                    selected:
                        pa.inelasticCollisionType == InelasticCollisionType.stick,
                    onSelected: (_) =>
                        controller.setStickSlip(InelasticCollisionType.stick),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ChoiceChip(
                    label: const Text(CollisionLabStrings.slip),
                    selected:
                        pa.inelasticCollisionType == InelasticCollisionType.slip,
                    onSelected: (_) =>
                        controller.setStickSlip(InelasticCollisionType.slip),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          _check(CollisionLabStrings.constantSize, bs.ballsConstantSize,
              controller.setConstantSize),
          const SizedBox(height: 8),
          _check(CollisionLabStrings.moreData, view.moreDataVisible,
              controller.setMoreData),
        ],
      ),
    );
  }

  Widget _check(String label, bool value, ValueChanged<bool> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          ],
        ),
      ),
    );
  }

  String _presetLabel(InelasticPreset p) {
    switch (p) {
      case InelasticPreset.custom:
        return 'Custom';
      case InelasticPreset.crissCross:
        return 'Criss Cross';
      case InelasticPreset.headOn:
        return 'Head On';
      case InelasticPreset.glancing:
        return 'Glancing';
    }
  }
}

class _TopRightExtras extends StatelessWidget {
  const _TopRightExtras({required this.controller, required this.config});
  final CollisionLabController controller;
  final ControlPanelConfig config;

  @override
  Widget build(BuildContext context) {
    final bs = controller.model.ballSystem;
    final pa = controller.model.playArea;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (config.showBallsPicker)
          Row(
            children: [
              const Text(CollisionLabStrings.balls,
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: bs.numberOfBalls > bs.minBalls
                    ? () => controller.setNumberOfBalls(bs.numberOfBalls - 1)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Text('${bs.numberOfBalls}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: bs.numberOfBalls < bs.maxBalls
                    ? () => controller.setNumberOfBalls(bs.numberOfBalls + 1)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        if (config.showGridCheckbox)
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const Text(CollisionLabStrings.grid, style: TextStyle(fontSize: 13)),
            value: pa.gridVisible,
            onChanged: (v) => controller.setGridVisible(v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        const Divider(height: 12),
      ],
    );
  }
}
