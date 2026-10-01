import 'package:flutter/material.dart';

import '../../model/box_type.dart';
import '../../model/challenge.dart';
import '../../model/game_enums.dart';
import '../../rpal_colors.dart';
import '../../rpal_constants.dart';
import '../../rpal_strings.dart';
import '../game_controller.dart';
import 'face_with_points.dart';
import 'game_buttons.dart';
import 'game_quantities_node.dart';
import 'game_random_box.dart';
import 'molecules_equation_node.dart';

/// One challenge view — `ChallengeNode.ts`.
class ChallengeNode extends StatelessWidget {
  const ChallengeNode({
    super.key,
    required this.controller,
    required this.challenge,
  });

  final GameController controller;
  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final model = controller.model;
    final reaction = challenge.reaction;
    final guess = challenge.guess;
    final interactiveBox = challenge.interactiveBox;
    final playState = model.playState;

    final reactants =
        interactiveBox == BoxType.before ? guess.reactants : reaction.reactants;
    final products =
        interactiveBox == BoxType.after ? guess.products : reaction.products;
    final leftovers =
        interactiveBox == BoxType.after ? guess.leftovers : reaction.leftovers;

    final interactive = playState.isInteractive;
    final showQuestion = interactive && !model.checkEnabled;
    final hideMolecules =
        playState != PlayState.next && !challenge.moleculesVisible;
    final hideNumbers =
        playState != PlayState.next && !challenge.numbersVisible;

    var faceVisible = false;
    var smile = true;
    var facePoints = 0;
    if (playState == PlayState.tryAgain || playState == PlayState.showAnswer) {
      faceVisible = true;
      smile = false;
      facePoints = 0;
    } else if (playState == PlayState.next && challenge.points > 0) {
      faceVisible = true;
      smile = true;
      facePoints = challenge.points;
    }

    const boxW = RpalConstants.gameBoxWidth;
    const boxH = RpalConstants.gameBoxHeight;
    const arrowGap = 50.0;
    final afterBoxX = boxW + arrowGap;

    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(3),
          ),
          child: MoleculesEquationNode(
            reaction: reaction,
            fill: Colors.black,
            fontSize: 26,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: afterBoxX + boxW,
          height: boxH,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    RandomBox(
                      substances: reactants,
                      seed: challenge.hashCode ^ 1,
                      visible: !(hideMolecules &&
                          interactiveBox == BoxType.after),
                    ),
                    if (hideMolecules && interactiveBox == BoxType.after)
                      _HideOverlay(width: boxW, height: boxH),
                    if (interactiveBox == BoxType.before) ...[
                      if (showQuestion)
                        const Text(
                          RpalStrings.questionMark,
                          style: TextStyle(
                            fontSize: 120,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Arial',
                          ),
                        ),
                      FaceWithPoints(
                        visible: faceVisible && interactiveBox == BoxType.before,
                        smile: smile,
                        points: facePoints,
                      ),
                      Positioned(
                        bottom: 15,
                        child: GameButtons(
                          controller: controller,
                          checkEnabled: model.checkEnabled,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                left: boxW + 8,
                top: boxH / 2 - 12,
                child: CustomPaint(
                  size: const Size(34, 24),
                  painter: const _ArrowPainter(),
                ),
              ),
              Positioned(
                left: afterBoxX,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    RandomBox(
                      substances: [...products, ...leftovers],
                      seed: challenge.hashCode ^ 2,
                      visible: !(hideMolecules &&
                          interactiveBox == BoxType.before),
                    ),
                    if (hideMolecules && interactiveBox == BoxType.before)
                      _HideOverlay(width: boxW, height: boxH),
                    if (interactiveBox == BoxType.after) ...[
                      if (showQuestion)
                        const Text(
                          RpalStrings.questionMark,
                          style: TextStyle(
                            fontSize: 120,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Arial',
                          ),
                        ),
                      FaceWithPoints(
                        visible: faceVisible && interactiveBox == BoxType.after,
                        smile: smile,
                        points: facePoints,
                      ),
                      Positioned(
                        bottom: 15,
                        child: GameButtons(
                          controller: controller,
                          checkEnabled: model.checkEnabled,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        GameQuantitiesNode(
          controller: controller,
          reactants: reactants,
          products: products,
          leftovers: leftovers,
          interactiveBox: interactiveBox,
          interactive: interactive,
          hideNumbers: hideNumbers,
          afterBoxXOffset: afterBoxX,
        ),
      ],
    );
  }
}

class _HideOverlay extends StatelessWidget {
  const _HideOverlay({required this.width, required this.height});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        border: Border.all(color: RpalColors.boxStroke, width: 2),
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size(height * 0.45, height * 0.35),
        painter: const _HideEyePainter(),
      ),
    );
  }
}

/// HideBox eye-slash (scenery-phet style, no Material icons).
class _HideEyePainter extends CustomPainter {
  const _HideEyePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = const Color(0xFF666666)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = const Color(0xFF888888);
    final c = Offset(size.width / 2, size.height / 2);
    final eye = Path()
      ..moveTo(4, c.dy)
      ..quadraticBezierTo(c.dx, 2, size.width - 4, c.dy)
      ..quadraticBezierTo(c.dx, size.height - 2, 4, c.dy)
      ..close();
    canvas.drawPath(eye, fill);
    canvas.drawCircle(c, size.height * 0.18, Paint()..color = Colors.white);
    canvas.drawLine(
      Offset(6, size.height - 4),
      Offset(size.width - 6, 4),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.35)
      ..lineTo(size.width * 0.55, size.height * 0.35)
      ..lineTo(size.width * 0.55, size.height * 0.15)
      ..lineTo(size.width, size.height * 0.5)
      ..lineTo(size.width * 0.55, size.height * 0.85)
      ..lineTo(size.width * 0.55, size.height * 0.65)
      ..lineTo(0, size.height * 0.65)
      ..close();
    canvas.drawPath(path, Paint()..color = RpalColors.statusBarFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
