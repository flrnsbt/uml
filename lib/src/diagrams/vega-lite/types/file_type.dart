import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for VegaLite diagram exports via Kroki.
enum VegaLiteFileType implements FileTypeBase {
  svg(FileType.svg),
  png(FileType.png),
  pdf(FileType.pdf),
  ;

  const VegaLiteFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
