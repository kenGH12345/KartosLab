import 'package:flutter/material.dart';
import 'package:kratos/gas_properties/screens/gas_properties_perf_harness.dart';

void main() {
  const n = int.fromEnvironment('GP_PERF_N', defaultValue: 1000);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: GasPropertiesPerfHarness(particleCount: n, sampleSeconds: 8),
  ));
}
