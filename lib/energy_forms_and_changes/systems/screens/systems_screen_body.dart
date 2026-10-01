import 'package:flutter/material.dart';
import 'package:kratos/energy_forms_and_changes/common/transform/efac_mvt.dart';
import 'package:kratos/energy_forms_and_changes/efac_assets.dart';
import 'package:kratos/energy_forms_and_changes/efac_colors.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';
import 'package:kratos/energy_forms_and_changes/efac_layout_constants.dart';
import 'package:kratos/energy_forms_and_changes/efac_strings.dart';
import 'package:kratos/energy_forms_and_changes/systems/controller/systems_controller.dart';
import 'package:kratos/energy_forms_and_changes/systems/model/belt_geometry.dart';
import 'package:kratos/energy_forms_and_changes/systems/model/systems_model.dart';
import 'package:kratos/energy_forms_and_changes/systems/widgets/beaker_heater_node.dart';
import 'package:kratos/energy_forms_and_changes/systems/widgets/biker_node.dart';
import 'package:kratos/energy_forms_and_changes/systems/widgets/energy_user_nodes.dart';
import 'package:kratos/energy_forms_and_changes/systems/widgets/faucet_and_water_node.dart';
import 'package:kratos/energy_forms_and_changes/systems/widgets/generator_node.dart';
import 'package:kratos/energy_forms_and_changes/systems/widgets/solar_panel_node.dart';
import 'package:kratos/energy_forms_and_changes/systems/widgets/sun_energy_node.dart';
import 'package:kratos/energy_forms_and_changes/systems/widgets/tea_kettle_node.dart';

/// Systems screen rebuilt to match PhET `SystemsScreenView` z-order.
///
/// Element nodes use local origin = model position (MoveFadeModelElementNode).
class SystemsScreenBody extends StatelessWidget {
  const SystemsScreenBody({super.key, required this.controller});

  final SystemsController controller;

  static const double edgeInset = 10;
  static const double selectorSpacing = 82;
  static const double bottomPanelHeight = 49;

