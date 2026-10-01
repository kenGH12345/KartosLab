import 'package:flutter/material.dart';
import 'package:kratos/hookes_law/view/phet_font.dart';

/// PhET-aligned text: Arial + `height:1` + no extra ascent/descent padding.
///
/// Source: scenery-phet `PhetFont` (height defaults to 1 in Scenery Text).
class BaText extends StatelessWidget {
  const BaText(
    this.data, {
    super.key,
    required this.size,
    this.color = const Color(0xFF000000),
    this.fontWeight = FontWeight.normal,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String data;
  final double size;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  static const TextHeightBehavior baseline = TextHeightBehavior(
    applyHeightToFirstAscent: false,
    applyHeightToLastDescent: false,
  );

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      textHeightBehavior: baseline,
      style: PhetFont.of(size, color: color, fontWeight: fontWeight),
    );
  }
}
