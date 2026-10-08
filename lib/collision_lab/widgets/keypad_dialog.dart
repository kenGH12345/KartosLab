import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../collision_lab_colors.dart';
import '../collision_lab_constants.dart';

enum KeypadField { mass, x, y, vx, vy }

Future<double?> showKeypadDialog({
  required BuildContext context,
  required String title,
  required double initial,
  required double min,
  required double max,
}) {
  return showDialog<double>(
    context: context,
    builder: (ctx) => KeypadDialog(
      title: title,
      initial: initial,
      min: min,
      max: max,
    ),
  );
}

class KeypadDialog extends StatefulWidget {
  const KeypadDialog({
    super.key,
    required this.title,
    required this.initial,
    required this.min,
    required this.max,
  });

  final String title;
  final double initial;
  final double min;
  final double max;

  @override
  State<KeypadDialog> createState() => _KeypadDialogState();
}

class _KeypadDialogState extends State<KeypadDialog> {
  late final TextEditingController _text;

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(
      text: widget.initial.toStringAsFixed(CollisionLabConstants.displayDecimalPlaces),
    );
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    final v = double.tryParse(_text.text.trim());
    if (v == null) return;
    final clamped = v.clamp(widget.min, widget.max);
    Navigator.of(context).pop(clamped.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Range: ${widget.min} … ${widget.max}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _text,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
            ],
            decoration: InputDecoration(
              filled: true,
              fillColor: CollisionLabColors.highlightedNumberDisplay,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('确定'),
        ),
      ],
    );
  }
}
