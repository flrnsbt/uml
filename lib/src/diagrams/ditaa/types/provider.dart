import 'package:uml/uml.dart';

/// Available Kroki server providers for Ditaa diagrams.
enum DitaaProvider implements UmlProvider {
  kroki('https://kroki.io/ditaa');

  const DitaaProvider(this.baseUrl);

  @override
  final String baseUrl;

  @override
  List<FileType> get supportedFileTypes => const [
        FileType.svg,
        FileType.png,
      ];

  @override
  bool supportsFileType(FileType type) => supportedFileTypes.contains(type);

  @override
  String getPathForFileType<FT extends FileTypeBase>(FT fileType) =>
      fileType.getPath();
}
