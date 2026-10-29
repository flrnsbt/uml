import 'package:uml/src/base.dart';

export 'package:uml/src/base.dart' show Color, TextAlign;

/// Built-in PlantUML themes.
///
/// Some themes (e.g., [darkula]) require an external dependency that is
/// automatically included when the theme is applied.
enum PlantUmlTheme implements UmlTheme {
  /// The Spacelab theme with a clean, light appearance.
  spacelab(UmlBrightness.light),

  /// The Darkula theme with a dark appearance (requires external dependency).
  darkula(
    UmlBrightness.dark,
    'https://raw.githubusercontent.com/bschwarz/puml-themes/master/themes/darkula.puml',
  ),

  /// The plain theme with no special styling.
  plain(UmlBrightness.light),

  /// The Cyborg theme with a dark, high-contrast appearance.
  cyborg(UmlBrightness.dark),

  /// The Sketchy theme with a hand-drawn appearance.
  sketchy(UmlBrightness.light),

  /// The Materia theme with a modern, colorful appearance.
  materia(UmlBrightness.light),

  /// The Cerulean theme with a blue-tinted appearance.
  cerulean(UmlBrightness.light),

  /// The Superhero theme with a bold, comic-book appearance.
  superhero(UmlBrightness.light),

  /// The United theme with a professional, light appearance.
  united(UmlBrightness.light);

  /// Creates a PlantUML theme with an optional external dependency URL.
  const PlantUmlTheme(this.brightness, [this.externalDependency]);

  /// An optional external Puml theme file URL.
  final String? externalDependency;

  @override
  final UmlBrightness brightness;

  @override
  String get themeName => name;
}
