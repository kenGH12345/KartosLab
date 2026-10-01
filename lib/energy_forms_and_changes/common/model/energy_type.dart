/// PhET `EnergyType.ts`.
enum EnergyType {
  thermal,
  electrical,
  mechanical,
  light,
  chemical,
  hidden;

  bool get isVisibleInLegend => this != EnergyType.hidden;

  String get assetKey => switch (this) {
        EnergyType.thermal => 'energyThermal',
        EnergyType.electrical => 'energyElectrical',
        EnergyType.mechanical => 'energyMechanical',
        EnergyType.light => 'energyLight',
        EnergyType.chemical => 'energyChemical',
        EnergyType.hidden => 'energyHidden',
      };
}
