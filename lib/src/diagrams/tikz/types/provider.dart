import 'package:uml/uml.dart';

/// Available Kroki server providers for Tikz diagrams.
enum TikzProvider implements UmlProvider {
  kroki('https://kroki.io/tikz');

  const TikzProvider(this.baseUrl);

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
