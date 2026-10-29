import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Actdiag diagram exports via Kroki.
enum ActdiagFileType implements FileTypeBase {
  svg(FileType.svg),
  png(FileType.png),
  pdf(FileType.pdf),
  ;

  const ActdiagFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
