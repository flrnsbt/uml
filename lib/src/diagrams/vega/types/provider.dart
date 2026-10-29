import 'package:uml/uml.dart';

/// Available Kroki server providers for Vega diagrams.
enum VegaProvider implements UmlProvider {
  kroki('https://kroki.io/vega');

  const VegaProvider(this.baseUrl);

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
