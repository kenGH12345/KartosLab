import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/controller/playground_controller.dart';
import 'package:kratos/energy_skate_park/screens/esp_screen_body.dart';
import 'package:kratos/energy_skate_park/widgets/control_panel.dart';
import 'package:kratos/energy_skate_park/widgets/energy_bar_panel.dart';
import 'package:kratos/energy_skate_park/widgets/playground_bottom_tools.dart';

class PlaygroundScreen extends StatefulWidget {
  const PlaygroundScreen({super.key, this.controller, this.embedded = false});

  final PlaygroundController? controller;
  final bool embedded;

  @override
  State<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends State<PlaygroundScreen> {
  late final PlaygroundController _controller;
  late final bool _owns;

  @override
  void initState() {
    super.initState();
    _owns = widget.controller == null;
    _controller = widget.controller ?? PlaygroundController();
  }

  @override
  void dispose() {
    if (_owns) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return EspScreenBody(
          controller: _controller,
          embedded: widget.embedded,
          leftPanel: EnergyBarPanel(controller: _controller),
          bottomCenter: PlaygroundBottomTools(
            onAddTrack: _controller.addTrack,
            onClearTracks: _controller.clearTracks,
          ),
          config: ControlPanelConfig(
            showSceneSelector: false,
            showGravityCombo: true,
            showToolbox: true,
            playgroundActions: true,
            onAddTrack: _controller.addTrack,
            onClearTracks: _controller.clearTracks,
            canSplit: _controller.canSplitSelected,
            canDeleteCp: _controller.canDeleteSelected,
            onSplitControlPoint: _controller.splitSelectedControlPoint,
            onDeleteControlPoint: _controller.deleteSelectedControlPoint,
          ),
        );
      },
    );
  }
}
