import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Mermaid diagram exports.
enum MermaidUmlFileType implements FileTypeBase {
  svg(FileType.svg, path: 'svg'),
  png(FileType.png, query: 'type=png'),
  webp(FileType.webp, query: 'type=webp'),
  jpeg(FileType.jpeg, query: 'type=jpeg');

  /// Returns the first file type (SVG) as the default.
  static MermaidUmlFileType get default_ => values.first;

  /// The URL path segment for this file type.
  final String path;
  @override
  final FileType type;
  /// An optional query parameter for the URL.
  final String? query;
  const MermaidUmlFileType(this.type, {this.path = 'img', this.query});
}
