// Copyright 2024-2026, University of Colorado Boulder
/// Section header with bottom border (SceneSectionHeader.ts).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

class SceneSectionHeader extends StatelessWidget {
  const SceneSectionHeader({
    super.key,
    required this.title,
    this.textColor = Colors.black,
    this.maxWidth,
  });

  final String title;
  final Color textColor;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final available =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 280.0;
        final lineWidth =
            maxWidth != null ? math.min(maxWidth!, available) : available;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: lineWidth),
              child: text,
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              width: lineWidth,
              color: Colors.black,
            ),
          ],
        );
      },
    );
  }
}
