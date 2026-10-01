import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../friction_constants.dart';
import '../../friction_strings.dart';

/// Port of PhET `CoverNode.js` — procedural 3D book cover (no PNG assets).
class BookCoverPainter extends CustomPainter {
  BookCoverPainter({
    required this.title,
    required this.color,
    this.strokeColor = Colors.grey,
  });

  final String title;
  final Color color;
  final Color strokeColor;

  static const double bindingLength = FrictionConstants.bindingLength;
  static const double bindingWidth = FrictionConstants.bindingWidth;
  static const double round = FrictionConstants.coverRound;
  static const int pages = FrictionConstants.coverPages;
  static const double bookCoverWidth = FrictionConstants.bookCoverWidth;
  static const double angle = FrictionConstants.coverAngle;

  /// Intrinsic size matching CoverNode bounds.
  static Size get intrinsicSize {
    final w = bindingLength + math.cos(angle) * bookCoverWidth + 2;
    final h = bindingWidth + math.sin(angle) * bookCoverWidth + 4;
    return Size(w, h);
  }

  /// Y offset so top cover edge sits at y=0 of the widget.
  static double get topExtent => math.sin(angle) * bookCoverWidth + 1;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(0, topExtent);

    final fill = Paint()..color = color;
    final stroke = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final whiteFill = Paint()..color = Colors.white;
    final pageStroke = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final pageBg = Path()
      ..moveTo(bindingLength, 0)
      ..lineTo(
        bindingLength + math.cos(angle) * bookCoverWidth,
        -math.sin(angle) * bookCoverWidth,
      )
      ..lineTo(
        bindingLength + math.cos(angle) * bookCoverWidth,
        bindingWidth - math.sin(angle) * bookCoverWidth,
      )
      ..lineTo(bindingLength, bindingWidth - 1)
      ..close();
    canvas.drawPath(pageBg, whiteFill);

    final rightSideOfSpine =
        bindingLength - round / 2 + math.cos(angle) * bookCoverWidth;

    canvas.drawLine(
      Offset(bindingLength - round / 2, bindingWidth),
      Offset(rightSideOfSpine, bindingWidth - math.sin(angle) * bookCoverWidth),
      stroke,
    );

    final front = Path()
      ..moveTo(round / 2, 0)
      ..lineTo(
        round / 2 + math.cos(angle) * bookCoverWidth,
        -math.sin(angle) * bookCoverWidth,
      )
      ..lineTo(rightSideOfSpine, -math.sin(angle) * bookCoverWidth)
      ..lineTo(bindingLength - round / 2, 0)
      ..close();
    canvas.drawPath(front, fill);
    canvas.drawPath(front, stroke);

    final binding = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, bindingLength, bindingWidth),
      const Radius.circular(round),
    );
    canvas.drawRRect(binding, fill);
    canvas.drawRRect(binding, stroke);

    final dy = (bindingWidth - round) / pages;
    const dl = bookCoverWidth / 5;
    const offset = 5.0;
    for (var i = 0; i < pages; i++) {
      final amplitude = bookCoverWidth -
          offset +
          dl * (math.pow(0.5 - i / pages, 2) - 0.25);
      final x2 = bindingLength + round / 2 + math.cos(angle) * amplitude;
      final y2 = round / 2 + dy * i - math.sin(angle) * amplitude;
      canvas.drawLine(
        Offset(bindingLength + round / 2, round / 2 + dy * i),
        Offset(x2, y2),
        pageStroke,
      );
    }

    final tp = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          fontSize: FrictionConstants.bookTitleFontSize,
          color: FrictionConstants.bookTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: bindingLength * 0.97);
    tp.paint(
      canvas,
      Offset(
        (bindingLength - tp.width) / 2,
        (bindingWidth - tp.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant BookCoverPainter oldDelegate) =>
      oldDelegate.title != title ||
      oldDelegate.color != color ||
      oldDelegate.strokeColor != strokeColor;
}

class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.title,
    required this.color,
  });

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final size = BookCoverPainter.intrinsicSize;
    return CustomPaint(
      size: size,
      painter: BookCoverPainter(title: title, color: color),
    );
  }
}

class ChemistryBookCover extends StatelessWidget {
  const ChemistryBookCover({super.key});

  @override
  Widget build(BuildContext context) => const BookCover(
        title: FrictionStrings.chemistry,
        color: FrictionConstants.topBookColorMacro,
      );
}

class PhysicsBookCover extends StatelessWidget {
  const PhysicsBookCover({super.key});

  @override
  Widget build(BuildContext context) => const BookCover(
        title: FrictionStrings.physics,
        color: FrictionConstants.bottomBookColorMacro,
      );
}
