import 'package:flutter/material.dart';

/// Menu entry for [ScenarioMenuButton].
///
/// A minimal contract that decouples the button from any specific
/// `<Sim>Scenario` type: sims pass their `scenarioId` + human-readable `name`
/// after mapping from their own scenario list.
@immutable
class ScenarioMenuEntry {
  final String id;
  final String name;
  const ScenarioMenuEntry({required this.id, required this.name});
}

/// L0 - AppBar action button for choosing a scenario.
///
/// Renders one of two states:
/// * `loading == true` or `entries` is empty  -> 16x16 white spinner
/// * otherwise -> `PopupMenuButton<String>` with radio icons; the selected
///   item is highlighted with [accentColor].
///
/// Why L0: identical structure and interaction is needed by every sim that
/// wants a scenario picker (sound / radio-waves / wave-interference already;
/// bending-light / photoelectric / more to come). Sims only differ in
/// [entries], [currentId], [accentColor] and the [onSelected] callback body.
class ScenarioMenuButton extends StatelessWidget {
  final List<ScenarioMenuEntry> entries;
  final String? currentId;
  final ValueChanged<String> onSelected;
  final Color accentColor;
  final bool loading;
  final String tooltip;

  const ScenarioMenuButton({
    super.key,
    required this.entries,
    required this.currentId,
    required this.onSelected,
    required this.accentColor,
    this.loading = false,
    this.tooltip = 'Choose scenario',
  });

  @override
  Widget build(BuildContext context) {
    if (loading || entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(right: 12),
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white70,
            ),
          ),
        ),
      );
    }
    return PopupMenuButton<String>(
      tooltip: tooltip,
      icon: const Icon(Icons.tune_rounded, size: 20),
      onSelected: onSelected,
      itemBuilder: (ctx) => entries.map((e) {
        final selected = e.id == currentId;
        return PopupMenuItem<String>(
          value: e.id,
          child: Row(children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 16,
              color: selected ? accentColor : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(e.name, style: const TextStyle(fontSize: 13)),
          ]),
        );
      }).toList(),
    );
  }
}
