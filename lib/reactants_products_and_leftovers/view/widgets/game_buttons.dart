import 'package:flutter/material.dart';

import '../../model/game_enums.dart';
import '../../rpal_strings.dart';
import '../game_controller.dart';

/// Check / Try Again / Show Answer / Next — `GameButtons.ts`.
class GameButtons extends StatelessWidget {
  const GameButtons({
    super.key,
    required this.controller,
    required this.checkEnabled,
  });

  final GameController controller;
  final bool checkEnabled;

  @override
  Widget build(BuildContext context) {
    final state = controller.model.playState;
    String? label;
    VoidCallback? onPressed;
    var enabled = true;

    switch (state) {
      case PlayState.firstCheck:
      case PlayState.secondCheck:
        label = RpalStrings.check;
        onPressed = controller.check;
        enabled = checkEnabled;
      case PlayState.tryAgain:
        label = RpalStrings.tryAgain;
        onPressed = controller.tryAgain;
      case PlayState.showAnswer:
        label = RpalStrings.showAnswer;
        onPressed = controller.showAnswer;
      case PlayState.next:
        label = RpalStrings.next;
        onPressed = controller.next;
      case PlayState.none:
        return const SizedBox.shrink();
    }

    return Opacity(
      opacity: 0.9,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF2E96B),
          foregroundColor: Colors.black,
          disabledBackgroundColor: const Color(0xFFE0E0E0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
