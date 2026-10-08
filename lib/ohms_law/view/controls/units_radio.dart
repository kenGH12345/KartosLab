import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../model/current_units.dart';
import '../../model/ohms_law_model.dart';
import '../../ohms_law_view_constants.dart';
import 'package:kratos/ohms_law/ohms_law_strings.dart';

/// PhET `UnitsRadioButtonContainer` — vertical aqua-style radios (1.5+).
class UnitsRadioGroup extends StatefulWidget {
  const UnitsRadioGroup({super.key, required this.model, this.focusNode});

  final OhmsLawModel model;
  final FocusNode? focusNode;

  @override
  State<UnitsRadioGroup> createState() => _UnitsRadioGroupState();
}

class _UnitsRadioGroupState extends State<UnitsRadioGroup> {
  late final FocusNode _focus;
  late final bool _ownsFocus;

  @override
  void initState() {
    super.initState();
    _ownsFocus = widget.focusNode == null;
    _focus = widget.focusNode ?? FocusNode(debugLabel: 'ohmsLawUnits');
  }

  @override
  void dispose() {
    if (_ownsFocus) {
      _focus.dispose();
    }
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowRight) {
      widget.model.currentUnits = CurrentUnit.amps;
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowLeft) {
      widget.model.currentUnits = CurrentUnit.milliamps;
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.digit1 || key == LogicalKeyboardKey.numpad1) {
      widget.model.currentUnits = CurrentUnit.milliamps;
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.digit2 || key == LogicalKeyboardKey.numpad2) {
      widget.model.currentUnits = CurrentUnit.amps;
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    return Focus(
      focusNode: _focus,
      onKeyEvent: _onKey,
      child: Semantics(
        container: true,
        label: OhmsLawStrings.currentUnits,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              OhmsLawStrings.units,
              style: TextStyle(
                fontFamily: OhmsLawViewConstants.uiFontFamily,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            _AquaRadio(
              key: const Key('ohms_law_units_ma'),
              selected: model.currentUnits == CurrentUnit.milliamps,
              label: OhmsLawStrings.milliamps,
              onTap: () {
                _focus.requestFocus();
                model.currentUnits = CurrentUnit.milliamps;
              },
            ),
            const SizedBox(height: 8),
            _AquaRadio(
              key: const Key('ohms_law_units_a'),
              selected: model.currentUnits == CurrentUnit.amps,
              label: OhmsLawStrings.amps,
              onTap: () {
                _focus.requestFocus();
                model.currentUnits = CurrentUnit.amps;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AquaRadio extends StatelessWidget {
  const _AquaRadio({
    super.key,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? const Color(0xFF6CC3E0) : Colors.white,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: OhmsLawViewConstants.uiFontFamily,
                fontSize: 20,
                color: Colors.black,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
