import 'package:flutter/material.dart';

import '../model/equation.dart';
import '../views/balance_scales_node.dart';
import '../views/bar_charts_node.dart';
import 'game_level.dart';
import 'game_model.dart';
import 'game_state.dart';
import 'package:kratos/balancing_chemical_equations/bce_strings.dart';

/// PhET `GameFeedbackNode` — three mutually exclusive panels.
class GameFeedbackNode extends StatelessWidget {
  const GameFeedbackNode({super.key, required this.model});

  final GameModel model;

  @override
  Widget build(BuildContext context) {
    if (!model.feedbackVisible) return const SizedBox.shrink();
    final eq = model.challenge;
    if (eq.isSimplified) {
      return _BalancedAndSimplifiedPanel(
        points: model.points,
        onNext: model.next,
      );
    }
    if (eq.isBalanced) {
      return _BalancedNotSimplifiedPanel(
        gameState: model.gameState,
        onTryAgain: model.tryAgain,
        onShowAnswer: model.showAnswer,
      );
    }
    return _NotBalancedPanel(
      model: model,
      equation: eq,
    );
  }
}

class _YellowButton extends StatelessWidget {
  const _YellowButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFFF00),
      borderRadius: BorderRadius.circular(6),
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _Face extends StatelessWidget {
  const _Face({required this.smile});
  final bool smile;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(60, 60),
      painter: _FacePainter(smile: smile),
    );
  }
}

class _FacePainter extends CustomPainter {
  _FacePainter({required this.smile});
  final bool smile;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 1;
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFFFFEE58));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.black,
    );
    canvas.drawCircle(Offset(c.dx - r * 0.35, c.dy - r * 0.15), 3, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(c.dx + r * 0.35, c.dy - r * 0.15), 3, Paint()..color = Colors.black);
    final mouth = Path();
    if (smile) {
      mouth.addArc(
        Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.1), width: r, height: r * 0.7),
        0.2,
        2.7,
      );
    } else {
      mouth.addArc(
        Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.45), width: r, height: r * 0.7),
        3.5,
        2.5,
      );
    }
    canvas.drawPath(
      mouth,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.black,
    );
  }

  @override
  bool shouldRepaint(covariant _FacePainter old) => old.smile != smile;
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.ok, required this.label});
  final bool ok;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(16, 16),
          painter: ok ? _CheckPainter() : _TimesPainter(),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontFamily: 'Arial', fontSize: 18)),
      ],
    );
  }
}

class _CheckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.55)
      ..lineTo(size.width * 0.4, size.height * 0.8)
      ..lineTo(size.width * 0.85, size.height * 0.2);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color.fromRGBO(0, 180, 0, 1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TimesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE50000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width * 0.2, size.height * 0.2),
        Offset(size.width * 0.8, size.height * 0.8), paint);
    canvas.drawLine(Offset(size.width * 0.8, size.height * 0.2),
        Offset(size.width * 0.2, size.height * 0.8), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PanelChrome extends StatelessWidget {
  const _PanelChrome({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFC1D8FE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black54),
      ),
      child: child,
    );
  }
}

class _BalancedAndSimplifiedPanel extends StatelessWidget {
  const _BalancedAndSimplifiedPanel({
    required this.points,
    required this.onNext,
  });
  final int points;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _PanelChrome(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _Face(smile: true),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _StatusLine(ok: true, label: BceStrings.balanced),
                  const SizedBox(height: 6),
                  const _StatusLine(ok: true, label: BceStrings.simplified),
                  const SizedBox(height: 8),
                  Text(
                    '+$points',
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF008000),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _YellowButton(label: BceStrings.next, onPressed: onNext),
        ],
      ),
    );
  }
}

class _BalancedNotSimplifiedPanel extends StatelessWidget {
  const _BalancedNotSimplifiedPanel({
    required this.gameState,
    required this.onTryAgain,
    required this.onShowAnswer,
  });
  final GameState gameState;
  final VoidCallback onTryAgain;
  final VoidCallback onShowAnswer;

  @override
  Widget build(BuildContext context) {
    return _PanelChrome(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Face(smile: true),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusLine(ok: true, label: BceStrings.balanced),
                  SizedBox(height: 6),
                  _StatusLine(ok: false, label: BceStrings.notSimplified),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (gameState == GameState.tryAgain)
                _YellowButton(label: BceStrings.tryAgain, onPressed: onTryAgain),
              if (gameState == GameState.showAnswer)
                _YellowButton(label: BceStrings.showAnswer, onPressed: onShowAnswer),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotBalancedPanel extends StatelessWidget {
  const _NotBalancedPanel({required this.model, required this.equation});
  final GameModel model;
  final Equation equation;

  @override
  Widget build(BuildContext context) {
    final viewMode = model.level?.getViewMode() ?? ShowWhyViewMode.balanceScales;
    return _PanelChrome(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Face(smile: false),
              SizedBox(width: 10),
              _StatusLine(ok: false, label: BceStrings.notBalanced),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (model.gameState == GameState.tryAgain)
                _YellowButton(label: BceStrings.tryAgain, onPressed: model.tryAgain),
              if (model.gameState == GameState.showAnswer)
                _YellowButton(label: BceStrings.showAnswer, onPressed: model.showAnswer),
            ],
          ),
          const SizedBox(height: 8),
          _YellowButton(
            label: model.showWhy ? '隐藏原因' : '显示原因',
            onPressed: model.toggleShowWhy,
          ),
          if (model.showWhy) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: 220,
              height: 160,
              child: FittedBox(
                fit: BoxFit.contain,
                child: viewMode == ShowWhyViewMode.balanceScales
                    ? BalanceScalesNode(equation: equation)
                    : BarChartsNode(equation: equation),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
