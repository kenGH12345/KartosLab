import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/controller/esp_controller.dart';
import 'package:kratos/energy_skate_park/controller/graphs_controller.dart';
import 'package:kratos/energy_skate_park/esp_colors.dart';
import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/esp_strings.dart';
import 'package:kratos/energy_skate_park/model/track_set_model.dart';
import 'package:kratos/energy_skate_park/render/esp_mvt.dart';
import 'package:kratos/energy_skate_park/widgets/esp_checkbox_icons.dart';
import 'package:kratos/energy_skate_park/widgets/gravity_controls.dart';
import 'package:kratos/energy_skate_park/widgets/skater_selection.dart';
import 'package:kratos/energy_skate_park/widgets/toolbox_panel.dart';
import 'package:kratos/energy_skate_park/widgets/track_scene_selector.dart';

class ControlPanelConfig {
  const ControlPanelConfig({
    this.showSceneSelector = true,
    this.showGravityCombo = false,
    this.showBarCheckbox = true,
    this.showPieCheckbox = true,
    this.showPathCheckbox = false,
    this.showStickCheckbox = true,
    this.showBottomVisibility = true,
    this.showToolbox = false,
    this.showEnergyGraphToggle = false,
    this.scenes = const [
      TrackScene.parabola,
      TrackScene.ramp,
      TrackScene.doubleWell,
      TrackScene.loop,
    ],
    this.onScene,
    this.onPathVisible,
    this.pathVisible = false,
    this.playgroundActions = false,
    this.onAddTrack,
    this.onClearTracks,
    this.onSplitControlPoint,
    this.onDeleteControlPoint,
    this.canSplit = false,
    this.canDeleteCp = false,
  });

  final bool showSceneSelector;
  final bool showGravityCombo;
  final bool showBarCheckbox;
  final bool showPieCheckbox;
  final bool showPathCheckbox;
  final bool showStickCheckbox;
  final bool showBottomVisibility;
  final bool showToolbox;
  final bool showEnergyGraphToggle;
  final List<TrackScene> scenes;
  final ValueChanged<TrackScene>? onScene;
  final ValueChanged<bool>? onPathVisible;
  final bool pathVisible;
  final bool playgroundActions;
  final VoidCallback? onAddTrack;
  final VoidCallback? onClearTracks;
  final VoidCallback? onSplitControlPoint;
  final VoidCallback? onDeleteControlPoint;
  final bool canSplit;
  final bool canDeleteCp;

  static const ControlPanelConfig intro = ControlPanelConfig(
    showToolbox: true,
  );
  static const ControlPanelConfig measure = ControlPanelConfig(
    showBarCheckbox: false,
    showGravityCombo: true,
    showPathCheckbox: true,
    showToolbox: true,
  );
  static const ControlPanelConfig graphs = ControlPanelConfig(
    showBarCheckbox: false,
    showGravityCombo: true,
    showToolbox: true,
    showEnergyGraphToggle: true,
    scenes: [TrackScene.parabola, TrackScene.doubleWell],
  );
  static const ControlPanelConfig playground = ControlPanelConfig(
    showSceneSelector: false,
    showGravityCombo: true,
    playgroundActions: true,
  );
}

class ControlPanel extends StatelessWidget {
  const ControlPanel({
    super.key,
    required this.controller,
    required this.config,
    this.playAreaSize,
  });

  final EspController controller;
  final ControlPanelConfig config;
  final Size? playAreaSize;

