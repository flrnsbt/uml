import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Mermaid diagram exports.
enum MermaidUmlFileType implements FileTypeBase {
  /// Scalable Vector Graphics format.
  svg(FileType.svg, path: 'svg'),
  /// Portable Network Graphics format.
  png(FileType.png, query: 'type=png'),
  /// WebP image format.
  webp(FileType.webp, query: 'type=webp'),
  /// JPEG image format.
  jpeg(FileType.jpeg, query: 'type=jpeg');

  const MermaidUmlFileType(this.type, {this.path = 'img', this.query});

  /// Returns the first file type (SVG) as the default.
  static MermaidUmlFileType get default_ => values.first;

  /// The URL path segment for this file type.
  final String path;
  @override
  final FileType type;

  /// An optional query parameter for the URL.
  final String? query;
}
