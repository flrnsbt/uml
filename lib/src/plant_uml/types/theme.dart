export 'package:uml/src/base.dart' show Color, TextAlign;

/// Built-in PlantUML themes.
///
/// Some themes (e.g., [darkula]) require an external dependency that is
/// automatically included when the theme is applied.
enum PlantUMLTheme {
  /// The Spacelab theme with a clean, light appearance.
  spacelab,

  /// The Darkula theme with a dark appearance (requires external dependency).
  darkula(
    'https://raw.githubusercontent.com/bschwarz/puml-themes/master/themes/darkula.puml',
  ),

  /// The plain theme with no special styling.
  plain,

  /// The Cyborg theme with a dark, high-contrast appearance.
  cyborg,

  /// The Sketchy theme with a hand-drawn appearance.
  sketchy,

  /// The Materia theme with a modern, colorful appearance.
  materia,

  /// The Cerulean theme with a blue-tinted appearance.
  cerulean,

  /// The Superhero theme with a bold, comic-book appearance.
  superhero,

  /// The United theme with a professional, light appearance.
  united;

  /// Creates a PlantUML theme with an optional external dependency URL.
  const PlantUMLTheme([this.externalDependency]);

  /// An optional external Puml theme file URL.
  final String? externalDependency;
}
