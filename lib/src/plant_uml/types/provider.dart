/// Available PlantUML server providers.
enum PlantUMLProvider {
  /// The PlantText PlantUML server provider.
  planttext('https://uml.planttext.com/plantuml/'),
  /// The official PlantUML.com server provider.
  plantuml('https://www.plantuml.com/plantuml/');

  const PlantUMLProvider(this.baseUrl);

  /// The base URL of the provider.
  final String baseUrl;
}
