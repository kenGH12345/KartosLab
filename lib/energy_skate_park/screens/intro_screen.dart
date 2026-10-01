import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/controller/intro_controller.dart';
import 'package:kratos/energy_skate_park/screens/esp_screen_body.dart';
import 'package:kratos/energy_skate_park/widgets/control_panel.dart';
import 'package:kratos/energy_skate_park/widgets/energy_bar_panel.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key, this.controller, this.embedded = false});

  final IntroController? controller;
  final bool embedded;

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late final IntroController _controller;
  late final bool _owns;

  @override
  void initState() {
    super.initState();
    _owns = widget.controller == null;
    _controller = widget.controller ?? IntroController();
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
          config: ControlPanelConfig(
            showToolbox: true,
            onScene: _controller.setScene,
          ),
        );
      },
    );
  }
}
