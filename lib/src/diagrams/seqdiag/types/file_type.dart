import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Seqdiag diagram exports via Kroki.
enum SeqdiagFileType implements FileTypeBase {
  svg(FileType.svg),
  png(FileType.png),
  pdf(FileType.pdf),
  ;

  const SeqdiagFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
