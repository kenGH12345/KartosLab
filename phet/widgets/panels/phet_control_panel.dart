/// PhET Control Panel — a panel with title and a column of controls.
///
/// A convenience subclass of [PhetPanel] for the typical "control panel"
/// layout (title at top, controls stacked below).
library;

import 'phet_panel.dart';

class PhetControlPanel extends PhetPanel {
  const PhetControlPanel({
    super.key,
    required super.title,
    required super.children,
    super.width = 240,
    super.padding,
    super.onDark,
  });
}
