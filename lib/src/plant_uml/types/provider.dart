enum PlantUMLProvider {
  planttext('https://uml.planttext.com/plantuml/'),
  plantuml('https://www.plantuml.com/plantuml/');

  final String baseUrl;
  const PlantUMLProvider(this.baseUrl);
}
