/// Built-in Mermaid themes.
enum MermaidUmlTheme {
  /// The default light theme.
  default_('default'),

  /// A green-themed forest appearance.
  forest('forest'),

  /// A dark-themed appearance.
  dark('dark'),

  /// A neutral, grayscale appearance.
  neutral('neutral');

  const MermaidUmlTheme(this.name);

  /// The theme name used by the Mermaid server.
  final String name;
}
