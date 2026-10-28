import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for PlantUML diagram exports.
enum PlantUMLFileType implements FileTypeBase {
  svg(FileType.svg),
  png(FileType.png);

  @override
  final FileType type;

  const PlantUMLFileType(this.type);
}
