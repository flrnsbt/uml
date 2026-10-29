import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Lini diagram exports via Kroki.
enum LiniFileType implements FileTypeBase {
  svg(FileType.svg),
  ;

  const LiniFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
