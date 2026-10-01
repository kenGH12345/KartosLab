import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kratos/energy_forms_and_changes/common/widgets/heater_cooler_control.dart';
import 'package:kratos/energy_forms_and_changes/efac_assets.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';
import 'package:kratos/energy_forms_and_changes/efac_layout_constants.dart';
import 'package:kratos/energy_forms_and_changes/systems/model/systems_model.dart';

/// PhET `TeaKettleNode` — local origin = model position.
///
/// Evidence `TeaKettleNode.ts`:
/// - teaKettle.png right:114, bottom:53
/// - BURNER_MODEL_BOUNDS + BurnerStand; HeaterCooler scale 0.85, coolEnabled:false
/// - UI setting → heat = s==0 ? 0 : 0.25+0.75*s
class TeaKettleNode extends StatelessWidget {
  const TeaKettleNode({
    super.key,
    required this.model,
    required this.opacity,
  });

  final SystemsModel model;
  final double opacity;

  static const double _s = EfacConstants.systemsMvtScaleFactor;

  /// TeaKettleNode.ts BURNER_MODEL_BOUNDS.
  static const Rect burnerModelBounds = Rect.fromLTRB(-0.037, -0.0075, 0.037, 0.0525);

  static const double burnerEdgeToHeightRatio = 0.2;
  static const double heaterCoolerNodeScale = 0.85;
  static const double gasPipeScale = 0.9;

  /// Map UI setting s∈[0,1] → stored heat proportion.
  static double mapSettingToHeat(double setting) =>
      setting == 0 ? 0 : 0.25 + 0.75 * setting;

  static double mapHeatToSetting(double heat) {
    if (heat <= 0) return 0;
    return ((heat - 0.25) / 0.75).clamp(0.0, 1.0);
  }

  static _TeaKettleLayout get _layout {
    // teaKettle.png placement — TeaKettleNode.ts { right: 114, bottom: 53 }
    const kettleNativeW = 226.0;
    const kettleNativeH = 172.0;
    const kettleRight = 114.0;
    const kettleBottom = 53.0;
    final kettleLeft = kettleRight - kettleNativeW;
    final kettleTop = kettleBottom - kettleNativeH;

    // Burner stand size from model bounds (modelToViewDelta; Y inverted).
    final standW =
        (burnerModelBounds.right - burnerModelBounds.left) * _s;
    final standH =
        (burnerModelBounds.bottom - burnerModelBounds.top) * _s;
    final projection = standW * burnerEdgeToHeightRatio;
    final standPadTop = 3 * projection * math.sqrt1_2 / 2;
    final standPaintW = standW + projection;
    final standPaintH = standH + standPadTop;

    // PhET: burnerStand.centerTop = teaKettle.centerBottom + (0, -height/4)
    final kettleCenterX = kettleLeft + kettleNativeW / 2;
    final kettleCenterBottom = Offset(kettleCenterX, kettleBottom);
    final standCenterTop = Offset(
      kettleCenterBottom.dx,
      kettleCenterBottom.dy - kettleNativeH / 4,
    );
    final standPaintLeft = standCenterTop.dx - standPaintW / 2;
    final standPaintTop = standCenterTop.dy - standPadTop;

    // HeaterCooler: stoveWidth = 120 * 0.85; bottom nests in stand.
    final stoveW = EfacLayoutConstants.heaterCoolerDefaultWidth *
        heaterCoolerNodeScale;
    final openingH =
        stoveW * EfacLayoutConstants.heaterCoolerOpeningHeightScale;
    final bodyH = stoveW * 0.75;
    final heaterTotalH = bodyH + openingH + 8;
    final heaterLeft = standCenterTop.dx - stoveW / 2;
    // heaterCoolerBack.bottom = burnerStand.bottom - projection/2
    final standBottom = standPaintTop + standPaintH;
    final heaterBottom = standBottom - projection / 2;
    final heaterTop = heaterBottom - heaterTotalH;

    // Gas pipes scale 0.9 — TeaKettleNode.ts
    const longNativeW = 426.0, longNativeH = 14.0;
    const shortNativeW = 60.0, shortNativeH = 14.0;
    final longW = longNativeW * gasPipeScale;
    final longH = longNativeH * gasPipeScale;
    final shortW = shortNativeW * gasPipeScale;
    final shortH = shortNativeH * gasPipeScale;
    // leftGasPipe: right = heater.left - 30; bottom = heater.bottom - 20
    final longRight = heaterLeft - 30;
    final longLeft = longRight - longW;
    final longBottom = heaterBottom - 20;
    final longTop = longBottom - longH;
    final shortLeft = longRight - 1;
    final shortTop = longTop + (longH - shortH) / 2;

    // Steam from spout exit ≈ kettle maxX - 4.5, minY + 16
    final steamOrigin = Offset(kettleRight - 4.5, kettleTop + 16);
    const steamW = 80.0;
    const steamH = 100.0;

    final minX = math.min(longLeft, math.min(kettleLeft, heaterLeft));
    final minY = math.min(
      kettleTop - steamH * 0.3,
      math.min(standPaintTop, heaterTop),
    );
    final maxX = math.max(
      kettleRight,
      math.max(heaterLeft + stoveW, shortLeft + shortW),
    );
    final maxY = math.max(heaterBottom, standBottom);

    return _TeaKettleLayout(
      kettleLeft: kettleLeft,
      kettleTop: kettleTop,
      kettleW: kettleNativeW,
      kettleH: kettleNativeH,
      standPaintLeft: standPaintLeft,
      standPaintTop: standPaintTop,
      standPaintW: standPaintW,
      standPaintH: standPaintH,
      standW: standW,
      standH: standH,
      projection: projection,
      standPadTop: standPadTop,
      heaterLeft: heaterLeft,
      heaterTop: heaterTop,
      stoveW: stoveW,
      longLeft: longLeft,
      longTop: longTop,
      longW: longW,
      longH: longH,
      shortLeft: shortLeft,
      shortTop: shortTop,
      shortW: shortW,
      shortH: shortH,
      steamOrigin: steamOrigin,
      steamW: steamW,
      steamH: steamH,
      minX: minX,
      minY: minY,
      maxX: maxX,
      maxY: maxY,
    );
  }

