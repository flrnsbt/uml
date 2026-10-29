import 'package:uml/uml.dart';

/// Available Kroki server providers for D2 diagrams.
enum D2Provider implements UmlProvider {
  kroki('https://kroki.io/d2');

  const D2Provider(this.baseUrl);

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
