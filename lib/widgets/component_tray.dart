import 'package:flutter/material.dart';
import '../models/circuit_state.dart';
import 'component_icon.dart';

class ComponentTray extends StatelessWidget {
  const ComponentTray({super.key});

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal:10,vertical:8),
    decoration: const BoxDecoration(color: Color(0xFF0B2B3D), borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    child: SingleChildScrollView(scrollDirection: Axis.horizontal,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _Item(type:ComponentType.battery),
        _Item(type:ComponentType.resistor),
        _Item(type:ComponentType.lightBulb),
        _Item(type:ComponentType.switch_),
        _Item(type:ComponentType.fuse),
        _Item(type:ComponentType.ground),
        _Item(type:ComponentType.wire),
      ])));
}

class _Item extends StatelessWidget {
  final ComponentType type;
  const _Item({required this.type});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Draggable<ComponentType>(
        data: type,
        feedback: ComponentIconWidget.dragFeedback(type),
        childWhenDragging: Opacity(
          opacity: 0.4,
          child: ComponentIconWidget(type: type),
        ),
        child: ComponentIconWidget(type: type),
      ),
    );
  }
}