  @override
  Widget build(BuildContext context) {
    final model = controller.model;
    final view = controller.view;
    final playSize = playAreaSize ?? const Size(600, 400);
    final mvt = EspMvt.forPlayArea(playSize);

    return Material(
      color: EspColors.panelFill,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: EspColors.panelStroke),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (config.showPieCheckbox)
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: _checkboxTitle(EspStrings.pieChart, EspCheckboxIcons.pieChart()),
                value: view.pieChartVisible,
                onChanged: (v) => controller.setPieChartVisible(v ?? false),
              ),
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: _checkboxTitle(EspStrings.speed, EspCheckboxIcons.speedometer()),
              value: view.speedVisible,
              onChanged: (v) => controller.setSpeedVisible(v ?? false),
            ),
            if (config.showPathCheckbox && config.onPathVisible != null)
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: _checkboxTitle(EspStrings.path, EspCheckboxIcons.path()),
                value: config.pathVisible,
                onChanged: (v) => config.onPathVisible!(v ?? false),
              ),
            if (config.showStickCheckbox)
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: _checkboxTitle(
                  EspStrings.stickToTrack,
                  EspCheckboxIcons.stickToTrack(),
                ),
                value: model.isStickingToTrack,
                onChanged: (v) => controller.setStickingToTrack(v ?? true),
              ),
            if (config.showBarCheckbox)
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(EspStrings.barGraph, style: const TextStyle(fontSize: 13)),
                value: view.barGraphVisible,
                onChanged: (v) => controller.setBarGraphVisible(v ?? false),
              ),
            if (config.showEnergyGraphToggle &&
                controller is GraphsController) ...[
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Energy Graph',
                    style: TextStyle(fontSize: 13)),
                value: (controller as GraphsController)
                    .graphsModel
                    .energyGraphExpanded,
                onChanged: (v) => (controller as GraphsController)
                    .setEnergyGraphExpanded(v ?? true),
              ),
            ],
            if (config.showSceneSelector && config.onScene != null) ...[
              const Divider(height: 16),
              TrackSceneSelector(
                scenes: config.scenes,
                selected: model is TrackSetModel ? model.scene : TrackScene.parabola,
                onSelected: config.onScene!,
              ),
            ],
            const Divider(height: 16),
            Text(EspStrings.friction,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Slider(
              value: model.friction,
              min: EspConstants.minFriction,
              max: EspConstants.maxFriction,
              onChanged: controller.setFriction,
            ),
            GravityControls(
              controller: controller,
              showCombo: config.showGravityCombo,
              showValueDisplay: config.showGravityCombo,
              sliderOnly: !config.showGravityCombo,
            ),
            Text('${EspStrings.mass}: ${model.skater.mass.toStringAsFixed(0)} kg',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Slider(
              value: model.skater.mass.clamp(20, 100),
              min: 20,
              max: 100,
              onChanged: controller.setMass,
            ),
            const Divider(height: 16),
            SkaterSelectionPanel(
              selectedIndex: view.selectedSkaterIndex,
              onSelected: controller.setSelectedSkater,
            ),
            if (config.showToolbox) ...[
              const Divider(height: 16),
              Align(
                alignment: Alignment.center,
                child: ToolboxPanel(
                  panelKey: controller.toolboxPanelKey,
                  controller: controller,
                  mvt: mvt,
                  playAreaSize: playSize,
                  onDragStart: () {},
                  onDragUpdate: (local, tool) {
                    final center = Offset(playSize.width / 2, playSize.height / 2);
                    if (tool == ToolboxTool.stopwatch) {
                      controller.placeStopwatchFromToolbox(
                        center - const Offset(50, 24),
                        playSize,
                      );
                    } else {
                      controller.placeMeasuringTapeFromToolbox(
                        mvt.viewToModel(center),
                      );
                    }
                  },
                  onDragEnd: () {},
                ),
              ),
            ],
            if (config.playgroundActions) ...[
              const Divider(height: 16),
              FilledButton(
                onPressed: config.onAddTrack,
                child: const Text(EspStrings.addTrack),
              ),
              const SizedBox(height: 6),
              OutlinedButton(
                onPressed: config.onClearTracks,
                child: const Text(EspStrings.clearTracks),
              ),
              if (config.canSplit || config.canDeleteCp) ...[
                const SizedBox(height: 8),
                const Text('选中控制点',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed:
                            config.canSplit ? config.onSplitControlPoint : null,
                        child: const Text(EspStrings.splitTrack,
                            style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: config.canDeleteCp
                            ? config.onDeleteControlPoint
                            : null,
                        child: const Text(EspStrings.deleteControlPoint,
                            style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  static Widget _checkboxTitle(String label, Widget icon) => Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      );
}
