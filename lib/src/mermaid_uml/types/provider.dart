import 'package:uml/uml.dart';

/// Available Mermaid server providers.
enum MermaidUmlProvider implements UmlProvider {
  /// The Mermaid.ink server provider.
  mermaidink('https://mermaid.ink');

  const MermaidUmlProvider(this.baseUrl);

  /// The base URL of the provider.
  @override
  final String baseUrl;

  @override
  List<MermaidUmlProvider> get all => values;
}
