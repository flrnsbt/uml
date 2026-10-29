import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Ditaa diagram exports via Kroki.
enum DitaaFileType implements FileTypeBase {
  svg(FileType.svg),
  png(FileType.png),
  ;

  const DitaaFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
