/// Available Mermaid server providers.
enum MermaidUmlProvider {
  mermaidink('https://mermaid.ink');

  const MermaidUmlProvider(this.baseUrl);

  /// The base URL of the provider.
  final String baseUrl;
}
