/// Available Mermaid server providers.
enum MermaidUmlProvider {
  mermaidink('https://mermaid.ink');

  /// The base URL of the provider.
  final String baseUrl;
  const MermaidUmlProvider(this.baseUrl);
}
