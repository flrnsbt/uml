import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Nomnoml diagram exports via Kroki.
enum NomnomlFileType implements FileTypeBase {
  svg(FileType.svg),
  ;

  const NomnomlFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
