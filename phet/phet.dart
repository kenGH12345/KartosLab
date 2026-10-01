/// PhET Simulation Component Library — Barrel Export
///
/// This file re-exports all public PhET components so that individual
/// simulations can simply do:
///
///   import 'package:flutter_phet/src/phet/phet.dart';
///
/// and get access to every shared component.
library;

// ── Core types & coordinate system ──
export 'widgets/core/phet_types.dart';
export 'widgets/core/coordinate_system.dart';

// ── Theme ──
export 'widgets/theme/phet_theme.dart';

// ── Canvas & layer system ──
export 'widgets/canvas/phet_canvas.dart';
export 'widgets/canvas/phet_painter.dart';
export 'widgets/canvas/phet_layer.dart';

// ── Layout ──
export 'widgets/layout/phet_responsive_layout.dart';

// ── UI Controls ──
export 'widgets/controls/phet_button.dart';
export 'widgets/controls/phet_icon_button.dart';
export 'widgets/controls/phet_toggle_button.dart';
export 'widgets/controls/phet_checkbox.dart';
export 'widgets/controls/phet_radio_button.dart';
export 'widgets/controls/phet_slider.dart';
export 'widgets/controls/phet_number_control.dart';
export 'widgets/controls/phet_arrow_button.dart';
export 'widgets/controls/phet_text_field.dart';

// ── Panels ──
export 'widgets/panels/phet_panel.dart';
export 'widgets/panels/phet_control_panel.dart';
export 'widgets/panels/phet_dialog.dart';
export 'widgets/panels/phet_floating_panel.dart';

// ── Navigation ──
export 'widgets/navigation/phet_back_button.dart';

// ── Simulation core ──
export 'widgets/simulation/simulation_clock.dart';
export 'widgets/simulation/simulation_controller.dart';
export 'widgets/simulation/simulation_control_bar.dart';
export 'widgets/simulation/simulation_page.dart';

// ── Interaction ──
export 'widgets/interaction/phet_draggable.dart';
export 'widgets/interaction/drag_controller.dart';

// ── Shapes ──
export 'widgets/shapes/phet_shapes.dart';
export 'widgets/shapes/phet_arrow.dart';

// ── Objects ──
export 'widgets/objects/phet_object.dart';
export 'widgets/objects/phet_interactive_object.dart';

// ── Particles ──
export 'widgets/particles/particle.dart';
export 'widgets/particles/particle_system.dart';

// ── Text & labels ──
export 'widgets/controls/phet_text.dart';
export 'widgets/controls/phet_label.dart';

// ── Visualization ──
export 'widgets/visualization/vector.dart';
export 'widgets/visualization/vector_arrow.dart';
export 'widgets/visualization/field.dart';
export 'widgets/visualization/field_arrow_painter.dart';
export 'widgets/visualization/compass.dart';
export 'widgets/visualization/field_meter.dart';

// ── Measurement tools ──
export 'widgets/measurement/measurement_tool.dart';
export 'widgets/measurement/ruler.dart';

// ── Graphs ──
export 'widgets/graphs/phet_graph.dart';
export 'widgets/graphs/graph_data.dart';
export 'widgets/graphs/axis.dart';

// ── Physics core ──
export 'widgets/physics/physics_object.dart';
export 'widgets/physics/force.dart';
export 'widgets/physics/mechanics/spring.dart';
export 'widgets/physics/mechanics/ball.dart';
export 'widgets/physics/mechanics/block.dart';
export 'widgets/physics/magnetism/magnetic_field.dart';
export 'widgets/physics/magnetism/bar_magnet.dart';
export 'widgets/physics/magnetism/electromagnet.dart';
export 'widgets/physics/magnetism/coil.dart';
export 'widgets/physics/electricity/battery.dart';
export 'widgets/physics/electricity/wire.dart';
export 'widgets/physics/electricity/switch.dart';
export 'widgets/physics/electricity/resistor.dart';
export 'widgets/physics/electricity/bulb.dart';
export 'widgets/physics/electricity/circuit.dart';

// ── Chemistry core ──
export 'widgets/chemistry/atoms/atom.dart';
export 'widgets/chemistry/atoms/nucleus.dart';
export 'widgets/chemistry/atoms/electron_shell.dart';
export 'widgets/chemistry/molecules/molecule.dart';
export 'widgets/chemistry/bonds/bond.dart';
export 'widgets/chemistry/solutions/solution.dart';
export 'widgets/chemistry/solutions/beaker.dart';
export 'widgets/chemistry/reactions/chemical_reaction.dart';
export 'widgets/chemistry/acids_bases/ph_model.dart';
export 'widgets/chemistry/gases/gas.dart';
