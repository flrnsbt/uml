import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

enum PlantUMLFileType implements FileTypeBase {
  svg(FileType.svg),
  png(FileType.png);

  @override
  final FileType type;

  const new(this.type);
}
