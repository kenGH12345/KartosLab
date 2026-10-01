import 'package:flutter/material.dart';

import '../controller/projectile_motion_controller.dart';
import '../model/projectile_object_type.dart';
import '../pm_colors.dart';
import '../pm_constants.dart';
import '../pm_strings.dart';
import 'pm_controls.dart';

/// 各屏面板（Intro/Vectors/Drag/Lab），结构对照 PHASE_1 §3。
abstract final class PmPanels {
  // ── Intro topRight（IntroProjectileControlPanel.ts）─────────────────────
  static Widget introProjectilePanel(ProjectileMotionController c) {
    final model = c.model;
    return PmPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: PmComboBox<PmProjectileObjectType>(
              value: model.selectedObjectType,
              items: model.objectTypes,
              itemLabel: (t) => t.name ?? '',
              onChanged: model.setSelectedObjectType,
            ),
          ),
          const SizedBox(height: 9),
          Text('Mass: ${_trim(model.projectileMass)} kg',
              style: PmConstants.uiText),
          const SizedBox(height: 4),
          Text('Diameter: ${_trim(model.projectileDiameter)} m',
              style: PmConstants.uiText),
          const SizedBox(height: 9),
          _airResistanceRow(c, readOnlyCoefficient: true),
        ],
      ),
    );
  }

  // ── Intro bottomRight（IntroVectorsControlPanel.ts）─────────────────────
  static Widget introVectorsPanel(ProjectileMotionController c) {
    final vp = c.viewProperties;
    return PmPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _vectorHeader(PmStrings.velocityVectors, PmColors.velocityVectorFill),
          PmCheckbox(
              label: PmStrings.total,
              value: vp.totalVelocityVectorOn,
              onChanged: vp.setTotalVelocityVectorOn),
          PmCheckbox(
              label: PmStrings.components,
              value: vp.componentsVelocityVectorsOn,
              onChanged: vp.setComponentsVelocityVectorsOn),
          const Divider(color: PmColors.separator),
          _vectorHeader(
              PmStrings.accelerationVectors, PmColors.accelerationVectorFill),
          PmCheckbox(
              label: PmStrings.total,
              value: vp.totalAccelerationVectorOn,
              onChanged: vp.setTotalAccelerationVectorOn),
          PmCheckbox(
              label: PmStrings.components,
              value: vp.componentsAccelerationVectorsOn,
              onChanged: vp.setComponentsAccelerationVectorsOn),
        ],
      ),
    );
  }

  // ── Vectors topRight（VectorsProjectileControlPanel.js）─────────────────
  static Widget vectorsProjectilePanel(ProjectileMotionController c) {
    final model = c.model;
    final type = model.selectedObjectType;
    return PmPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PmNumberControl(
            title: PmStrings.diameter,
            value: model.projectileDiameter,
            min: type.diameterMin,
            max: type.diameterMax,
            delta: type.diameterRound,
            decimals: 1,
            unit: 'm',
            onChanged: model.setProjectileDiameter,
          ),
          const SizedBox(height: 9),
          PmNumberControl(
            title: PmStrings.mass,
            value: model.projectileMass,
            min: type.massMin,
            max: type.massMax,
            delta: type.massRound,
            decimals: 0,
            unit: 'kg',
            onChanged: model.setProjectileMass,
          ),
          const SizedBox(height: 9),
          _airResistanceRow(c, readOnlyCoefficient: true),
        ],
      ),
    );
  }

  // ── Vectors bottomRight（VectorsVectorsControlPanel.ts）─────────────────
  static Widget vectorsVectorsPanel(ProjectileMotionController c) =>
      _enumVectorsPanel(c, showAcceleration: true, showForce: true);

  // ── Drag topRight（DragProjectileControlPanel.js）───────────────────────
  static Widget dragProjectilePanel(ProjectileMotionController c) {
    final model = c.model;
    final type = model.selectedObjectType;
    return PmPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PmNumberControl(
            title: PmStrings.dragCoefficient,
            value: model.projectileDragCoefficient,
            min: type.dragCoefficientMin,
            max: type.dragCoefficientMax,
            delta: 0.01,
            decimals: 2,
            unit: '',
            onChanged: model.setProjectileDragCoefficient,
          ),
          const SizedBox(height: 9),
          PmNumberControl(
            title: PmStrings.diameter,
            value: model.projectileDiameter,
            min: type.diameterMin,
            max: type.diameterMax,
            delta: type.diameterRound,
            decimals: 1,
            unit: 'm',
            onChanged: model.setProjectileDiameter,
          ),
          const SizedBox(height: 9),
          PmNumberControl(
            title: PmStrings.mass,
            value: model.projectileMass,
            min: type.massMin,
            max: type.massMax,
            delta: type.massRound,
            decimals: 0,
            unit: 'kg',
            onChanged: model.setProjectileMass,
          ),
          const SizedBox(height: 9),
          PmNumberControl(
            title: PmStrings.altitude,
            value: model.altitude,
            min: PmConstants.altitudeMin,
            max: PmConstants.altitudeMax,
            delta: 100,
            decimals: 0,
            unit: 'm',
            onChanged: model.setAltitude,
          ),
        ],
      ),
    );
  }

  // ── Drag bottomRight（DragVectorsControlPanel.ts，无加速度）─────────────
  static Widget dragVectorsPanel(ProjectileMotionController c) =>
      _enumVectorsPanel(c, showAcceleration: false, showForce: true);

  // ── Lab topRight（InitialValuesPanel.ts）────────────────────────────────
  static Widget labInitialValuesPanel(ProjectileMotionController c) {
    final model = c.model;
    const style = PmConstants.uiText;
    return PmPanel(
      fill: PmColors.initialValuePanelFill,
      minWidth: 0,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(PmStrings.initialValues,
                style: PmConstants.uiText.copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          Text('Height: ${model.cannonHeight.toStringAsFixed(2)} m',
              style: style),
          Text('Cannon Angle: ${model.cannonAngle.toStringAsFixed(0)}°',
              style: style),
          Text('Speed: ${model.initialSpeed.toStringAsFixed(0)} m/s',
              style: style),
        ],
      ),
    );
  }

  // ── Lab bottomRight（LabProjectileControlPanel.js）──────────────────────
  static Widget labProjectilePanel(ProjectileMotionController c) {
    final model = c.model;
    final type = model.selectedObjectType;
    final isCustom = type.benchmark == 'custom';
    return PmPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PmComboBox<PmProjectileObjectType>(
            value: model.selectedObjectType,
            items: model.objectTypes,
            itemLabel: (t) => t.name ?? '',
            onChanged: model.setSelectedObjectType,
          ),
          const SizedBox(height: 9),
          PmNumberControl(
            title: PmStrings.mass,
            value: model.projectileMass,
            min: type.massMin,
            max: type.massMax,
            delta: type.massRound,
            decimals: type.massRound < 1 ? 2 : 0,
            unit: 'kg',
            onChanged: model.setProjectileMass,
          ),
          const SizedBox(height: 9),
          PmNumberControl(
            title: PmStrings.diameter,
            value: model.projectileDiameter,
            min: type.diameterMin,
            max: type.diameterMax,
            delta: type.diameterRound,
            decimals: 2,
            unit: 'm',
            onChanged: model.setProjectileDiameter,
          ),
          const SizedBox(height: 9),
          PmNumberControl(
            title: PmStrings.gravity,
            value: model.gravity,
            min: PmConstants.gravityMin,
            max: PmConstants.gravityMax,
            delta: 0.01,
            decimals: 2,
            unit: 'm/s²',
            onChanged: model.setGravity,
          ),
          const SizedBox(height: 9),
          _airResistanceRow(c, readOnlyCoefficient: !isCustom),
          const SizedBox(height: 9),
          PmNumberControl(
            title: PmStrings.altitude,
            value: model.altitude,
            min: PmConstants.altitudeMin,
            max: PmConstants.altitudeMax,
            delta: 100,
            decimals: 0,
            unit: 'm',
            enabled: model.airResistanceOn,
            onChanged: model.setAltitude,
          ),
          if (isCustom) ...[
            const SizedBox(height: 9),
            PmNumberControl(
              title: PmStrings.dragCoefficient,
              value: model.projectileDragCoefficient,
              min: type.dragCoefficientMin,
              max: type.dragCoefficientMax,
              delta: 0.01,
              decimals: 2,
              unit: '',
              onChanged: model.setProjectileDragCoefficient,
            ),
          ],
        ],
      ),
    );
  }

  // ── 共用碎片 ────────────────────────────────────────────────────────────

  static Widget _airResistanceRow(ProjectileMotionController c,
      {required bool readOnlyCoefficient}) {
    final model = c.model;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PmCheckbox(
          label: PmStrings.airResistance,
          value: model.airResistanceOn,
          onChanged: model.setAirResistanceOn,
          icon: const _AirResistanceIcon(),
        ),
        const SizedBox(width: 8),
        Opacity(
          opacity: model.airResistanceOn ? 1 : 0.5,
          child: Text(
            'Drag Coefficient: ${model.projectileDragCoefficient.toStringAsFixed(2)}',
            style: PmConstants.uiText,
          ),
        ),
      ],
    );
  }

  static Widget _enumVectorsPanel(ProjectileMotionController c,
      {required bool showAcceleration, required bool showForce}) {
    final vp = c.viewProperties;
    return PmPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PmRadioRow(
                  label: PmStrings.total,
                  value: PmVectorsDisplay.total,
                  groupValue: vp.vectorsDisplay,
                  onChanged: vp.setVectorsDisplay),
              const SizedBox(width: 12),
              PmRadioRow(
                  label: PmStrings.components,
                  value: PmVectorsDisplay.components,
                  groupValue: vp.vectorsDisplay,
                  onChanged: vp.setVectorsDisplay),
            ],
          ),
          const SizedBox(height: 9),
          PmCheckbox(
            label: PmStrings.velocityVectors,
            value: vp.velocityVectorsOn,
            onChanged: vp.setVelocityVectorsOn,
            icon: const _VectorIcon(color: PmColors.velocityVectorFill),
          ),
          if (showAcceleration) ...[
            const SizedBox(height: 6),
            PmCheckbox(
              label: PmStrings.accelerationVectors,
              value: vp.accelerationVectorsOn,
              onChanged: vp.setAccelerationVectorsOn,
              icon: const _VectorIcon(color: PmColors.accelerationVectorFill),
            ),
          ],
          if (showForce) ...[
            const SizedBox(height: 6),
            PmCheckbox(
              label: PmStrings.forceVectors,
              value: vp.forceVectorsOn,
              onChanged: vp.setForceVectorsOn,
              icon: const _VectorIcon(color: PmColors.forceVectorFill),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _vectorHeader(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title,
            style: PmConstants.uiText.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        _VectorIcon(color: color),
      ],
    );
  }

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
}

