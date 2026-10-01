enum CckViewType { lifelike, schematic }

enum CckCurrentType { electrons, conventional }

enum CckElementKind {
  wire,
  battery,
  acSource,
  resistor,
  lightBulb,
  capacitor,
  inductor,
  switch_,
  fuse,
  seriesAmmeter,
}

enum CckResistorKind {
  resistor,
  coin,
  paperClip,
  pencil,
  thinPencil,
  eraser,
  dollarBill,
}

enum CckSelectionKind { none, element, vertex }
