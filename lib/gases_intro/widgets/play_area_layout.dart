import 'dart:ui' show Rect, Size;

import '../gases_intro_constants.dart';
import '../render/render_data.dart';
import '../view/gases_intro_mvt.dart';

/// Shared model↔view mapping for Ideal play area.
///
/// V5: MVT scaled uniformly by [layoutScale] so physical coords match the
/// fitted shell size. Anchor **rules** unchanged from V2.
class PlayAreaLayout {
  PlayAreaLayout(this.size, {double? layoutScale}) {
    final s = layoutScale ??
        (size.width / GasesIntroConstants.layoutWidth);
    this.layoutScale = s;
    scale = GasesIntroMvt.scale * s;
    originX = GasesIntroMvt.originX * s;
    originY = GasesIntroMvt.originY * s;
  }

  final Size size;
  late final double layoutScale;
  late final double scale;
  late final double originX;
  late final double originY;

  double vx(double mx) => originX + mx * scale;
  double vy(double my) => originY - my * scale;
  double vs(double pm) => pm * scale;

  double mx(double viewX) => (viewX - originX) / scale;
  double my(double viewY) => (originY - viewY) / scale;

  Rect containerRect(RenderData data) {
    return Rect.fromLTRB(
      vx(data.containerLeft),
      vy(data.containerTop),
      vx(data.containerRight),
      vy(data.containerBottom),
    );
  }

  Rect leftHandleHit(RenderData data) {
    final left = vx(data.containerLeft);
    final top = vy(data.containerTop);
    final bottom = vy(data.containerBottom);
    return Rect.fromLTRB(left - 28 * layoutScale, top, left + 8 * layoutScale, bottom);
  }
}

Size get idealLayoutSize => const Size(
      GasesIntroConstants.layoutWidth,
      GasesIntroConstants.layoutHeight,
    );
