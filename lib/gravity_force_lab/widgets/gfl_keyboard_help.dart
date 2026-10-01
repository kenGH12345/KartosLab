import 'package:flutter/material.dart';

import '../a11y/gfl_a11y_strings.dart';

/// PhET `GravityForceLabKeyboardHelpContent` (Full, not Basics).
class GflKeyboardHelpDialog extends StatelessWidget {
  const GflKeyboardHelpDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => const GflKeyboardHelpDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(GflA11yStrings.keyboardHelp),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Section(
                heading: GflA11yStrings.moveSpheresHeading,
                rows: const [
                  _Row(GflA11yStrings.moveSphereLabel, '← →'),
                  _Row(GflA11yStrings.moveInSmallerSteps, 'Shift + ← →'),
                  _Row(GflA11yStrings.moveInLargerSteps, 'Page Up / Page Down'),
                  _Row(GflA11yStrings.jumpToLeft, 'Home'),
                  _Row(GflA11yStrings.jumpToRight, 'End'),
                ],
              ),
              _Section(
                heading: GflA11yStrings.changeMassHeading,
                rows: const [
                  _Row(GflA11yStrings.changeMassLabel, '← →'),
                  _Row(GflA11yStrings.changeMassInSmallerSteps, 'Shift + ← →'),
                  _Row(
                    GflA11yStrings.changeMassInLargerSteps,
                    'Page Up / Page Down',
                  ),
                  _Row(GflA11yStrings.jumpToMinimumMass, 'Home'),
                  _Row(GflA11yStrings.jumpToMaximumMass, 'End'),
                ],
              ),
              _Section(
                heading: GflA11yStrings.grabReleaseRulerHeading,
                rows: const [
                  _Row('Grab or release ruler', 'Enter / Space'),
                ],
              ),
              _Section(
                heading: GflA11yStrings.moveOrJumpGrabbedRuler,
                rows: const [
                  _Row(GflA11yStrings.moveGrabbedRuler, 'Arrows or WASD'),
                  _Row(GflA11yStrings.moveInSmallerSteps, 'Shift + Arrows/WASD'),
                  _Row(GflA11yStrings.jumpStartOfSphere, 'J + C'),
                  _Row(GflA11yStrings.jumpHome, 'J + H'),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

/// Compact keyboard-help opener used on the Full screen.
class GflKeyboardHelpButton extends StatelessWidget {
  const GflKeyboardHelpButton({super.key, this.focusOrder});

  final double? focusOrder;

  @override
  Widget build(BuildContext context) {
    void open() => GflKeyboardHelpDialog.show(context);
    Widget btn = Semantics(
      button: true,
      label: GflA11yStrings.keyboardHelpButton,
      onTap: open,
      child: ExcludeSemantics(
        child: TextButton(
          onPressed: open,
          child: const Text('?', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
    if (focusOrder != null) {
      btn = FocusTraversalOrder(
        order: NumericFocusOrder(focusOrder!),
        child: btn,
      );
    }
    return btn;
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.heading, required this.rows});

  final String heading;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          ...rows,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.keys);

  final String label;
  final String keys;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          Text(
            keys,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
