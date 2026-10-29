import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Rackdiag diagram exports via Kroki.
enum RackdiagFileType implements FileTypeBase {
  svg(FileType.svg),
  png(FileType.png),
  pdf(FileType.pdf),
  ;

  const RackdiagFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
