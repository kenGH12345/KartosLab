import 'package:flutter/material.dart';
import 'package:kratos/rutherford_scattering/controller/rs_simulation_controller.dart';
import 'package:kratos/rutherford_scattering/model/rutherford_atom_model.dart';
import 'package:kratos/rutherford_scattering/painters/rs_observation_painter.dart';
import 'package:kratos/rutherford_scattering/rs_colors.dart';
import 'package:kratos/rutherford_scattering/rs_constants.dart';
import 'package:kratos/rutherford_scattering/rs_strings.dart';
import 'package:kratos/rutherford_scattering/widgets/rs_base_screen_layout.dart';
import 'package:kratos/rutherford_scattering/widgets/rs_control_panels.dart';

class RutherfordAtomScreen extends StatefulWidget {
  const RutherfordAtomScreen({super.key});

  @override
  State<RutherfordAtomScreen> createState() => _RutherfordAtomScreenState();
}

class _RutherfordAtomScreenState extends State<RutherfordAtomScreen>
    with TickerProviderStateMixin {
  late final RutherfordAtomModel _model;
  late final RsSimulationController _controller;

  @override
  void initState() {
    super.initState();
    _model = RutherfordAtomModel();
    _controller = RsSimulationController(_model)..attach(this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final isNucleus = _model.scene == RutherfordScene.nucleus;
        final scaleLabel = isNucleus
            ? RsStrings.nuclearScale(RsConstants.nuclearScaleValue)
            : RsStrings.atomicScale(RsConstants.atomicScaleValue);

        return RsBaseScreenLayout(
          controller: _controller,
          mode: isNucleus
              ? RsObservationMode.nuclearCluster
              : RsObservationMode.atomicAtoms,
          particleStyle: isNucleus
              ? RsParticleStyle.nucleus
              : RsParticleStyle.particle,
          scaleLabel: scaleLabel,
          beamColor: isNucleus ? RsColors.nucleusBeam : RsColors.atomBeam,
          sceneRadio: RsSceneRadio(
            scene: _model.scene,
            onChanged: _controller.setScene,
          ),
          panels: [
            if (isNucleus)
              RsLegendPanel(
                entries: [
                  (RsLegendPanel.protonDot(), RsStrings.proton),
                  (RsLegendPanel.neutronDot(), RsStrings.neutron),
                  (RsLegendPanel.alphaCluster(), RsStrings.alphaParticle),
                ],
              )
            else
              RsLegendPanel(
                entries: [
                  (RsLegendPanel.nucleusDot(), RsStrings.nucleus),
                  (
                    RsLegendPanel.energyLevelIcon(),
                    RsStrings.electronEnergyLevel
                  ),
                  (RsLegendPanel.traceArrow(), RsStrings.alphaParticleTrace),
                ],
              ),
            RsAlphaParticlePanel(controller: _controller),
            RsAtomPropertiesPanel(controller: _controller),
          ],
        );
      },
    );
  }
}
