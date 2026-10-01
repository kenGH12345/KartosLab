/// PhET Measurement Tool — base class for all measurement instruments.
///
/// Subclasses: Ruler, Stopwatch, Thermometer, PressureGauge, Voltmeter,
/// Ammeter, FieldMeter, PHMeter, Balance, Protractor.
library;

import 'package:flutter/material.dart';
import '../objects/phet_object.dart';

abstract class MeasurementTool extends PhetObject {
  /// The measurement value as a string (for display).
  String get displayValue;

  /// The unit of measurement.
  String get unit;
}

/// A draggable measurement tool widget that displays a value.
class MeasurementToolWidget extends StatefulWidget {
  final String label;
  final String value;
  final String unit;
  final Offset initialPosition;
  final double width;
  final double height;

  const MeasurementToolWidget({
    super.key,
    required this.label,
    required this.value,
    this.unit = '',
    this.initialPosition = const Offset(100, 100),
    this.width = 120,
    this.height = 60,
  });

  @override
  State<MeasurementToolWidget> createState() => _MeasurementToolWidgetState();
}

class _MeasurementToolWidgetState extends State<MeasurementToolWidget> {
  late Offset _position;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx - widget.width / 2,
      top: _position.dy - widget.height / 2,
      child: GestureDetector(
        onPanUpdate: (d) => setState(() => _position += d.delta),
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xff0d2255).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.lightBlueAccent, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
              const SizedBox(height: 2),
              Text(
                '${widget.value} ${widget.unit}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
