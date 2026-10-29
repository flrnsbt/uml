import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Excalidraw diagram exports via Kroki.
enum ExcalidrawFileType implements FileTypeBase {
  svg(FileType.svg),
  ;

  const ExcalidrawFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
