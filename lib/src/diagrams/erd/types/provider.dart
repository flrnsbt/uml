import 'package:uml/uml.dart';

/// Available Kroki server providers for Erd diagrams.
enum ErdProvider implements UmlProvider {
  kroki('https://kroki.io/erd');

  const ErdProvider(this.baseUrl);

  @override
  final String baseUrl;

  @override
  List<FileType> get supportedFileTypes => const [
        FileType.svg,
        FileType.png,
        FileType.jpeg,
        FileType.pdf,
      ];

  @override
  bool supportsFileType(FileType type) => supportedFileTypes.contains(type);

  @override
  String getPathForFileType<FT extends FileTypeBase>(FT fileType) =>
      fileType.getPath();
}
