/// Built-in Mermaid themes.
enum MermaidUmlTheme {
  default_('default'),
  forest('forest'),
  dark('dark'),
  neutral('neutral');

  const MermaidUmlTheme(this.name);

  /// The theme name used by the Mermaid server.
  final String name;
}
