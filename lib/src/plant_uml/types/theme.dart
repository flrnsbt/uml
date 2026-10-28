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

  final String? externalDependency;
  const PlantUMLTheme([this.externalDependency]);
}

class Color {
  final int aRGB32;
  const Color(this.aRGB32);

  String toHex() {
    final rgb = aRGB32 & 0x00FFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}

enum TextAlign { left, right, center }
