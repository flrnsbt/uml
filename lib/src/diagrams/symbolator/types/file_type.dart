import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Symbolator diagram exports via Kroki.
enum SymbolatorFileType implements FileTypeBase {
  svg(FileType.svg),
  ;

  const SymbolatorFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
