import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for D2 diagram exports via Kroki.
enum D2FileType implements FileTypeBase {
  svg(FileType.svg),
  ;

  const D2FileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
