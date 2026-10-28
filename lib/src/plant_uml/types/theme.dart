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

/// A color value used for PlantUML skinparam styling.
///
/// Stores an ARGB32 integer and provides [toHex] for PlantUML-compatible
/// hex color strings (e.g., `#FF0000`).
class Color {
  /// Creates a color from an ARGB32 integer value.
  const Color(this.aRGB32);

  /// The ARGB32 color value.
  final int aRGB32;

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
enum TextAlign {
  /// Align text to the left.
  left,
  /// Align text to the right.
  right,
  /// Align text to the center.
  center
}
