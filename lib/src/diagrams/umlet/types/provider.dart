import 'package:uml/uml.dart';

/// Available Kroki server providers for Umlet diagrams.
enum UmletProvider implements UmlProvider {
  kroki('https://kroki.io/umlet');

  const UmletProvider(this.baseUrl);

  @override
  final String baseUrl;

  @override
  List<FileType> get supportedFileTypes => const [
        FileType.svg,
        FileType.png,
        FileType.jpeg,
      ];

  @override
  bool supportsFileType(FileType type) => supportedFileTypes.contains(type);

  @override
  String getPathForFileType<FT extends FileTypeBase>(FT fileType) =>
      fileType.getPath();
}
