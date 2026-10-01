enum TransportProteinType {
  sodiumIonLeakageChannel,
  potassiumIonLeakageChannel,
  sodiumIonVoltageGatedChannel,
  potassiumIonVoltageGatedChannel,
  sodiumIonLigandGatedChannel,
  potassiumIonLigandGatedChannel,
  sodiumPotassiumPump,
  sodiumGlucoseCotransporter,
}

const List<TransportProteinType> allTransportProteinTypes =
    TransportProteinType.values;

bool isSodiumPassiveGate(TransportProteinType type) =>
    type == TransportProteinType.sodiumIonLeakageChannel ||
    type == TransportProteinType.sodiumIonLigandGatedChannel ||
    type == TransportProteinType.sodiumIonVoltageGatedChannel;

bool isPotassiumPassiveGate(TransportProteinType type) =>
    type == TransportProteinType.potassiumIonLeakageChannel ||
    type == TransportProteinType.potassiumIonLigandGatedChannel ||
    type == TransportProteinType.potassiumIonVoltageGatedChannel;
