import 'package:flutter/material.dart';
import 'package:kratos/energy_forms_and_changes/common/transform/efac_mvt.dart';
import 'package:kratos/energy_forms_and_changes/efac_assets.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';
import 'package:kratos/energy_forms_and_changes/efac_layout_constants.dart';
import 'package:kratos/energy_forms_and_changes/intro/painters/beaker_painter.dart';
import 'package:kratos/energy_forms_and_changes/intro/widgets/beaker_steam_overlay.dart';
import 'package:kratos/energy_forms_and_changes/intro/widgets/temperature_and_color_sensor_widget.dart';
import 'package:kratos/energy_forms_and_changes/systems/model/systems_model.dart';

/// PhET `BeakerHeaterNode` — local origin = model position.
///
/// Evidence:
/// - `systems/view/BeakerHeaterNode.ts` — asset offsets + z-order
/// - `systems/model/BeakerHeater.ts` — BEAKER_OFFSET / thermometer offset
/// - `common/view/BeakerView.ts` — back/front split (no invent Path)
class BeakerHeaterNode extends StatelessWidget {
  const BeakerHeaterNode({
    super.key,
    required this.model,
    required this.opacity,
  });

  final SystemsModel model;
  final double opacity;

  static const double _systemsScale = EfacConstants.systemsMvtScaleFactor;

