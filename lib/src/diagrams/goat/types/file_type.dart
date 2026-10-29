import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Goat diagram exports via Kroki.
enum GoatFileType implements FileTypeBase {
  svg(FileType.svg),
  ;

  const GoatFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
