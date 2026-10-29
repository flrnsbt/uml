import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Erd diagram exports via Kroki.
enum ErdFileType implements FileTypeBase {
  svg(FileType.svg),
  png(FileType.png),
  jpeg(FileType.jpeg),
  pdf(FileType.pdf),
  ;

  const ErdFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
