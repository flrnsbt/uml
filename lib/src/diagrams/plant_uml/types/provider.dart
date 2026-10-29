import 'package:uml/uml.dart';

/// Available PlantUML server providers.
///
/// Each provider renders PlantUML diagrams and may support different
/// file types and have different URL structures.
///
/// All PlantUML providers currently support: SVG, PNG, and TXT.
enum PlantUMLProvider implements UmlProvider {
  /// The PlantText PlantUML server provider.
  ///
  /// Base URL: https://uml.planttext.com/plantuml
  ///
  /// Supports: SVG, PNG, TXT
  planttext('https://uml.planttext.com/plantuml'),

  /// The official PlantUML.com server provider.
  ///
  /// Base URL: https://www.plantuml.com/plantuml
  ///
  /// Supports: SVG, PNG, TXT
  plantuml('https://www.plantuml.com/plantuml'),

  /// The Kroki diagram rendering service (supports PlantUML and many other diagram types).
  ///
  /// Base URL: https://kroki.io/plantuml
  ///
  /// Supports: SVG, PNG, TXT
  ///
  /// Kroki is a free public service that supports multiple diagram types
  /// including PlantUML, Mermaid, Graphviz, and more.
  kroki('https://kroki.io/plantuml');

  const PlantUMLProvider(this.baseUrl);

  /// The base URL of the provider.
  @override
  final String baseUrl;

  @override
  List<FileType> get supportedFileTypes => const [
        FileType.svg,
        FileType.png,
        FileType.txt,
      ];

  @override
  bool supportsFileType(FileType type) => supportedFileTypes.contains(type);

  @override
  String getPathForFileType<FT extends FileTypeBase>(FT fileType) =>
      fileType.getPath();
}
