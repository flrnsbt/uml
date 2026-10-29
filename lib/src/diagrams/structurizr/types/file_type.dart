import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Structurizr diagram exports via Kroki.
enum StructurizrFileType implements FileTypeBase {
  svg(FileType.svg),
  png(FileType.png),
  pdf(FileType.pdf),
  txt(FileType.txt),
  ;

  const StructurizrFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
