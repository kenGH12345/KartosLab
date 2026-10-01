/// Positioned body sprites via original PNG assets (not CustomPainter redraw).
library;

import 'package:flutter/material.dart';

import '../gao_assets.dart';
import '../gao_colors.dart';
import '../gao_strings.dart';
import '../model/body_type.dart';
import '../model/gao_body.dart';
import '../render/gao_mvt.dart';

typedef GaoBodyDragStart = void Function(GaoBody body);
typedef GaoBodyDragUpdate = void Function(GaoBody body, Offset viewDelta);
typedef GaoBodyDragEnd = void Function(GaoBody body);

class GaoBodiesLayer extends StatelessWidget {
  const GaoBodiesLayer({
    super.key,
    required this.bodies,
    required this.mvt,
    required this.showMass,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  });

  final List<GaoBody> bodies;
  final GaoMvt mvt;
  final bool showMass;
  final GaoBodyDragStart? onDragStart;
  final GaoBodyDragUpdate? onDragUpdate;
  final GaoBodyDragEnd? onDragEnd;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final body in bodies)
          if (!body.isCollided) _bodyWidget(body),
      ],
    );
  }

  Widget _bodyWidget(GaoBody body) {
    final center = mvt.modelToView(body.position);
    final diameterPx =
        mvt.modelDeltaToViewDelta(body.diameter).abs().clamp(8.0, 400.0);
    final hit = diameterPx + body.touchDilation * 2;
    final label = _massLabel(body);

    return Positioned(
      left: center.dx - hit / 2,
      top: center.dy - hit / 2,
      width: hit,
      height: hit,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: body.isMovable && onDragStart != null
            ? (_) => onDragStart!(body)
            : null,
        onPanUpdate: body.isMovable && onDragUpdate != null
            ? (d) => onDragUpdate!(body, d.delta)
            : null,
        onPanEnd: body.isMovable && onDragEnd != null
            ? (_) => onDragEnd!(body)
            : null,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: diameterPx,
              height: diameterPx,
              child: Image.asset(
                GaoAssets.bodyImage(body),
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
              ),
            ),
            if (showMass && label != null)
              Positioned(
                top: body.massReadoutBelow ? diameterPx / 2 + 4 : null,
                bottom: body.massReadoutBelow ? null : diameterPx / 2 + 4,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: GaoColors.foreground,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String? _massLabel(GaoBody body) {
    final name = body.tickLabel.isNotEmpty
        ? body.tickLabel
        : GaoAssets.labelFor(body.type);
    final ratio = body.mass / body.tickMass;
    if ((ratio - 1).abs() < 1e-6) return name;
    return '${ratio.toStringAsFixed(2)}× $name';
  }
}

/// Hit-test helper for velocity vector tips (view space).
class GaoVelocityTipHit {
  GaoVelocityTipHit({required this.body, required this.tipView});

  final GaoBody body;
  final Offset tipView;
}

List<GaoVelocityTipHit> velocityTips({
  required List<GaoBody> bodies,
  required GaoMvt mvt,
  required double velocityVectorScale,
}) {
  return [
    for (final body in bodies)
      if (!body.isCollided)
        GaoVelocityTipHit(
          body: body,
          tipView: mvt.modelToView(
            body.position + body.velocity * velocityVectorScale,
          ),
        ),
  ];
}

/// Mass title for slider panel.
String massControlTitle(GaoBodyType type) {
  switch (type) {
    case GaoBodyType.star:
      return GaoStrings.starMass;
    case GaoBodyType.planet:
      return GaoStrings.planetMass;
    case GaoBodyType.moon:
      return GaoStrings.moonMass;
    case GaoBodyType.satellite:
      return GaoStrings.satelliteMass;
  }
}
