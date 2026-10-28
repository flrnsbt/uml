/// Built-in PlantUML themes.
///
/// Some themes (e.g., [darkula]) require an external dependency that is
/// automatically included when the theme is applied.
enum PlantUMLTheme {
  spacelab,
  darkula(
    'https://raw.githubusercontent.com/bschwarz/puml-themes/master/themes/darkula.puml',
  ),
  plain,
  cyborg,
  sketchy,
  materia,
  cerulean,
  superhero,
  united;

  /// An optional external Puml theme file URL.
  final String? externalDependency;
  const PlantUMLTheme([this.externalDependency]);
}

/// A color value used for PlantUML skinparam styling.
///
/// Stores an ARGB32 integer and provides [toHex] for PlantUML-compatible
/// hex color strings (e.g., `#FF0000`).
class Color {
  /// The ARGB32 color value.
  final int aRGB32;
  const Color(this.aRGB32);

  /// Converts this color to a PlantUML-compatible hex string (e.g., `#FF0000`).
  /// The alpha channel is ignored.
  String toHex() {
    final rgb = aRGB32 & 0x00FFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  @override
  String toString() => 'Color(${aRGB32.toRadixString(16).padLeft(8, '0')})';
}

/// Text alignment options for PlantUML diagrams.
enum TextAlign { left, right, center }
