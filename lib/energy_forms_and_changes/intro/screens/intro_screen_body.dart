import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kratos/energy_forms_and_changes/common/model/beaker.dart';
import 'package:kratos/energy_forms_and_changes/common/model/burner.dart';
import 'package:kratos/energy_forms_and_changes/common/model/energy_type.dart';
import 'package:kratos/energy_forms_and_changes/common/transform/efac_mvt.dart';
import 'package:kratos/energy_forms_and_changes/common/widgets/heater_cooler_control.dart';
import 'package:kratos/energy_forms_and_changes/efac_assets.dart';
import 'package:kratos/energy_forms_and_changes/efac_colors.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';
import 'package:kratos/energy_forms_and_changes/efac_layout_constants.dart';
import 'package:kratos/energy_forms_and_changes/efac_strings.dart';
import 'package:kratos/energy_forms_and_changes/intro/controller/intro_controller.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/efac_intro_model.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/efac_intro_z_order.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/sticky_thermometer.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/thermal_block.dart';
import 'package:kratos/energy_forms_and_changes/intro/painters/beaker_painter.dart';
import 'package:kratos/energy_forms_and_changes/intro/widgets/beaker_steam_overlay.dart';
import 'package:kratos/energy_forms_and_changes/intro/widgets/block_node_widget.dart';
import 'package:kratos/energy_forms_and_changes/intro/widgets/temperature_and_color_sensor_widget.dart';
import 'package:kratos/energy_forms_and_changes/intro/widgets/time_speed_radio_group.dart';

/// Intro screen rebuilt to PhET `EFACIntroScreenView` layer order.
///
/// Z-order (bottom→top), evidence `EFACIntroScreenView.ts` + `BeakerView.ts`:
/// back(shelf,time,heaterBack,stand,pipe,storage,panel) →
/// beakerBack → **beakerGrab** → block → air/EC → heaterFront →
/// beakerFront (fluid+glass+steam, non-pickable) → thermometer → reset → sky
///
/// `frontNode`/`backNode` pickable=false; drag only on `grabNode`.
/// HeaterCooler flame/ice: [BLOCKED scenery-phet] — heatCoolLevel still bound.
class IntroScreenBody extends StatefulWidget {
  const IntroScreenBody({super.key, required this.controller});

  final IntroController controller;

  @override
  State<IntroScreenBody> createState() => _IntroScreenBodyState();
}

class _IntroScreenBodyState extends State<IntroScreenBody> {
  final EfacMvt mvt = EfacMvt.intro();
  bool _storageInit = false;

