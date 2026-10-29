import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Vega diagram exports via Kroki.
enum VegaFileType implements FileTypeBase {
  svg(FileType.svg),
  png(FileType.png),
  pdf(FileType.pdf),
  ;

  const VegaFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
