import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for PlantUML diagram exports.
enum PlantUMLFileType implements FileTypeBase {
  /// Scalable Vector Graphics format.
  svg(FileType.svg),
  /// Portable Network Graphics format.
  png(FileType.png);

  const PlantUMLFileType(this.type);

  @override
  final FileType type;
}
