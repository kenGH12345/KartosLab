/// Yellow "Return Objects" button when bodies leave the view or collide.
library;

import 'package:flutter/material.dart';

import '../controller/gao_controller.dart';
import '../gao_colors.dart';
import '../gao_strings.dart';

class ReturnObjectsButton extends StatelessWidget {
  const ReturnObjectsButton({super.key, required this.controller});

  final GaoController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.bodiesAreReturnable) return const SizedBox.shrink();
    return Material(
      color: GaoColors.returnObjectsBg,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: controller.returnObjects,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            GaoStrings.returnObjects,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
