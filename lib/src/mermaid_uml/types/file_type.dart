import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

enum MermaidUmlFileType implements FileTypeBase {
  svg(FileType.svg, path: 'svg'),
  png(FileType.png, query: 'type=png'),
  webp(FileType.webp, query: 'type=webp'),
  jpeg(FileType.jpeg, query: 'type=jpeg');

  static MermaidUmlFileType get default_ => values.first;

  final String path;
  @override
  final FileType type;
  final String? query;
  const MermaidUmlFileType(this.type, {this.path = 'img', this.query});
}