  static const double edgeInset = 10;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller.model,
      builder: (context, _) {
        final model = widget.controller.model;
        if (!_storageInit) {
          _storageInit = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initThermometerStorage(model);
          });
        }
        // Design-space only (1024×618). Viewport fit is [EfacSimulationShell].
        return ColoredBox(
          color: EfacColors.screenBackground,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // === backLayer ===
              _labBenchSide(),
              _shelf(),
              // TimeControl deferred to above heaterFront — PhET keeps it in
              // backLayer, but default PhET omits speed radios; with Always-on
              // Normal/FF the control must stay pickable (not under stove body).
              for (final burner in model.burners) ..._burnerBack(model, burner),
              _thermometerStorage(model),
              for (final t in model.thermometers)
                if (!t.active) _thermometer(model, t, model.thermometers.indexOf(t)),
              _controlPanel(model),

              // === beakerBackLayer (order = centerY back→front) ===
              for (final beaker
                  in EfacIntroZOrder.beakersBackToFront(model.beakers))
                _beaker(model, beaker, BeakerPaintLayer.back),

              // === beakerGrabLayer — pickable only; between back & blocks ===
              for (final beaker
                  in EfacIntroZOrder.beakersBackToFront(model.beakers))
                _beaker(model, beaker, BeakerPaintLayer.grab),

              // === blockLayer (order = zIndex back→front) ===
              for (final block
                  in EfacIntroZOrder.blocksBackToFront(model.blocks))
                _block(model, block),

              // === energy chunk layers ===
              if (model.energyChunksVisible) ..._energyChunks(model),

              // === heaterCoolerFrontLayer ===
              for (final burner in model.burners) _heaterFront(model, burner),

              // === beakerFrontLayer (fluid + glass + steam; non-pickable) ===
              for (final beaker
                  in EfacIntroZOrder.beakersBackToFront(model.beakers))
                _beaker(model, beaker, BeakerPaintLayer.front),

              // === thermometerLayer (active) ===
              for (final t in model.thermometers)
                if (t.active) _thermometer(model, t, model.thermometers.indexOf(t)),

              // === time + reset (root-adjacent; pickable over stove hang) ===
              _timeBar(widget.controller),
              _resetButton(widget.controller),

              // === skyNode ===
              _sky(),
            ],
          ),
        );
      },
    );
  }

  void _initThermometerStorage(EfacIntroModel model) {
    // EFACIntroScreenView.ts: storage = nodeW*2 × nodeH*1.15, EDGE_INSET=10,
    // offsetFromBottomOfStorageArea=25, tip at storage bottom - 25.
    final nodeW = TemperatureAndColorSensorWidget.nominalWidth;
    final nodeH = TemperatureAndColorSensorWidget.nominalHeight;
    final storage = thermometerStorageSize(Size(nodeW, nodeH));
    const offsetFromBottom = 25.0;
    final storageLeft = edgeInset;
    final storageTop = edgeInset;
    final thermometerNodePositionX =
        storageLeft + (storage.width - nodeW) / 2;
    final viewPos = Offset(
      thermometerNodePositionX,
      storageTop + storage.height - offsetFromBottom,
    );
    final modelPos = mvt.viewToModel(viewPos);
    model.setThermometerStoragePositions(
      List<Offset>.filled(EfacIntroModel.thermometerCount, modelPos),
    );
  }

  /// Native shelf PNG is 2204×69 (PhET uses unscaled Image).
  static const double _shelfNativeW = 2204;
  static const double _shelfNativeH = 69;
  static const double _gasPipeNativeW = 53;
  static const double _gasPipeNativeH = 60;

  Widget _labBenchSide() {
    final center = mvt.modelToView(Offset.zero);
    // PhET: benchWidth = shelf.width * 0.95, left = shelf.centerX - benchWidth/2
    // fill = CLOCK_CONTROL_BACKGROUND_COLOR (160,160,160) — NOT wood brown.
    final shelfCenterY = center.dy + 10;
    final benchW = _shelfNativeW * 0.95;
    return Positioned(
      left: center.dx - benchW / 2,
      top: shelfCenterY,
      child: Container(
        width: benchW,
        height: EfacConstants.layoutHeight - shelfCenterY,
        color: EfacColors.clockControlBackground,
      ),
    );
  }

  Widget _shelf() {
    final center = mvt.modelToView(Offset.zero);
    // PhET: centerX = mvtX(0), centerY = mvtY(0)+10
    return Positioned(
      left: center.dx - _shelfNativeW / 2,
      top: center.dy + 10 - _shelfNativeH / 2,
      child: Image.asset(
        EfacAssets.shelf,
        width: _shelfNativeW,
        height: _shelfNativeH,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.medium,
      ),
    );
  }

  /// BurnerStandNode width ≈ rectW + projectedEdge (perspective).
  double _burnerStandPaintWidth(double standW, double projection) =>
      standW + projection;

  /// Top pad for BurnerStandNode side parallelograms.
  ///
  /// Side path peak is `upperRight` at Δy = −3·(edge/(2√2)) relative to topCenter
  /// (BurnerStandNode.ts createBurnerStandSide). Using only edge/(2√2) clips the
  /// sides and leaves a floating “top ring” above the heater.
  double _burnerStandPadTop(double projection) =>
      3 * projection * math.sqrt1_2 / 2;

  List<Widget> _burnerBack(EfacIntroModel model, Burner burner) {
    final topLeft = mvt.modelToView(
      Offset(burner.bounds.minX, burner.bounds.maxY),
    );
    final bottomRight = mvt.modelToView(
      Offset(burner.bounds.maxX, burner.bounds.minY),
    );
    final standW = (bottomRight.dx - topLeft.dx).abs();
    final standH = (bottomRight.dy - topLeft.dy).abs();
    final projection = standH * EfacConstants.burnerEdgeToHeightRatio;
    final standPaintW = _burnerStandPaintWidth(standW, projection);
    // PhET: minWidth/maxWidth = leftBurnerStand.width / 1.5
    final heaterW = standPaintW / EfacLayoutConstants.heaterWidthDivisor;
    final centerX = mvt.modelToView(Offset(burner.bounds.center.dx, 0)).dx;
    final bottomY = mvt.modelToView(Offset(0, burner.bounds.minY)).dy;
    final heaterLeft = centerX - heaterW / 2;
    final openingH =
        heaterW * EfacLayoutConstants.heaterCoolerOpeningHeightScale;
    final standPadTop = _burnerStandPadTop(projection);
    final pipeScale = EfacLayoutConstants.gasPipeScale;
    final pipeW = _gasPipeNativeW * pipeScale;
    final pipeH = _gasPipeNativeH * pipeScale;
    final bodyH = heaterW * 0.75;
    // Original runtime: grey stove nests INSIDE stand legs (opening near stand
    // mid/top, body bottom ≈ shelf / burner.minY). Positioning only the opening
    // at burner.minY left the stand empty and the body hanging below the shelf.
    final stoveH = bodyH + openingH;
    final stoveBottom = bottomY;
    final stoveTop = stoveBottom - stoveH;
    // HeaterCoolerBack opening at stove top; Front leftTop = back + (0, oh/2)
    final backTop = stoveTop;
    final frontTop = stoveTop + openingH / 2;
    final frontBottom = frontTop + bodyH + openingH + 8;
    final pipeRight =
        heaterLeft + EfacLayoutConstants.gasPipeRightFromHeaterLeft;
    final pipeBottom =
        frontBottom - EfacLayoutConstants.gasPipeBottomFromHeaterBottom;

    // PhET backLayer order: heaterBack → stand → gasPipe
    // (EFACIntroScreenView.ts:229-231)
    return [
      Positioned(
        left: heaterLeft,
        top: backTop,
        child: HeaterCoolerControl(
          value: burner.heatCoolLevel,
          onChanged: (_) {},
          stoveWidth: heaterW,
          layer: HeaterCoolerPaintLayer.back,
        ),
      ),
      Positioned(
        left: topLeft.dx - projection / 2,
        top: topLeft.dy - standPadTop,
        child: CustomPaint(
          size: Size(standW + projection, standH + standPadTop),
          painter: _BurnerStandPainter(
            projection: projection,
            standW: standW,
            padTop: standPadTop,
          ),
        ),
      ),
      Positioned(
        left: pipeRight - pipeW,
        top: pipeBottom - pipeH,
        child: Image.asset(
          EfacAssets.gasPipeIntro,
          width: pipeW,
          height: pipeH,
          fit: BoxFit.fill,
          gaplessPlayback: true,
        ),
      ),
    ];
  }

  Widget _heaterFront(EfacIntroModel model, Burner burner) {
    final topLeft = mvt.modelToView(
      Offset(burner.bounds.minX, burner.bounds.maxY),
    );
    final bottomRight = mvt.modelToView(
      Offset(burner.bounds.maxX, burner.bounds.minY),
    );
    final standW = (bottomRight.dx - topLeft.dx).abs();
    final standH = (bottomRight.dy - topLeft.dy).abs();
    final projection = standH * EfacConstants.burnerEdgeToHeightRatio;
    final standPaintW = _burnerStandPaintWidth(standW, projection);
    final heaterW = standPaintW / EfacLayoutConstants.heaterWidthDivisor;
    final centerX = mvt.modelToView(Offset(burner.bounds.center.dx, 0)).dx;
    final bottomY = mvt.modelToView(Offset(0, burner.bounds.minY)).dy;
    final heaterLeft = centerX - heaterW / 2;
    final openingH =
        heaterW * EfacLayoutConstants.heaterCoolerOpeningHeightScale;
    final bodyH = heaterW * 0.75;
    final stoveH = bodyH + openingH;
    final stoveTop = bottomY - stoveH;
    final frontTop = stoveTop + openingH / 2;

    return Positioned(
      left: 0,
      top: 0,
      width: EfacConstants.layoutWidth,
      height: EfacConstants.layoutHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: heaterLeft,
            top: frontTop,
            child: HeaterCoolerControl(
              value: burner.heatCoolLevel,
              onChanged: (v) => model.setHeatCoolLevel(burner, v),
              stoveWidth: heaterW,
              layer: HeaterCoolerPaintLayer.front,
            ),
          ),
        ],
      ),
    );
  }

  Widget _block(EfacIntroModel model, ThermalBlock block) {
    final size = mvt.modelToViewDelta(block.surfaceWidth);
    // PhET BlockNode: translation = mvt.modelToViewPosition(position)
    // on the NODE ORIGIN = untransformed bottom-center (before blockFaceOffset).
    final origin = mvt.modelToView(block.position);
    final localOrigin = BlockNodeWidget.localOriginFromTopLeft(size);
    return Positioned(
      left: origin.dx - localOrigin.dx,
      top: origin.dy - localOrigin.dy,
      child: BlockNodeWidget(
        block: block,
        size: size,
        energyChunksVisible: model.energyChunksVisible,
        onPanStart: (_) => block.userControlled = true,
        onPanUpdate: (d) {
          model.moveBlock(
            block,
            block.position +
                Offset(d.delta.dx / mvt.scale, -d.delta.dy / mvt.scale),
          );
        },
        onPanEnd: (_) => model.endBlockDrag(block),
      ),
    );
  }

  Widget _beaker(
    EfacIntroModel model,
    Beaker beaker,
    BeakerPaintLayer layer,
  ) {
    final w = mvt.modelToViewDelta(beaker.width).abs();
    final h = mvt.modelToViewDelta(beaker.height).abs();
    final bottomLeft = mvt.modelToView(
      Offset(beaker.position.dx - beaker.width / 2, beaker.position.dy),
    );
    // BeakerView: front/back non-pickable; grabNode invisible + drag.
    final paint = CustomPaint(
      size: Size(w, h),
      painter: BeakerPainter(
        beaker: beaker,
        mvt: mvt,
        energyChunksVisible: model.energyChunksVisible,
        layer: layer,
      ),
    );
    late final Widget child;
    switch (layer) {
      case BeakerPaintLayer.back:
        child = IgnorePointer(child: paint);
      case BeakerPaintLayer.grab:
        child = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (_) {
            beaker.userControlled = true;
          },
          onPanUpdate: (d) {
            model.moveBeaker(
              beaker,
              beaker.position +
                  Offset(d.delta.dx / mvt.scale, -d.delta.dy / mvt.scale),
            );
          },
          onPanEnd: (_) => model.endBeakerDrag(beaker),
          child: paint,
        );
      case BeakerPaintLayer.front:
        child = IgnorePointer(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              paint,
              BeakerSteamOverlay(beaker: beaker, width: w, height: h),
            ],
          ),
        );
    }
    return Positioned(
      left: bottomLeft.dx,
      top: bottomLeft.dy - h,
      child: child,
    );
  }

  List<Widget> _energyChunks(EfacIntroModel model) {
    final widgets = <Widget>[];
    final all = [
      ...model.chunkSystem.chunks,
      for (final b in model.blocks) ...b.energyChunks,
      for (final b in model.beakers) ...b.energyChunks,
    ];
    final seen = <int>{};
    for (final c in all) {
      if (!seen.add(c.id)) continue;
      if (c.energyType != EnergyType.thermal) continue;
      final v = mvt.modelToView(c.position);
      widgets.add(
        Positioned(
          left: v.dx - EfacConstants.energyChunkWidth / 2,
          top: v.dy - EfacConstants.energyChunkWidth / 2,
          child: Image.asset(
            EfacAssets.energyThermal,
            width: EfacConstants.energyChunkWidth,
            height: EfacConstants.energyChunkWidth,
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _thermometer(EfacIntroModel model, StickyThermometer t, int index) {
    // Tip (triangle leftmost) = model position in view.
    final tip = mvt.modelToView(t.position);
    return Positioned(
      left: tip.dx,
      top: tip.dy - TemperatureAndColorSensorWidget.tipFromTop,
      child: GestureDetector(
        onPanStart: (_) {
          if (!t.active) {
            // EFACIntroScreenView: THERMOMETER_JUMP_ON_EXTRACTION = (5, 5) view
            model.moveThermometer(
              t,
              t.position + mvt.viewToModelDelta(const Offset(5, 5)),
            );
          }
        },
        onPanUpdate: (d) {
          model.moveThermometer(
            t,
            t.position + Offset(d.delta.dx / mvt.scale, -d.delta.dy / mvt.scale),
          );
        },
        onPanEnd: (_) {
          model.endThermometerDrag(t);
          final storage = model.thermometerStoragePositions[index];
          if ((t.position - storage).distance < 0.08) {
            model.returnThermometerToStorage(t, index);
          }
        },
        child: TemperatureAndColorSensorWidget(
          temperatureKelvin: t.sensedTemperature,
          sensedColor: t.sensedColor,
          active: t.active,
        ),
      ),
    );
  }

  Widget _thermometerStorage(EfacIntroModel model) {
    final nodeW = TemperatureAndColorSensorWidget.nominalWidth;
    final nodeH = TemperatureAndColorSensorWidget.nominalHeight;
    final storage = thermometerStorageSize(Size(nodeW, nodeH));
    return Positioned(
      left: edgeInset,
      top: edgeInset,
      child: Container(
        width: storage.width,
        height: storage.height,
        decoration: BoxDecoration(
          color: EfacColors.controlPanelBackground,
          border: Border.all(color: EfacColors.controlPanelOutline),
          borderRadius:
              BorderRadius.circular(EfacConstants.controlPanelCornerRadius),
        ),
      ),
    );
  }

  Widget _controlPanel(EfacIntroModel model) {
    return Positioned(
      right: edgeInset,
      top: edgeInset,
      child: Material(
        color: EfacColors.controlPanelBackground,
        elevation: 2,
        borderRadius: BorderRadius.circular(6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: EfacConstants.energySymbolsPanelMinWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: model.energyChunksVisible,
                      onChanged: (v) =>
                          model.setEnergyChunksVisible(v ?? false),
                    ),
                    Image.asset(EfacAssets.energyThermal, width: 22, height: 22),
                    const SizedBox(width: 6),
                    const Text(EfacStrings.energySymbols),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: model.linkedHeaters,
                      onChanged: (v) => model.setLinkedHeaters(v ?? false),
                    ),
                    Image.asset(EfacAssets.flame, width: 22, height: 22),
                    const SizedBox(width: 6),
                    const Text(EfacStrings.linkHeaters),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _timeBar(IntroController controller) {
    final model = controller.model;
    // EFACIntroScreenView.ts:
    // centerYBelowSurface = (layoutH + labBenchSurfaceImage.bottom) / 2
    // Default PhET: showSpeedControls flag OFF → Play/Pause + Step only.
    final shelfCenterY = mvt.modelToView(Offset.zero).dy + 10;
    final shelfBottom = shelfCenterY + _shelfNativeH / 2;
    final cy = (EfacConstants.layoutHeight + shelfBottom) / 2;
    const playD = 41.6;
    const stepD = 30.0;
    return Positioned(
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
                child: const Icon(Icons.skip_next, color: Colors.white, size: 18),
              ),
            ),
          ),
          // Speed radios only when explicitly enabled (PhET query flag).
          if (EfacLayoutConstants.showSpeedControls) ...[
            const SizedBox(width: 40),
            TimeSpeedRadioGroup(
              value: model.timeSpeed,
              onChanged: model.setTimeSpeed,
              enabled: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _resetButton(IntroController controller) {
    // EFACIntroScreenView.ts: centerY = (shelf.bottom + layout.maxY) / 2
    final shelfCenterY = mvt.modelToView(Offset.zero).dy + 10;
    final shelfBottom = shelfCenterY + _shelfNativeH / 2;
    final cy = (shelfBottom + EfacConstants.layoutHeight) / 2;
    return Positioned(
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
    );
  }

  Widget _sky() {
    // PhET SkyNode.ts: opaque region is ABOVE fullOpaqueYPosition;
    // fade band is FADE_HEIGHT=200 starting at fullOpaqueYPosition.
    // Intro: fullOpaqueY = modelToViewY(0.85)+EC_WIDTH ≈ negative → sky off-screen.
    // Do NOT paint an opaque cream blanket over y=0 (that hid thermometer storage).
    const fadeHeight = 200.0;
    final fullOpaqueY = mvt
            .modelToView(
              const Offset(0, EfacConstants.introScreenEnergyChunkMaxTravelHeight),
            )
            .dy +
        EfacConstants.energyChunkWidth;

    // Only paint the portion of the fade band that intersects the layout.
    final fadeTop = fullOpaqueY;
    final fadeBottom = fullOpaqueY + fadeHeight;
    if (fadeBottom <= 0 || fadeTop >= EfacConstants.layoutHeight) {
      return const SizedBox.shrink();
    }
    final clipTop = fadeTop.clamp(0.0, EfacConstants.layoutHeight);
    final clipBottom = fadeBottom.clamp(0.0, EfacConstants.layoutHeight);
    final visibleH = clipBottom - clipTop;
    if (visibleH <= 1) return const SizedBox.shrink();

    // Gradient mapped so that fullOpaqueY→opaque white, +FADE_HEIGHT→transparent.
    final t0 = ((clipTop - fadeTop) / fadeHeight).clamp(0.0, 1.0);
    final t1 = ((clipBottom - fadeTop) / fadeHeight).clamp(0.0, 1.0);
    return Positioned(
      left: 0,
      right: 0,
      top: clipTop,
      height: visibleH,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(Colors.white, Colors.white.withValues(alpha: 0), t0)!,
                Color.lerp(Colors.white, Colors.white.withValues(alpha: 0), t1)!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BurnerStandPainter extends CustomPainter {
  /// Port of `BurnerStandNode.ts` — sides + top with oval opening.
  /// [size] = `(standW + projection, standH + padTop)`; burner rect origin at `(projection/2, padTop)`.
  _BurnerStandPainter({
    required this.projection,
    required this.standW,
    required this.padTop,
  });
  final double projection;
  final double standW;
  final double padTop;

  static const double _stroke = 2;
  static const double _angle = EfacLayoutConstants.burnerStandPerspectiveAngle;

  Offset _rot(double x, double y) {
    final c = math.cos(-_angle);
    final s = math.sin(-_angle);
    return Offset(x * c - y * s, x * s + y * c);
  }

  Path _side(Offset topCenter, double height, double edge) {
    final upperLeft = topCenter + _rot(-edge / 2, 0);
    final lowerLeft = upperLeft + Offset(0, height);
    final lowerRight = lowerLeft + _rot(edge, 0);
    final upperRight = lowerRight + Offset(0, -height);
    return Path()
      ..moveTo(topCenter.dx, topCenter.dy)
      ..lineTo(upperLeft.dx, upperLeft.dy)
      ..lineTo(lowerLeft.dx, lowerLeft.dy)
      ..lineTo(lowerRight.dx, lowerRight.dy)
      ..lineTo(upperRight.dx, upperRight.dy)
      ..close();
  }

  Path _top(Offset leftCenter, double width, double edge) {
    final upperLeft = leftCenter + _rot(edge / 2, 0);
    final upperRight = upperLeft + Offset(width, 0);
    final lowerRight = upperRight + _rot(-edge, 0);
    final lowerLeft = lowerRight + Offset(-width, 0);

    final ulOpen = upperLeft + Offset(width * 0.25, 0);
    final urOpen = upperLeft + Offset(width * 0.75, 0);
    final llOpen = lowerLeft + Offset(width * 0.25, 0);
    final lrOpen = lowerLeft + Offset(width * 0.75, 0);
    final persp = _rot(edge * 0.5, 0);

    return Path()
      ..moveTo(upperLeft.dx, upperLeft.dy)
      ..lineTo(ulOpen.dx, ulOpen.dy)
      ..cubicTo(
        ulOpen.dx + persp.dx,
        ulOpen.dy + persp.dy,
        urOpen.dx + persp.dx,
        urOpen.dy + persp.dy,
        urOpen.dx,
        urOpen.dy,
      )
      ..lineTo(upperRight.dx, upperRight.dy)
      ..lineTo(lowerRight.dx, lowerRight.dy)
      ..lineTo(lrOpen.dx, lrOpen.dy)
      ..cubicTo(
        lrOpen.dx - persp.dx,
        lrOpen.dy - persp.dy,
        llOpen.dx - persp.dx,
        llOpen.dy - persp.dy,
        llOpen.dx,
        llOpen.dy,
      )
      ..lineTo(lowerLeft.dx, lowerLeft.dy)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = _stroke
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.butt;

    final h = size.height - padTop;
    final e = projection;
    // Burner rect top edge after pad (matches BurnerStandNode rect.y).
    final leftTop = Offset(e / 2, padTop);
    final rightTop = Offset(e / 2 + standW, padTop);

    canvas.drawPath(_side(leftTop, h, e), paint);
    canvas.drawPath(_side(rightTop, h, e), paint);
    canvas.drawPath(_top(leftTop, standW, e), paint);
  }

  @override
  bool shouldRepaint(covariant _BurnerStandPainter oldDelegate) =>
      oldDelegate.projection != projection ||
      oldDelegate.standW != standW ||
      oldDelegate.padTop != padTop;
}

