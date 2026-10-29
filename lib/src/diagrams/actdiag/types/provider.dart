import 'package:uml/uml.dart';

/// Available Kroki server providers for Actdiag diagrams.
enum ActdiagProvider implements UmlProvider {
  kroki('https://kroki.io/actdiag');

  const ActdiagProvider(this.baseUrl);

  @override
  final String baseUrl;

  @override
  List<FileType> get supportedFileTypes => const [
        FileType.svg,
        FileType.png,
        FileType.pdf,
      ];

  @override
  bool supportsFileType(FileType type) => supportedFileTypes.contains(type);

  @override
  String getPathForFileType<FT extends FileTypeBase>(FT fileType) =>
      fileType.getPath();
}
