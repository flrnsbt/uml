import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Wavedrom diagram exports via Kroki.
enum WavedromFileType implements FileTypeBase {
  svg(FileType.svg),
  ;

  const WavedromFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
