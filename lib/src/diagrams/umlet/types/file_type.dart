import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Umlet diagram exports via Kroki.
enum UmletFileType implements FileTypeBase {
  svg(FileType.svg),
  png(FileType.png),
  jpeg(FileType.jpeg),
  ;

  const UmletFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
