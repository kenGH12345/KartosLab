import '../membrane_transport_model.dart';
import '../transport_protein_type.dart';
import 'leakage_channel.dart';
import 'ligand_gated_channel.dart';
import 'sodium_glucose_cotransporter.dart';
import 'sodium_potassium_pump.dart';
import 'transport_protein.dart';
import 'voltage_gated_channel.dart';

TransportProtein createTransportProtein(
  MembraneTransportModel model,
  TransportProteinType type,
  double position,
) {
  switch (type) {
    case TransportProteinType.sodiumIonLeakageChannel:
    case TransportProteinType.potassiumIonLeakageChannel:
      return LeakageChannel(model: model, type: type, position: position);
    case TransportProteinType.sodiumIonVoltageGatedChannel:
      return SodiumVoltageGatedChannel(model: model, position: position);
    case TransportProteinType.potassiumIonVoltageGatedChannel:
      return PotassiumVoltageGatedChannel(model: model, position: position);
    case TransportProteinType.sodiumIonLigandGatedChannel:
    case TransportProteinType.potassiumIonLigandGatedChannel:
      return LigandGatedChannel(model: model, type: type, position: position);
    case TransportProteinType.sodiumPotassiumPump:
      return SodiumPotassiumPump(model: model, position: position);
    case TransportProteinType.sodiumGlucoseCotransporter:
      return SodiumGlucoseCotransporter(model: model, position: position);
  }
}
