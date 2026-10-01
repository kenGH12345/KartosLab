/// PhET `SourceTypeValues`.
enum SourceType {
  photons,
  electrons,
  neutrons,
  heliumAtoms,
}

extension SourceTypePhysics on SourceType {
  bool get isPhoton => this == SourceType.photons;

  bool get isMatter => !isPhoton;
}
