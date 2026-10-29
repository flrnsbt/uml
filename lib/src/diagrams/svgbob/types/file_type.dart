import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Svgbob diagram exports via Kroki.
enum SvgbobFileType implements FileTypeBase {
  svg(FileType.svg),
  ;

  const SvgbobFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