  static Offset topLeftFromModelOrigin() {
    final L = _layout;
    return Offset(L.minX, L.minY);
  }

  @override
  Widget build(BuildContext context) {
    final L = _layout;
    final heat = model.teaKettleHeatProportion;
    final setting = mapHeatToSetting(heat);
    final kettleOpacity = model.energyChunksVisible ? 0.7 : 1.0;

    Widget at(double x, double y, Widget child) => Positioned(
          left: x - L.minX,
          top: y - L.minY,
          child: child,
        );

    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: L.maxX - L.minX,
        height: L.maxY - L.minY,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // HeaterCooler back opening first (z-order like PhET).
            at(
              L.heaterLeft,
              L.heaterTop,
              HeaterCoolerNode(
                value: setting,
                onChanged: (s) => model.setTeaKettleHeat(mapSettingToHeat(s)),
                stoveWidth: L.stoveW,
                snapToZero: false,
                coolEnabled: false,
                layer: HeaterCoolerPaintLayer.back,
              ),
            ),
            at(
              L.longLeft,
              L.longTop,
              Image.asset(
                EfacAssets.png('gasPipeSystemsLong'),
                width: L.longW,
                height: L.longH,
                fit: BoxFit.fill,
                gaplessPlayback: true,
              ),
            ),
            at(
              L.standPaintLeft,
              L.standPaintTop,
              Opacity(
                opacity: kettleOpacity,
                child: CustomPaint(
                  size: Size(L.standPaintW, L.standPaintH),
                  painter: _BurnerStandPainter(
                    projection: L.projection,
                    standW: L.standW,
                    padTop: L.standPadTop,
                  ),
                ),
              ),
            ),
            if (heat > 0.1)
              at(
                L.steamOrigin.dx - L.steamW * 0.2,
                L.steamOrigin.dy - L.steamH,
                Opacity(
                  opacity: kettleOpacity,
                  child: _SteamPuffs(
                    width: L.steamW,
                    height: L.steamH,
                    intensity: heat,
                  ),
                ),
              ),
            at(
              L.kettleLeft,
              L.kettleTop,
              Opacity(
                opacity: kettleOpacity,
                child: Image.asset(
                  EfacAssets.png('teaKettle'),
                  width: L.kettleW,
                  height: L.kettleH,
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                ),
              ),
            ),
            at(
              L.shortLeft,
              L.shortTop,
              Image.asset(
                EfacAssets.png('gasPipeSystemsShort'),
                width: L.shortW,
                height: L.shortH,
                fit: BoxFit.fill,
                gaplessPlayback: true,
              ),
            ),
            at(
              L.heaterLeft,
              L.heaterTop,
              HeaterCoolerNode(
                value: setting,
                onChanged: (s) => model.setTeaKettleHeat(mapSettingToHeat(s)),
                stoveWidth: L.stoveW,
                snapToZero: false,
                coolEnabled: false,
                layer: HeaterCoolerPaintLayer.front,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeaKettleLayout {
  const _TeaKettleLayout({
    required this.kettleLeft,
    required this.kettleTop,
    required this.kettleW,
    required this.kettleH,
    required this.standPaintLeft,
    required this.standPaintTop,
    required this.standPaintW,
    required this.standPaintH,
    required this.standW,
    required this.standH,
    required this.projection,
    required this.standPadTop,
    required this.heaterLeft,
    required this.heaterTop,
    required this.stoveW,
    required this.longLeft,
    required this.longTop,
    required this.longW,
    required this.longH,
    required this.shortLeft,
    required this.shortTop,
    required this.shortW,
    required this.shortH,
    required this.steamOrigin,
    required this.steamW,
    required this.steamH,
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
  });

  final double kettleLeft, kettleTop, kettleW, kettleH;
  final double standPaintLeft, standPaintTop, standPaintW, standPaintH;
  final double standW, standH, projection, standPadTop;
  final double heaterLeft, heaterTop, stoveW;
  final double longLeft, longTop, longW, longH;
  final double shortLeft, shortTop, shortW, shortH;
  final Offset steamOrigin;
  final double steamW, steamH;
  final double minX, minY, maxX, maxY;
}

/// Port of intro `_BurnerStandPainter` / PhET `BurnerStandNode.ts`.
class _BurnerStandPainter extends CustomPainter {
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
    final leftTop = Offset(e / 2, padTop);
    final rightTop = Offset(e / 2 + standW, padTop);

    canvas.drawPath(_side(leftTop, h, e), paint);
    canvas.drawPath(_side(rightTop, h, e), paint);
    canvas.drawPath(_top(leftTop, standW, e), paint);
  }

  @override
  bool shouldRepaint(covariant _BurnerStandPainter old) =>
      old.projection != projection ||
      old.standW != standW ||
      old.padTop != padTop;
}

/// Simple rising steam puffs when heat > 0.1.
class _SteamPuffs extends StatelessWidget {
  const _SteamPuffs({
    required this.width,
    required this.height,
    required this.intensity,
  });

  final double width;
  final double height;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final a = (0.25 + 0.55 * intensity).clamp(0.0, 0.85);
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SteamPainter(alpha: a),
      ),
    );
  }
}

class _SteamPainter extends CustomPainter {
  _SteamPainter({required this.alpha});
  final double alpha;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: alpha);
    final cx = size.width * 0.35;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, size.height * 0.75),
        width: 18,
        height: 12,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 10, size.height * 0.5),
        width: 22,
        height: 14,
      ),
      paint..color = Colors.white.withValues(alpha: alpha * 0.85),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 4, size.height * 0.28),
        width: 16,
        height: 11,
      ),
      paint..color = Colors.white.withValues(alpha: alpha * 0.65),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 16, size.height * 0.12),
        width: 14,
        height: 10,
      ),
      paint..color = Colors.white.withValues(alpha: alpha * 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant _SteamPainter old) => old.alpha != alpha;
}
