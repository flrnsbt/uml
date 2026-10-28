import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for PlantUML diagram exports.
enum PlantUMLFileType implements FileTypeBase {
  svg(FileType.svg),
  png(FileType.png);

  const PlantUMLFileType(this.type);

  @override
  final FileType type;
}
