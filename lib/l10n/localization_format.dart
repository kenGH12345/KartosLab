/// Parameterized string formatting for KartosLab localization.
///
/// Placeholders use `{name}` syntax, e.g. `质量: {value} kg`.
String locFormat(String template, [Map<String, Object?>? params]) {
  if (params == null || params.isEmpty) return template;
  var out = template;
  params.forEach((key, value) {
    out = out.replaceAll('{$key}', '${value ?? ''}');
  });
  return out;
}
