import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Mermaid diagram exports.
///
/// Each file type represents a different output format. Not all
/// Mermaid providers support all file types; check
/// [MermaidUmlProvider.supportedFileTypes].
///
/// Provider support:
/// - Mermaid.ink: SVG, PNG, WebP, JPEG
/// - Kroki: SVG, PNG, PDF
enum MermaidUmlFileType implements FileTypeBase {
  /// Scalable Vector Graphics format.
  ///
  /// A vector graphics format that scales without loss of quality.
  /// Supported by all Mermaid providers.
  svg(FileType.svg),

  /// Portable Network Graphics format.
  ///
  /// A lossless bitmap image format.
  /// Supported by all Mermaid providers.
  /// When used with Mermaid.ink, adds a `?type=png` query parameter.
  png(FileType.png, query: 'type=png'),

  /// WebP image format.
  ///
  /// A modern bitmap image format with excellent compression.
  /// Supported by Mermaid.ink only.
  /// When used with Mermaid.ink, adds a `?type=webp` query parameter.
  webp(FileType.webp, query: 'type=webp'),

  /// JPEG image format.
  ///
  /// A lossy bitmap image format suitable for photographs.
  /// Supported by Mermaid.ink only.
  /// When used with Mermaid.ink, adds a `?type=jpeg` query parameter.
  jpeg(FileType.jpeg, query: 'type=jpeg'),

  /// PDF document format.
  ///
  /// A portable document format suitable for printing.
  /// Supported by Kroki only.
  pdf(FileType.pdf);

  const MermaidUmlFileType(this.type, {this.query});

  /// The underlying [FileType] enum value.
  @override
  final FileType type;

  /// An optional query parameter for the URL (used by Mermaid.ink).
  ///
  /// This is added to the URL when using Mermaid.ink for bitmap formats
  /// to specify the image type in the query string.
  final String? query;

  /// Returns the URL path segment for this file type.
  ///
  /// Returns the file type name (e.g., "svg", "png", "webp", "jpeg", "pdf").
  /// Providers may override this for custom path logic.
  @override
  String getPath() => type.name;
}
