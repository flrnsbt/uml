import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Wireviz diagram exports via Kroki.
enum WirevizFileType implements FileTypeBase {
  svg(FileType.svg),
  png(FileType.png),
  ;

  const WirevizFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
