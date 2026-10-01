import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:kratos/rutherford_scattering/controller/rs_simulation_controller.dart';
import 'package:kratos/rutherford_scattering/model/plum_pudding_atom_model.dart';
import 'package:kratos/rutherford_scattering/painters/rs_observation_painter.dart';
import 'package:kratos/rutherford_scattering/rs_colors.dart';
import 'package:kratos/rutherford_scattering/rs_constants.dart';
import 'package:kratos/rutherford_scattering/rs_strings.dart';
import 'package:kratos/rutherford_scattering/widgets/rs_base_screen_layout.dart';
import 'package:kratos/rutherford_scattering/widgets/rs_control_panels.dart';

class PlumPuddingAtomScreen extends StatefulWidget {
  const PlumPuddingAtomScreen({super.key});

  @override
  State<PlumPuddingAtomScreen> createState() => _PlumPuddingAtomScreenState();
}

class _PlumPuddingAtomScreenState extends State<PlumPuddingAtomScreen>
    with TickerProviderStateMixin {
  late final PlumPuddingAtomModel _model;
  late final RsSimulationController _controller;
  ui.Image? _plumImage;

  @override
  void initState() {
    super.initState();
    _model = PlumPuddingAtomModel();
    _controller = RsSimulationController(_model)..attach(this);
    loadRsPlumPuddingImage().then((img) {
      if (mounted) setState(() => _plumImage = img);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _plumImage?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return RsBaseScreenLayout(
          controller: _controller,
          mode: RsObservationMode.plumPudding,
          particleStyle: RsParticleStyle.nucleus,
          scaleLabel:
              RsStrings.atomicScale(RsConstants.plumPuddingScaleValue),
          beamColor: RsColors.atomBeam,
          plumPuddingImage: _plumImage,
          panels: [
            RsLegendPanel(
              entries: [
                (RsLegendPanel.electronDot(), RsStrings.electron),
                (RsLegendPanel.protonDot(), RsStrings.proton),
                (RsLegendPanel.neutronDot(), RsStrings.neutron),
                (RsLegendPanel.alphaCluster(), RsStrings.alphaParticle),
                (
                  RsLegendPanel.positiveChargeIcon(),
                  RsStrings.positiveCharge
                ),
              ],
            ),
            RsAlphaParticlePanel(controller: _controller),
          ],
        );
      },
    );
  }
}
