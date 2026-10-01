import 'package:flutter/material.dart';

import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/under_pressure/controller/under_pressure_controller.dart';
import 'package:kratos/under_pressure/model/under_pressure_constants.dart';
import 'package:kratos/under_pressure/model/under_pressure_model.dart';
import 'package:kratos/under_pressure/transform/up_mvt.dart';
import 'package:kratos/under_pressure/view/controls/up_control_slider.dart';
import 'package:kratos/under_pressure/view/controls/up_mystery_controls.dart';
import 'package:kratos/under_pressure/view/controls/up_scene_choice_node.dart';
import 'package:kratos/under_pressure/view/controls/up_tools_control_panel.dart';
import 'package:kratos/under_pressure/view/controls/up_units_control_panel.dart';
import 'package:kratos/under_pressure/view/tools/up_barometer_node.dart';
import 'package:kratos/under_pressure/view/tools/up_ruler_layer.dart';
import 'package:kratos/under_pressure/view/up_background_layer.dart';
import 'package:kratos/under_pressure/view/up_cement_pattern.dart';
import 'package:kratos/under_pressure/view/up_chamber_pool_layer.dart';
import 'package:kratos/under_pressure/view/up_square_pool_layer.dart';
import 'package:kratos/under_pressure/view/up_trapezoid_pool_layer.dart';

/// Source: `UnderPressureScreen` + `UnderPressureScreenView`.
class UnderPressureScreen extends StatefulWidget {
  const UnderPressureScreen({super.key, required this.controller});

  final UnderPressureController controller;

  @override
  State<UnderPressureScreen> createState() => _UnderPressureScreenState();
}

class _UnderPressureScreenState extends State<UnderPressureScreen>
    with TickerProviderStateMixin {
  static const double _inset = 15;
  static const double _panelW = 140;

  UnderPressureController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    c.attachTicker(this);
    UpCementPattern.ensureLoaded().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    c.clock.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        return ColoredBox(
          color: Colors.white,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final scale = (constraints.maxWidth / UpMvt.layoutWidth)
                  .clamp(0.0, constraints.maxHeight / UpMvt.layoutHeight);
              final w = UpMvt.layoutWidth * scale;
              final h = UpMvt.layoutHeight * scale;
              return Center(
                child: SizedBox(
                  width: w,
                  height: h,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: UpMvt.layoutWidth,
                      height: UpMvt.layoutHeight,
                      child: _buildStage(),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStage() {
    final m = c.model;
    final resetRight = UpMvt.layoutWidth - _inset;

    final controlRight = resetRight;
    final controlTop = 5.0;
    final sensorPanelRight = controlRight - _panelW - 20;
    final sensorPanelRect = Rect.fromLTWH(
      sensorPanelRight - UnderPressureController.sensorPanelWidth,
      controlTop,
      UnderPressureController.sensorPanelWidth,
      UnderPressureController.sensorPanelHeight,
    );

    // Units panel sits below tools (~120); mystery choice below units.
    const unitsTop = 5.0 + 120;
    const unitsApproxBottom = unitsTop + 90;
    final densitySliderTop = UpMvt.layoutHeight - (55 + 120) - 160;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        UpBackgroundLayer(controller: c),

        switch (m.currentScene) {
          UnderPressureScene.square => UpSquarePoolLayer(controller: c),
          UnderPressureScene.trapezoid => UpTrapezoidPoolLayer(controller: c),
          UnderPressureScene.chamber => UpChamberPoolLayer(controller: c),
          UnderPressureScene.mystery =>
            UpSquarePoolLayer(controller: c, useMysteryPool: true),
        },

        // Sensor toolbox
        Positioned(
          left: sensorPanelRect.left,
          top: sensorPanelRect.top,
          width: sensorPanelRect.width,
          height: sensorPanelRect.height,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF2FA6A),
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ),

        for (var i = 0; i < m.barometers.length; i++)
          UpBarometerNode(
            controller: c,
            index: i,
            sensorPanelRect: sensorPanelRect,
          ),

        UpRulerLayer(controller: c),

        UpSceneChoiceNode(controller: c),

        Positioned(
          right: _inset,
          top: controlTop,
          child: UpToolsControlPanel(controller: c),
        ),
        Positioned(
          right: _inset,
          top: unitsTop,
          child: UpUnitsControlPanel(controller: c),
        ),

        if (m.currentScene == UnderPressureScene.mystery)
          Positioned.fill(
            child: UpMysteryControls(
              controller: c,
              panelLeft: UpMvt.layoutWidth - _inset - _panelW,
              panelTop: unitsApproxBottom + 5,
              panelWidth: _panelW,
              comboRight: UpMvt.layoutWidth - _inset,
              comboTop: densitySliderTop,
            ),
          ),

        Positioned(
          right: _inset,
          bottom: 55 + 120,
          child: UpControlSlider(
            controller: c,
            title: 'Fluid Density',
            value: m.fluidDensity,
            min: m.fluidDensityMin,
            max: m.fluidDensityMax,
            decimals: 0,
            displayString: m.getFluidDensityString(),
            expanded: m.fluidDensityControlExpanded,
            onExpanded: c.setDensityExpanded,
            onChanged: c.setDensity,
            disabled: m.currentScene == UnderPressureScene.mystery &&
                m.mysteryChoice == 'fluidDensity',
            ticks: [
              (title: 'gasoline', value: m.fluidDensityMin),
              (
                title: 'water',
                value: UnderPressureConstants.waterDensity,
              ),
              (title: 'honey', value: m.fluidDensityMax),
            ],
          ),
        ),
        Positioned(
          right: _inset,
          bottom: 55,
          child: UpControlSlider(
            controller: c,
            title: 'Gravity',
            value: m.gravity,
            min: m.gravityMin,
            max: m.gravityMax,
            decimals: 1,
            displayString: m.getGravityString(),
            expanded: m.gravityControlExpanded,
            onExpanded: c.setGravityExpanded,
            onChanged: c.setGravity,
            disabled: m.currentScene == UnderPressureScene.mystery &&
                m.mysteryChoice == 'gravity',
            ticks: [
              (title: 'Mars', value: m.gravityMin),
              (title: 'Earth', value: UnderPressureConstants.earthGravity),
              (title: 'Jupiter', value: m.gravityMax),
            ],
          ),
        ),

        Positioned(
          right: _inset,
          bottom: 5,
          child: KratosResetAllButton(
            radius: 18,
            onPressed: c.resetAll,
          ),
        ),
      ],
    );
  }
}
