import 'package:flutter/material.dart';

import '../../balancing_act/view/widgets/ba_styled_svg.dart';

/// Load PhET asset: SVG via CSS-inlined flutter_svg, raster via Image.
class FambPicture extends StatelessWidget {
  const FambPicture(
    this.assetPath, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;

  bool get _isSvg => assetPath.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    if (_isSvg) {
      return BaSvgPicture.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
      );
    }
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      alignment:
          alignment is Alignment ? alignment as Alignment : Alignment.center,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, error, stack) => SizedBox(
        width: width,
        height: height,
        child: const ColoredBox(color: Color(0x33FF0000)),
      ),
    );
  }
}
