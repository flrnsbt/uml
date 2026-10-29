import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Tikz diagram exports via Kroki.
enum TikzFileType implements FileTypeBase {
  svg(FileType.svg),
  png(FileType.png),
  jpeg(FileType.jpeg),
  pdf(FileType.pdf),
  ;

  const TikzFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
