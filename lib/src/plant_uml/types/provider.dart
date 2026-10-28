import 'package:uml/uml.dart';

/// Available PlantUML server providers.
enum PlantUMLProvider implements UmlProvider {
  /// The PlantText PlantUML server provider.
  planttext('https://uml.planttext.com/plantuml'),

  /// The official PlantUML.com server provider.
  plantuml('https://www.plantuml.com/plantuml');

  const PlantUMLProvider(this.baseUrl);

  /// The base URL of the provider.
  @override
  final String baseUrl;

  @override
  List<PlantUMLProvider> get all => values;
}
