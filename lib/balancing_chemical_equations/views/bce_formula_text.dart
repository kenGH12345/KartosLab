import 'package:flutter/material.dart';

/// Renders PhET RichText HTML fragments (`H<sub>2</sub>O`, □ coeffs, arrows).
class BceFormulaText extends StatelessWidget {
  const BceFormulaText({
    super.key,
    required this.html,
    this.fontSize = 16,
    this.textAlign = TextAlign.center,
    this.color,
  });

  final String html;
  final double fontSize;
  final TextAlign textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    final re = RegExp(r'<sub>(.*?)</sub>|([^<]+)');
    final baseColor = color ?? Colors.black;
    for (final m in re.allMatches(html)) {
      if (m.group(1) != null) {
        spans.add(TextSpan(
          text: m.group(1),
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: fontSize * 0.65,
            height: 1,
            color: baseColor,
          ),
        ));
      } else if (m.group(2) != null) {
        spans.add(TextSpan(
          text: m.group(2),
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: fontSize,
            height: 1,
            color: baseColor,
          ),
        ));
      }
    }
    return Text.rich(
      TextSpan(children: spans),
      textAlign: textAlign,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
