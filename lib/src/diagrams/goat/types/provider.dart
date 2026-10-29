import 'package:uml/uml.dart';

/// Available Kroki server providers for Goat diagrams.
enum GoatProvider implements UmlProvider {
  kroki('https://kroki.io/goat');

  const GoatProvider(this.baseUrl);

  @override
  final String baseUrl;

  @override
  List<FileType> get supportedFileTypes => const [
        FileType.svg,
      ];

  @override
  bool supportsFileType(FileType type) => supportedFileTypes.contains(type);

  @override
  String getPathForFileType<FT extends FileTypeBase>(FT fileType) =>
      fileType.getPath();
}
