import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Pikchr diagram exports via Kroki.
enum PikchrFileType implements FileTypeBase {
  svg(FileType.svg),
  ;

  const PikchrFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
