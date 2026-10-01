import 'package:flutter/material.dart';

import '../collision_lab_colors.dart';
import '../collision_lab_constants.dart';
import '../collision_lab_strings.dart';
import '../controller/collision_lab_controller.dart';
import '../model/cl_vec.dart';
import '../model/play_area.dart';
import 'keypad_dialog.dart';

class BallValuesPanel extends StatelessWidget {
  const BallValuesPanel({super.key, required this.controller});

  final CollisionLabController controller;

  @override
  Widget build(BuildContext context) {
    final model = controller.model;
    final more = controller.view.moreDataVisible;
    final is2d = model.playArea.dimension == PlayAreaDimension.two;
    final balls = model.ballSystem.balls;

    return Container(
      decoration: BoxDecoration(
        color: CollisionLabColors.panelFill,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: CollisionLabColors.panelStroke),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 32,
          dataRowMinHeight: 28,
          dataRowMaxHeight: 36,
          columnSpacing: 12,
          horizontalMargin: 8,
          columns: [
            const DataColumn(label: Text('Ball')),
            const DataColumn(label: Text(CollisionLabStrings.mass)),
            const DataColumn(label: Text('x')),
            if (is2d && more) const DataColumn(label: Text('y')),
            const DataColumn(label: Text('vx')),
            if (is2d) const DataColumn(label: Text('vy')),
            if (more) const DataColumn(label: Text('|v|')),
            if (more) const DataColumn(label: Text('px')),
            if (more && is2d) const DataColumn(label: Text('py')),
            if (more) const DataColumn(label: Text('|p|')),
          ],
          rows: [
            for (var i = 0; i < balls.length; i++)
              DataRow(
                cells: [
                  DataCell(Text('${balls[i].index}')),
                  _cell(
                    context,
                    balls[i].mass,
                    () => _editMass(context, i),
                  ),
                  _cell(
                    context,
                    balls[i].position.x,
                    () => _editPos(context, i, axisX: true),
                  ),
                  if (is2d && more)
                    _cell(
                      context,
                      balls[i].position.y,
                      () => _editPos(context, i, axisX: false),
                    ),
                  _cell(
                    context,
                    balls[i].velocity.x,
                    () => _editVel(context, i, axisX: true),
                  ),
                  if (is2d)
                    _cell(
                      context,
                      balls[i].velocity.y,
                      () => _editVel(context, i, axisX: false),
                    ),
                  if (more)
                    DataCell(Text(_fmt(balls[i].speed))),
                  if (more)
                    DataCell(Text(_fmt(balls[i].xMomentum))),
                  if (more && is2d)
                    DataCell(Text(_fmt(balls[i].yMomentum))),
                  if (more)
                    DataCell(Text(_fmt(balls[i].momentumMagnitude))),
                ],
              ),
          ],
        ),
      ),
    );
  }

  DataCell _cell(BuildContext context, double value, VoidCallback onTap) {
    return DataCell(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: CollisionLabColors.panelStroke),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(_fmt(value)),
      ),
      onTap: onTap,
    );
  }

  String _fmt(double v) =>
      v.toStringAsFixed(CollisionLabConstants.displayDecimalPlaces);

  Future<void> _editMass(BuildContext context, int index) async {
    final ball = controller.model.ballSystem.balls[index];
    final v = await showKeypadDialog(
      context: context,
      title: 'Ball ${ball.index} mass (kg)',
      initial: ball.mass,
      min: CollisionLabConstants.massMin,
      max: CollisionLabConstants.massMax,
    );
    if (v != null) controller.setMass(index, v);
  }

  Future<void> _editPos(
    BuildContext context,
    int index, {
    required bool axisX,
  }) async {
    final ball = controller.model.ballSystem.balls[index];
    final bounds = controller.model.playArea.bounds;
    final v = await showKeypadDialog(
      context: context,
      title: 'Ball ${ball.index} ${axisX ? 'x' : 'y'} (m)',
      initial: axisX ? ball.position.x : ball.position.y,
      min: axisX ? bounds.minX : bounds.minY,
      max: axisX ? bounds.maxX : bounds.maxY,
    );
    if (v == null) return;
    final pos = axisX
        ? ClVec(v, ball.position.y)
        : ClVec(ball.position.x, v);
    controller.setPosition(index, pos);
  }

  Future<void> _editVel(
    BuildContext context,
    int index, {
    required bool axisX,
  }) async {
    final ball = controller.model.ballSystem.balls[index];
    final v = await showKeypadDialog(
      context: context,
      title: 'Ball ${ball.index} ${axisX ? 'vx' : 'vy'} (m/s)',
      initial: axisX ? ball.velocity.x : ball.velocity.y,
      min: CollisionLabConstants.velocityMin,
      max: CollisionLabConstants.velocityMax,
    );
    if (v == null) return;
    final vel = axisX
        ? ClVec(v, ball.velocity.y)
        : ClVec(ball.velocity.x, v);
    controller.setVelocity(index, vel);
  }
}
