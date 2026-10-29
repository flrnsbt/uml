import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for C4Plantuml diagram exports via Kroki.
enum C4PlantumlFileType implements FileTypeBase {
  svg(FileType.svg),
  png(FileType.png),
  pdf(FileType.pdf),
  txt(FileType.txt),
  ;

  const C4PlantumlFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
