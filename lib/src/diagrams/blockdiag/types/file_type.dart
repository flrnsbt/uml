import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Blockdiag diagram exports via Kroki.
enum BlockdiagFileType implements FileTypeBase {
  svg(FileType.svg),
  png(FileType.png),
  pdf(FileType.pdf),
  ;

  const BlockdiagFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
