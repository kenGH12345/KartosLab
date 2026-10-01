import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/controller/graphs_controller.dart';
import 'package:kratos/energy_skate_park/model/track_set_model.dart';
import 'package:kratos/energy_skate_park/screens/esp_screen_body.dart';
import 'package:kratos/energy_skate_park/widgets/control_panel.dart';
import 'package:kratos/energy_skate_park/widgets/energy_graph_panel.dart';

class GraphsScreen extends StatefulWidget {
  const GraphsScreen({super.key, this.controller, this.embedded = false});

  final GraphsController? controller;
  final bool embedded;

  @override
  State<GraphsScreen> createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen> {
  late final GraphsController _controller;
  late final bool _owns;

  @override
  void initState() {
    super.initState();
    _owns = widget.controller == null;
    _controller = widget.controller ?? GraphsController();
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
          // Page-level graph above simulation — not a play-area overlay.
          topPanel: EnergyGraphPanel(controller: _controller),
          config: ControlPanelConfig(
            showBarCheckbox: false,
            showPieCheckbox: false,
            showGravityCombo: true,
            showToolbox: true,
            showEnergyGraphToggle: false,
            scenes: const [TrackScene.parabola, TrackScene.doubleWell],
            onScene: _controller.setScene,
          ),
        );
      },
    );
  }
}
