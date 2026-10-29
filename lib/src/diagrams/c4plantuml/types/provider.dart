import 'package:uml/uml.dart';

/// Available Kroki server providers for C4Plantuml diagrams.
enum C4PlantumlProvider implements UmlProvider {
  kroki('https://kroki.io/c4plantuml');

  const C4PlantumlProvider(this.baseUrl);

  @override
  final String baseUrl;

  @override
  List<FileType> get supportedFileTypes => const [
        FileType.svg,
        FileType.png,
        FileType.pdf,
        FileType.txt,
      ];

  @override
  bool supportsFileType(FileType type) => supportedFileTypes.contains(type);

  @override
  String getPathForFileType<FT extends FileTypeBase>(FT fileType) =>
      fileType.getPath();
}