/// Constants:93-99 箭头图标（20px 长）
class _VectorIcon extends StatelessWidget {
  const _VectorIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 10),
      painter: _ArrowIconPainter(color),
    );
  }
}

class _ArrowIconPainter extends CustomPainter {
  _ArrowIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final cy = size.height / 2;
    final path = Path()
      ..moveTo(0, cy - 2)
      ..lineTo(size.width - 8, cy - 2)
      ..lineTo(size.width - 8, cy - 4)
      ..lineTo(size.width, cy)
      ..lineTo(size.width - 8, cy + 4)
      ..lineTo(size.width - 8, cy + 2)
      ..lineTo(0, cy + 2)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArrowIconPainter oldDelegate) => false;
}

/// AIR_RESISTANCE_ICON（Constants:33-38, 114-134）：洋红弧 + 3 黑点
class _AirResistanceIcon extends StatelessWidget {
  const _AirResistanceIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(22, 16), painter: _AirIconPainter());
  }
}

class _AirIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.55);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 8),
      3.14159 * 1.15,
      3.14159 * 0.7,
      false,
      Paint()
        ..color = const Color.fromRGBO(252, 40, 252, 1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    final dotPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(center.dx - 6, center.dy + 2), 1.8, dotPaint);
    canvas.drawCircle(Offset(center.dx + 6, center.dy + 2), 1.8, dotPaint);
    canvas.drawCircle(Offset(center.dx, center.dy - 7), 1.8, dotPaint);
  }

  @override
  bool shouldRepaint(_AirIconPainter oldDelegate) => false;
}