  @override
  Widget build(BuildContext context) {
    final heat = model.beakerHeaterHeatProportion;
    final beaker = model.beakerHeaterBeaker;
    final ws = EfacLayoutConstants.wireImageScale;

    final wireStraightW =
        EfacLayoutConstants.wireStraightNative.width * ws;
    final wireStraightH =
        EfacLayoutConstants.wireStraightNative.height * ws;
    final wireStraightLeft = EfacLayoutConstants.wireStraightLeft;
    final wireStraightTop = EfacLayoutConstants.wireStraightTop;

    // wireBottomRightShort: left = wireStraight.right - 4
    final wireBrW =
        EfacLayoutConstants.wireBottomRightShortNative.width * ws;
    final wireBrH =
        EfacLayoutConstants.wireBottomRightShortNative.height * ws;
    final wireBrLeft = wireStraightLeft + wireStraightW - 4;
    final wireBrBottom = wireStraightTop + wireStraightH + 2.1;
    final wireBrTop = wireBrBottom - wireBrH;

    // elementBaseBack: maxWidth=72, right = wireBr.right + 22
    final baseW = EfacLayoutConstants.elementBaseWidth;
    final baseRight = wireBrLeft + wireBrW + 22;
    final baseLeft = baseRight - baseW;
    final baseBackTop = wireBrTop - 2.5;
    // elementBaseFront.top = wireBr.top - 3 (BeakerHeaterNode.ts:58)
    final baseFrontTop = wireBrTop - 3;

    // coils: maxHeight = modelToViewDeltaX(HEATER_ELEMENT_2D_HEIGHT)
    final coilH =
        EfacLayoutConstants.heaterElement2dHeight * _systemsScale;
    final coilCenterX =
        baseLeft + baseW / 2 + EfacLayoutConstants.coilCenterXOffset;
    final coilBottom = baseFrontTop + EfacLayoutConstants.coilTopOffset;
    final coilTop = coilBottom - coilH;
    // intrinsic 148×60 → width from height
    final coilW = coilH * (148 / 60);

    // BeakerView local (followPosition=false): untransformed bounds scaled.
    // Rectangle(-w/2, 0, w, h) → view (-w/2·s … w/2·s, -h·s … 0).
    final beakerW =
        EfacLayoutConstants.beakerWidth * _systemsScale;
    final beakerH =
        EfacLayoutConstants.beakerHeight * _systemsScale;
    final beakerLeft = -beakerW / 2;
    final beakerTop = -beakerH;

    // Thermometer tip = scaleOnlyMVT(model offset) — BeakerHeater.ts:156
    final tip = EfacLayoutConstants.beakerThermometerOffset;
    final tipX = tip.dx * _systemsScale;
    final tipY = -tip.dy * _systemsScale;

    final mvt = EfacMvt.systems();
    final thermoLeft = tipX;
    final thermoTop =
        tipY - TemperatureAndColorSensorWidget.tipFromTop;

    final minX = [
      wireStraightLeft,
      baseLeft,
      beakerLeft,
      thermoLeft,
    ].reduce((a, b) => a < b ? a : b);
    final minY = [
      beakerTop,
      coilTop,
      wireStraightTop,
      thermoTop,
    ].reduce((a, b) => a < b ? a : b);
    final maxX = [
      baseRight,
      beakerLeft + beakerW,
      thermoLeft + TemperatureAndColorSensorWidget.nominalWidth,
    ].reduce((a, b) => a > b ? a : b);
    final maxY = [
      wireBrBottom,
      baseBackTop + baseW * (92 / 152),
    ].reduce((a, b) => a > b ? a : b);

    Widget at(double x, double y, Widget child) => Positioned(
          left: x - minX,
          top: y - minY,
          child: child,
        );

    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: maxX - minX,
        height: maxY - minY,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            at(
              wireStraightLeft,
              wireStraightTop,
              Image.asset(
                EfacAssets.png('wireStraight'),
                width: wireStraightW,
                height: wireStraightH,
                gaplessPlayback: true,
              ),
            ),
            at(
              wireBrLeft,
              wireBrTop,
              Image.asset(
                EfacAssets.png('wireBottomRightShort'),
                width: wireBrW,
                height: wireBrH,
                gaplessPlayback: true,
              ),
            ),
            at(
              baseLeft,
              baseBackTop,
              Image.asset(
                EfacAssets.png('elementBaseBack'),
                width: baseW,
                gaplessPlayback: true,
              ),
            ),
            at(
              coilCenterX - coilW / 2,
              coilTop,
              Image.asset(
                EfacAssets.png('heaterElementDark'),
                width: coilW,
                height: coilH,
                gaplessPlayback: true,
              ),
            ),
            at(
              coilCenterX - coilW / 2,
              coilTop,
              Opacity(
                opacity: heat.clamp(0.0, 1.0),
                child: Image.asset(
                  EfacAssets.png('heaterElement'),
                  width: coilW,
                  height: coilH,
                  gaplessPlayback: true,
                ),
              ),
            ),
            at(
              baseLeft,
              baseFrontTop,
              Image.asset(
                EfacAssets.png('elementBaseFront'),
                width: baseW,
                gaplessPlayback: true,
              ),
            ),
            // BeakerView back → front (no extra Path)
            at(
              beakerLeft,
              beakerTop,
              CustomPaint(
                size: Size(beakerW, beakerH),
                painter: BeakerPainter(
                  beaker: beaker,
                  mvt: mvt,
                  energyChunksVisible: model.energyChunksVisible,
                  layer: BeakerPaintLayer.back,
                ),
              ),
            ),
            at(
              beakerLeft,
              beakerTop,
              CustomPaint(
                size: Size(beakerW, beakerH),
                painter: BeakerPainter(
                  beaker: beaker,
                  mvt: mvt,
                  energyChunksVisible: model.energyChunksVisible,
                  layer: BeakerPaintLayer.front,
                ),
              ),
            ),
            // Steam when near boiling — BeakerSteamCanvasNode.
            at(
              beakerLeft,
              beakerTop,
              BeakerSteamOverlay(
                beaker: beaker,
                width: beakerW,
                height: beakerH,
              ),
            ),
            at(
              thermoLeft,
              thermoTop,
              TemperatureAndColorSensorWidget(
                temperatureKelvin: beaker.temperature,
                sensedColor: const Color(0xFF4FC3F7),
                active: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Stack top-left so local (0,0) = model origin.
  static Offset topLeftFromModelOrigin() {
    final ws = EfacLayoutConstants.wireImageScale;
    final wireStraightW =
        EfacLayoutConstants.wireStraightNative.width * ws;
    final wireBrW =
        EfacLayoutConstants.wireBottomRightShortNative.width * ws;
    final wireBrLeft =
        EfacLayoutConstants.wireStraightLeft + wireStraightW - 4;
    final baseRight = wireBrLeft + wireBrW + 22;
    final baseLeft = baseRight - EfacLayoutConstants.elementBaseWidth;
    final beakerW =
        EfacLayoutConstants.beakerWidth * _systemsScale;
    final beakerH =
        EfacLayoutConstants.beakerHeight * _systemsScale;
    final tip = EfacLayoutConstants.beakerThermometerOffset;
    final tipX = tip.dx * _systemsScale;
    final tipY = -tip.dy * _systemsScale;
    final thermoTop =
        tipY - TemperatureAndColorSensorWidget.tipFromTop;

    final minX = [
      EfacLayoutConstants.wireStraightLeft,
      baseLeft,
      -beakerW / 2,
      tipX,
    ].reduce((a, b) => a < b ? a : b);
    final coilH =
        EfacLayoutConstants.heaterElement2dHeight * _systemsScale;
    final wireBrH =
        EfacLayoutConstants.wireBottomRightShortNative.height * ws;
    final wireStraightH =
        EfacLayoutConstants.wireStraightNative.height * ws;
    final wireBrBottom =
        EfacLayoutConstants.wireStraightTop + wireStraightH + 2.1;
    final wireBrTop = wireBrBottom - wireBrH;
    final baseFrontTop = wireBrTop - 3;
    final coilTop =
        baseFrontTop + EfacLayoutConstants.coilTopOffset - coilH;

    final minY = [
      -beakerH,
      coilTop,
      EfacLayoutConstants.wireStraightTop,
      thermoTop,
    ].reduce((a, b) => a < b ? a : b);
    return Offset(minX, minY);
  }
}
