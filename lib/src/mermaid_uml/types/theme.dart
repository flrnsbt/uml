import 'package:uml/src/base.dart';

/// Built-in Mermaid themes.
enum MermaidUmlTheme implements UmlTheme {
  /// The default light theme.
  default_('default', UmlBrightness.light),

  /// A green-themed forest appearance.
  forest('forest', UmlBrightness.light),

  /// A dark-themed appearance.
  dark('dark', UmlBrightness.dark),

  /// A neutral, grayscale appearance.
  neutral('neutral', UmlBrightness.light);

  const MermaidUmlTheme(this.themeName, this.brightness);

  /// The theme name used by the Mermaid server.
  @override
  final String themeName;

  @override
  final UmlBrightness brightness;

  @override
  List<MermaidUmlTheme> get all => values;
}