  @override
  Widget build(BuildContext context) {
    final mvt = EfacMvt.systems();
    return ListenableBuilder(
      listenable: controller.model,
      builder: (context, _) {
        final model = controller.model;
        // Design-space only (1024×618). Viewport fit is [EfacSimulationShell].
        return ColoredBox(
          color: EfacColors.screenBackground,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ..._allUsers(model, mvt),
              _atModel(
                mvt,
                model.converters.positionForIndex(0),
                GeneratorNode.topLeftFromModelOrigin(),
                GeneratorNode(
                  model: model,
                  opacity: 1,
                  directCoupling: model.beltVisible,
                ),
                visible: model.converters.targetIndex == 0 ||
                    model.converters.opacityForIndex(0) > 0.05,
                opacity: model.converters.opacityForIndex(0),
              ),
              if (model.beltVisible) _belt(mvt),
              ..._otherConverters(model, mvt),
              _atModel(
                mvt,
                model.sources.positionForIndex(0),
                BikerNode.topLeftFromModelOrigin(mvt.scale),
                BikerNode(
                  model: model,
                  opacity: 1,
                  mvtScale: mvt.scale,
                ),
                visible: model.sources.targetIndex == 0 ||
                    model.sources.opacityForIndex(0) > 0.05,
                opacity: model.sources.opacityForIndex(0),
              ),
              ..._otherSources(model, mvt),
              if (model.energyChunksVisible) ..._pathChunks(model, mvt),
              _energySymbolsPanel(model),
              if (model.energyChunksVisible) _legend(model),
              _bottomPanel(),
              _timeAndReset(controller),
              _selectors(model),
              _sky(),
            ],
          ),
        );
      },
    );
  }

  /// Place [child] so its local (0,0) maps to [modelPos] in view,
  /// given that child's Stack top-left is [localTopLeft] in local coords.
  Widget _atModel(
    EfacMvt mvt,
    Offset modelPos,
    Offset localTopLeft,
    Widget child, {
    required bool visible,
    double opacity = 1,
  }) {
    if (!visible || opacity < 0.05) return const SizedBox.shrink();
    final origin = mvt.modelToView(modelPos);
    return Positioned(
      left: origin.dx + localTopLeft.dx,
      top: origin.dy + localTopLeft.dy,
      child: Opacity(opacity: opacity.clamp(0.0, 1.0), child: child),
    );
  }

  List<Widget> _allUsers(SystemsModel model, EfacMvt mvt) {
    final out = <Widget>[];
    // Light only when converter actually delivers electrical energy
    // (bike+solar / sun+generator produce zero — PhET type match).
    final electrical =
        (model.lastFromConverter?.amount ?? 0) > 1e-9;
    final lit = electrical || model.beakerHeaterHeatProportion > 0.05;
    for (var i = 0; i < model.users.ids.length; i++) {
      final op = model.users.opacityForIndex(i);
      if (op < 0.05) continue;
      final id = model.users.ids[i];
      final litProportion = lit ? 1.0 : 0.0;
      final child = switch (id) {
        EnergyUserId.beakerHeater =>
          BeakerHeaterNode(model: model, opacity: 1),
        EnergyUserId.incandescentBulb => LightBulbNode(
            fluorescent: false,
            lit: lit,
            litProportion: litProportion,
            opacity: 1,
            energyChunksVisible: model.energyChunksVisible,
          ),
        EnergyUserId.fluorescentBulb => LightBulbNode(
            fluorescent: true,
            lit: lit,
            litProportion: litProportion,
            opacity: 1,
            energyChunksVisible: model.energyChunksVisible,
          ),
        EnergyUserId.fan => FanNode(model: model, opacity: 1),
      };
      final localTopLeft = switch (id) {
        EnergyUserId.beakerHeater => BeakerHeaterNode.topLeftFromModelOrigin(),
        EnergyUserId.incandescentBulb =>
          LightBulbNode.topLeftFromModelOrigin(fluorescent: false),
        EnergyUserId.fluorescentBulb =>
          LightBulbNode.topLeftFromModelOrigin(fluorescent: true),
        EnergyUserId.fan => FanNode.topLeftFromModelOrigin(),
      };
      out.add(
        _atModel(
          mvt,
          model.users.positionForIndex(i),
          localTopLeft,
          child,
          visible: true,
          opacity: op,
        ),
      );
    }
    return out;
  }

  List<Widget> _otherConverters(SystemsModel model, EfacMvt mvt) {
    final out = <Widget>[];
    // Solar panel is converters index 1 — same _atModel chain as Generator.
    final op = model.converters.opacityForIndex(1);
    if (op >= 0.05) {
      out.add(
        _atModel(
          mvt,
          model.converters.positionForIndex(1),
          SolarPanelNode.topLeftFromModelOrigin(),
          SolarPanelNode(opacity: 1),
          visible: true,
          opacity: op,
        ),
      );
    }
    return out;
  }

  List<Widget> _otherSources(SystemsModel model, EfacMvt mvt) {
    final out = <Widget>[];
    for (var i = 1; i < model.sources.ids.length; i++) {
      final op = model.sources.opacityForIndex(i);
      if (op < 0.05) continue;
      final id = model.sources.ids[i];
      final child = switch (id) {
        EnergySourceId.faucet =>
          FaucetAndWaterNode(model: model, opacity: 1),
        EnergySourceId.sun => SunEnergyNode(model: model, opacity: 1),
        EnergySourceId.teaKettle =>
          TeaKettleNode(model: model, opacity: 1),
        EnergySourceId.biker => const SizedBox.shrink(),
      };
      final localTopLeft = switch (id) {
        EnergySourceId.faucet => FaucetAndWaterNode.topLeftFromModelOrigin(),
        EnergySourceId.sun => SunEnergyNode.topLeftFromModelOrigin(),
        EnergySourceId.teaKettle => TeaKettleNode.topLeftFromModelOrigin(),
        EnergySourceId.biker => Offset.zero,
      };
      out.add(
        _atModel(
          mvt,
          model.sources.positionForIndex(i),
          localTopLeft,
          child,
          visible: true,
          opacity: op,
        ),
      );
    }
    return out;
  }

  Widget _belt(EfacMvt mvt) {
    // Belt.ts + BeltNode.ts: closed double-arc path, stroke black, lineWidth 4.
    // Wheel centers/radii from SystemsModel.ts — same set as connection points.
    final geometry = BeltGeometry(
      wheel1Center: EfacLayoutConstants.beltWheel1Center,
      wheel1Radius: EfacLayoutConstants.rearWheelRadius,
      wheel2Center: EfacLayoutConstants.beltWheel2Center,
      wheel2Radius: EfacLayoutConstants.generatorWheelRadius,
    );
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _BeltPainter(geometry: geometry, mvt: mvt),
        ),
      ),
    );
  }

  List<Widget> _pathChunks(SystemsModel model, EfacMvt mvt) {
    return [
      for (final mover in model.pathMovers)
        Positioned(
          left: mvt.modelToView(mover.position).dx - 10,
          top: mvt.modelToView(mover.position).dy - 10,
          child: Image.asset(EfacAssets.energyMechanical, width: 20, height: 20),
        ),
    ];
  }

  Widget _energySymbolsPanel(SystemsModel model) {
    return Positioned(
      right: edgeInset,
      top: edgeInset,
      child: Material(
        color: EfacColors.controlPanelBackground,
        borderRadius: BorderRadius.circular(
          EfacConstants.energySymbolsPanelMinWidth > 0 ? 6 : 6,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: EfacConstants.energySymbolsPanelMinWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Checkbox(
                  value: model.energyChunksVisible,
                  onChanged: (v) => model.setEnergyChunksVisible(v ?? false),
                ),
                Image.asset(EfacAssets.energyThermal, width: 20, height: 20),
                const SizedBox(width: 4),
                const Text(EfacStrings.energySymbols),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _legend(SystemsModel model) {
    return Positioned(
      right: edgeInset,
      top: 70,
      child: Material(
        color: EfacColors.controlPanelBackground,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                EfacStrings.formsOfEnergy,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              _leg(EfacAssets.energyMechanical, EfacStrings.mechanical),
              _leg(EfacAssets.energyElectrical, EfacStrings.electrical),
              _leg(EfacAssets.energyThermal, EfacStrings.thermal),
              _leg(EfacAssets.energyLight, EfacStrings.light),
              _leg(EfacAssets.energyChemical, EfacStrings.chemical),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leg(String a, String l) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(children: [
          Image.asset(a, width: 16, height: 16),
          const SizedBox(width: 6),
          Text(l, style: const TextStyle(fontSize: 11)),
        ]),
      );

  Widget _bottomPanel() {
    return Positioned(
      left: 0,
      right: 0,
      top: EfacConstants.layoutHeight - bottomPanelHeight,
      height: bottomPanelHeight,
      child: const ColoredBox(color: EfacColors.clockControlBackground),
    );
  }

  Widget _timeAndReset(SystemsController controller) {
    // SystemsScreenView.ts:
    // resetAllButton.centerY = (bottomPanel.top + layout.maxY) / 2
    // timeControlNode.center = (layout.centerX, resetAllButton.centerY)
    final model = controller.model;
    final cy = EfacConstants.layoutHeight - bottomPanelHeight / 2;
    const playD = 41.6;
    const stepD = 30.0;
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: cy - playD / 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                color: const Color(0xFF1976D2),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => controller.setPlaying(!model.isPlaying),
                  child: SizedBox(
                    width: playD,
                    height: playD,
                    child: Icon(
                      model.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: const Color(0xFFBDBDBD),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: model.isPlaying ? null : controller.manualStep,
                  child: SizedBox(
                    width: stepD,
                    height: stepD,
                    child: const Icon(
                      Icons.skip_next,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: edgeInset,
          top: cy - 20,
          child: Material(
            color: const Color(0xFFFF9800),
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: controller.reset,
              icon: const Icon(Icons.refresh, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _selectors(SystemsModel model) {
    final bottom = EfacConstants.layoutHeight - bottomPanelHeight - edgeInset;
    return Positioned(
      left: edgeInset,
      right: edgeInset,
      bottom: EfacConstants.layoutHeight - bottom,
      child: Row(
        children: [
          _selectorPanel(
            icons: [
              EfacAssets.bicycleIcon,
              EfacAssets.faucetIcon,
              EfacAssets.sunIcon,
              EfacAssets.teaKettleIcon,
            ],
            selected: model.sources.targetIndex,
            onSelect: model.selectSourceIndex,
          ),
          SizedBox(width: selectorSpacing),
          _selectorPanel(
            icons: [
              EfacAssets.generatorIcon,
              EfacAssets.solarPanelIcon,
            ],
            selected: model.converters.targetIndex,
            onSelect: model.selectConverterIndex,
          ),
          SizedBox(width: selectorSpacing),
          _selectorPanel(
            icons: [
              EfacAssets.waterIcon,
              EfacAssets.incandescentIcon,
              EfacAssets.fluorescentIcon,
              EfacAssets.fanIcon,
            ],
            selected: model.users.targetIndex,
            onSelect: model.selectUserIndex,
          ),
        ],
      ),
    );
  }

  Widget _selectorPanel({
    required List<String> icons,
    required int selected,
    required void Function(int) onSelect,
  }) {
    // EnergySystemElementSelector: icons scaled to 44×44, Panel cornerRadius 10
    return Material(
      color: Colors.white,
      elevation: 1,
      borderRadius: BorderRadius.circular(EfacConstants.controlPanelCornerRadius),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < icons.length; i++) ...[
              if (i > 0) const SizedBox(width: 15),
              InkWell(
                onTap: () => onSelect(i),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: i == selected
                          ? const Color(0xFF1976D2)
                          : Colors.transparent,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Image.asset(icons[i], width: 44, height: 44),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sky() {
    // SkyNode: fade above SYSTEMS_SCREEN_ENERGY_CHUNK_MAX_TRAVEL_HEIGHT
    // modelToViewY(0.55) from origin: originY - 0.55*scale
    final y = EfacConstants.layoutHeight * 0.475 -
        0.55 * EfacConstants.systemsMvtScaleFactor +
        EfacConstants.energyChunkWidth;
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      height: y.clamp(0, EfacConstants.layoutHeight * 0.2),
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                EfacColors.screenBackground,
                EfacColors.screenBackground.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BeltPainter extends CustomPainter {
  _BeltPainter({required this.geometry, required this.mvt});

  final BeltGeometry geometry;
  final EfacMvt mvt;

  /// BeltNode.ts: stroke black, lineWidth 4.
  static const double lineWidth = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final path = geometry.toViewPath(mvt.modelToView);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..strokeWidth = lineWidth
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _BeltPainter oldDelegate) =>
      oldDelegate.geometry.wheel1Center != geometry.wheel1Center ||
      oldDelegate.geometry.wheel2Center != geometry.wheel2Center ||
      oldDelegate.geometry.wheel1Radius != geometry.wheel1Radius ||
      oldDelegate.geometry.wheel2Radius != geometry.wheel2Radius ||
      oldDelegate.mvt.scale != mvt.scale;
}

