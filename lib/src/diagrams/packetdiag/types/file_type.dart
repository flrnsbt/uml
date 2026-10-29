import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Packetdiag diagram exports via Kroki.
enum PacketdiagFileType implements FileTypeBase {
  svg(FileType.svg),
  png(FileType.png),
  pdf(FileType.pdf),
  ;

  const PacketdiagFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
