/// Gas Properties — Model / Solver / View barrel.
///
/// PhET source traceability (local `gas-properties-main`):
/// - IdealGasLawModel ← `js/common/model/IdealGasLawModel.ts`
/// - Particle / collisions ← `Particle.ts`, `CollisionDetector.ts`
/// - Pressure / Temperature ← `PressureModel.ts`, `TemperatureModel.ts`
/// - Hold Constant ← Ideal holdConstantProperty + Oops emitters
/// - Energy sampling ← Energy histograms / AverageSpeed (19 bins, 1 ps)
/// - Diffusion ← `js/diffusion/model/DiffusionModel.ts`
/// - View MVT ← BaseModel MODEL_VIEW_SCALE 0.040
library;

export 'gas_properties_constants.dart';
export 'gas_properties_colors.dart';
export 'model/container_state.dart';
export 'model/diffusion_model.dart';
export 'model/hold_constant.dart';
export 'model/ideal_gas_law_model.dart';
export 'model/particle.dart';
export 'model/particle_system.dart';
export 'model/particle_type.dart';
export 'model/random_source.dart';
export 'model/simulation_clock.dart';
export 'solver/collision_solver.dart';
export 'solver/gas_law_solver.dart';
export 'solver/histogram_solver.dart';
export 'solver/hold_constant_solver.dart';
export 'solver/pressure_solver.dart';
export 'solver/temperature_solver.dart';
export 'controller/gas_simulation_controller.dart';
export 'transform/gas_coordinate_transform.dart';
export 'render/gas_render_state.dart';
export 'screens/gas_properties_home.dart';
