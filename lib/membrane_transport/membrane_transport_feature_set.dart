import 'model/solute_type.dart';
import 'model/transport_protein_type.dart';

/// PhET `MembraneTransportFeatureSet` — per-screen capability flags.
enum MembraneTransportFeatureSet {
  simpleDiffusion,
  facilitatedDiffusion,
  activeTransport,
  playground,
}

List<SoluteType> featureSetSoluteTypes(MembraneTransportFeatureSet fs) {
  if (fs == MembraneTransportFeatureSet.activeTransport ||
      fs == MembraneTransportFeatureSet.playground) {
    return SoluteType.values.toList();
  }
  return SoluteType.values.where((t) => t != SoluteType.atp).toList();
}

List<SoluteType> featureSetSelectableSoluteTypes(
  MembraneTransportFeatureSet fs,
) {
  return featureSetSoluteTypes(fs)
      .where((t) => t != SoluteType.adp && t != SoluteType.phosphate)
      .toList();
}

bool featureSetHasVoltages(MembraneTransportFeatureSet fs) =>
    fs == MembraneTransportFeatureSet.facilitatedDiffusion ||
    fs == MembraneTransportFeatureSet.playground;

bool featureSetHasLigands(MembraneTransportFeatureSet fs) =>
    fs == MembraneTransportFeatureSet.facilitatedDiffusion ||
    fs == MembraneTransportFeatureSet.playground;

bool featureSetHasProteins(MembraneTransportFeatureSet fs) =>
    fs != MembraneTransportFeatureSet.simpleDiffusion;

List<TransportProteinType> featureSetTransportProteins(
  MembraneTransportFeatureSet fs,
) {
  switch (fs) {
    case MembraneTransportFeatureSet.simpleDiffusion:
      return const [];
    case MembraneTransportFeatureSet.facilitatedDiffusion:
      return const [
        TransportProteinType.sodiumIonLeakageChannel,
        TransportProteinType.potassiumIonLeakageChannel,
        TransportProteinType.sodiumIonVoltageGatedChannel,
        TransportProteinType.potassiumIonVoltageGatedChannel,
        TransportProteinType.sodiumIonLigandGatedChannel,
        TransportProteinType.potassiumIonLigandGatedChannel,
      ];
    case MembraneTransportFeatureSet.activeTransport:
      return const [
        TransportProteinType.sodiumPotassiumPump,
        TransportProteinType.sodiumGlucoseCotransporter,
      ];
    case MembraneTransportFeatureSet.playground:
      return allTransportProteinTypes;
  }
}
