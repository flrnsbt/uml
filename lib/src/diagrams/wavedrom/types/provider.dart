import 'package:uml/uml.dart';

/// Available Kroki server providers for Wavedrom diagrams.
enum WavedromProvider implements UmlProvider {
  kroki('https://kroki.io/wavedrom');

  const WavedromProvider(this.baseUrl);

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
