import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Nwdiag diagram exports via Kroki.
enum NwdiagFileType implements FileTypeBase {
  svg(FileType.svg),
  png(FileType.png),
  pdf(FileType.pdf),
  ;

  const NwdiagFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
