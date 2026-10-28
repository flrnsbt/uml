/// Available PlantUML server providers.
enum PlantUMLProvider {
  planttext('https://uml.planttext.com/plantuml/'),
  plantuml('https://www.plantuml.com/plantuml/');

  /// The base URL of the provider.
  final String baseUrl;
  const PlantUMLProvider(this.baseUrl);
}
