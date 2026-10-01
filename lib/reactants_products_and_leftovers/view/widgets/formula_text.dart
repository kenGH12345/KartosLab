import 'package:flutter/material.dart';

/// Renders PhET HTML-ish symbols like `H<sub>2</sub>O` with true subscripts.
class FormulaText extends StatelessWidget {
  const FormulaText({
    super.key,
    required this.symbolHtml,
    this.fontSize = 28,
    this.color = Colors.white,
    this.fontFamily = 'Arial',
  });

  final String symbolHtml;
  final double fontSize;
  final Color color;
  final String? fontFamily;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: _parse(symbolHtml)),
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      ),
    );
  }

  List<InlineSpan> _parse(String html) {
    final spans = <InlineSpan>[];
    final re = RegExp(r'<sub>(.*?)</sub>');
    var index = 0;
    for (final match in re.allMatches(html)) {
      if (match.start > index) {
        spans.add(TextSpan(
          text: html.substring(index, match.start),
          style: _baseStyle,
        ));
      }
      final sub = match.group(1) ?? '';
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: Transform.translate(
          offset: Offset(0, fontSize * 0.22),
          child: Text(
            sub,
            style: _baseStyle.copyWith(fontSize: fontSize * 0.65, height: 1),
          ),
        ),
      ));
      index = match.end;
    }
    if (index < html.length) {
      spans.add(TextSpan(text: html.substring(index), style: _baseStyle));
    }
    if (spans.isEmpty) {
      spans.add(TextSpan(text: html, style: _baseStyle));
    }
    return spans;
  }

  TextStyle get _baseStyle => TextStyle(
        fontSize: fontSize,
        color: color,
        fontFamily: fontFamily,
        height: 1.1,
      );
}
