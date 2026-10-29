import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Bytefield diagram exports via Kroki.
enum BytefieldFileType implements FileTypeBase {
  svg(FileType.svg),
  ;

  const BytefieldFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
