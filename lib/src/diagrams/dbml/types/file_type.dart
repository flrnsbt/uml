import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Dbml diagram exports via Kroki.
enum DbmlFileType implements FileTypeBase {
  svg(FileType.svg),
  ;

  const DbmlFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
