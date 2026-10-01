import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kratos/energy_forms_and_changes/efac_assets.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';
import 'package:kratos/energy_forms_and_changes/efac_layout_constants.dart';

/// PhET `SolarPanelNode` — local origin = model position.
///
/// Evidence `SolarPanelNode.ts` + `SolarPanel.ts`:
/// - panel scaled to PANEL_SIZE (0.15×0.07 m) via systems MVT
/// - post / gen window / wireBottomLeft / connector relative to panel
class SolarPanelNode extends StatelessWidget {
  const SolarPanelNode({
    super.key,
    required this.opacity,
  });

  final double opacity;

  static const double _s = EfacConstants.systemsMvtScaleFactor;

  /// View layout in local coords (Y down, origin = model position).
  static _SolarPanelLayout get _layout {
    final panelW = EfacLayoutConstants.solarPanelModelSize.width * _s;
    final panelH = EfacLayoutConstants.solarPanelModelSize.height * _s;
    // scaleOnlyMVT inverted-Y: panel center at (0, -height/2)
    final panelCenter = Offset(0, -panelH / 2);
    final panelLeft = panelCenter.dx - panelW / 2;
    final panelTop = panelCenter.dy - panelH / 2;
    final panelBottom = panelTop + panelH;

    final postW = EfacLayoutConstants.solarPanelPostNative.width.toDouble();
    final postH = EfacLayoutConstants.solarPanelPostNative.height.toDouble();
    final postCenterX =
        EfacLayoutConstants.solarPanelConnectorOffset.dx * _s;
    final postTop = panelBottom - 5;
    final postLeft = postCenterX - postW / 2;

    final genW = EfacLayoutConstants.solarPanelGenNative.width.toDouble();
    final genH = EfacLayoutConstants.solarPanelGenNative.height.toDouble();
    final genTop = postTop + postH / 2; // post.centerY
    final genLeft = postCenterX - genW / 2;
    final genRight = genLeft + genW;
    final genCenterY = genTop + genH / 2;

    final wireScale = EfacLayoutConstants.wireImageScale;
    final wireW = EfacLayoutConstants.wireBottomLeftNative.width * wireScale;
    final wireH = EfacLayoutConstants.wireBottomLeftNative.height * wireScale;
    final wireRight = genRight - 20;
    final wireBottom = genCenterY + 13;
    final wireLeft = wireRight - wireW;
    final wireTop = wireBottom - wireH;

    final connW = EfacLayoutConstants.connectorNative.width.toDouble();
    final connH = EfacLayoutConstants.connectorNative.height.toDouble();
    final connLeft = genRight - 2;
    final connTop = genCenterY - connH / 2;

    final minX = [panelLeft, postLeft, genLeft, wireLeft, connLeft]
        .reduce(math.min);
    final minY = [panelTop, postTop, genTop, wireTop, connTop].reduce(math.min);
    final maxX = [panelLeft + panelW, postLeft + postW, genRight, connLeft + connW]
        .reduce(math.max);
    final maxY = [
      panelBottom,
      postTop + postH,
      genTop + genH,
      wireBottom,
      connTop + connH,
    ].reduce(math.max);

    return _SolarPanelLayout(
      panelLeft: panelLeft,
      panelTop: panelTop,
      panelW: panelW,
      panelH: panelH,
      postLeft: postLeft,
      postTop: postTop,
      postW: postW,
      postH: postH,
      genLeft: genLeft,
      genTop: genTop,
      genW: genW,
      genH: genH,
      wireLeft: wireLeft,
      wireTop: wireTop,
      wireW: wireW,
      wireH: wireH,
      connLeft: connLeft,
      connTop: connTop,
      connW: connW,
      connH: connH,
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
            // Layer order: wire → post → panel → gen window → connector
            at(
              L.wireLeft,
              L.wireTop,
              Image.asset(
                EfacAssets.png('wireBottomLeft'),
                width: L.wireW,
                height: L.wireH,
                fit: BoxFit.fill,
                gaplessPlayback: true,
              ),
            ),
            at(
              L.postLeft,
              L.postTop,
              Image.asset(
                EfacAssets.png('solarPanelPost'),
                width: L.postW,
                height: L.postH,
                fit: BoxFit.fill,
                gaplessPlayback: true,
              ),
            ),
            at(
              L.panelLeft,
              L.panelTop,
              Image.asset(
                EfacAssets.png('solarPanel'),
                width: L.panelW,
                height: L.panelH,
                fit: BoxFit.fill,
                gaplessPlayback: true,
              ),
            ),
            at(
              L.genLeft,
              L.genTop,
              Image.asset(
                EfacAssets.png('solarPanelGen'),
                width: L.genW,
                height: L.genH,
                fit: BoxFit.fill,
                gaplessPlayback: true,
              ),
            ),
            at(
              L.connLeft,
              L.connTop,
              Image.asset(
                EfacAssets.png('connector'),
                width: L.connW,
                height: L.connH,
                fit: BoxFit.fill,
                gaplessPlayback: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SolarPanelLayout {
  const _SolarPanelLayout({
    required this.panelLeft,
    required this.panelTop,
    required this.panelW,
    required this.panelH,
    required this.postLeft,
    required this.postTop,
    required this.postW,
    required this.postH,
    required this.genLeft,
    required this.genTop,
    required this.genW,
    required this.genH,
    required this.wireLeft,
    required this.wireTop,
    required this.wireW,
    required this.wireH,
    required this.connLeft,
    required this.connTop,
    required this.connW,
    required this.connH,
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
  });

  final double panelLeft, panelTop, panelW, panelH;
  final double postLeft, postTop, postW, postH;
  final double genLeft, genTop, genW, genH;
  final double wireLeft, wireTop, wireW, wireH;
  final double connLeft, connTop, connW, connH;
  final double minX, minY, maxX, maxY;
}
