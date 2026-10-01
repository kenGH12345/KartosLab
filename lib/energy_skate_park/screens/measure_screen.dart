import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/controller/measure_controller.dart';
import 'package:kratos/energy_skate_park/screens/esp_screen_body.dart';
import 'package:kratos/energy_skate_park/widgets/control_panel.dart';
import 'package:kratos/energy_skate_park/widgets/measure_sensor_panel.dart';

class MeasureScreen extends StatefulWidget {
  const MeasureScreen({super.key, this.controller, this.embedded = false});

  final MeasureController? controller;
  final bool embedded;

  @override
  State<MeasureScreen> createState() => _MeasureScreenState();
}

class _MeasureScreenState extends State<MeasureScreen> {
  late final MeasureController _controller;
  late final bool _owns;

  @override
  void initState() {
    super.initState();
    _owns = widget.controller == null;
    _controller = widget.controller ?? MeasureController();
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
          leftPanel: MeasureSensorPanel(controller: _controller),
          config: ControlPanelConfig(
            showBarCheckbox: false,
            showGravityCombo: true,
            showPathCheckbox: true,
            showToolbox: true,
            pathVisible: _controller.measureModel.pathVisible,
            onScene: _controller.setScene,
            onPathVisible: _controller.setPathVisible,
          ),
        );
      },
    );
  }
}
