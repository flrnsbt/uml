import 'package:uml/uml.dart';

/// Available Mermaid server providers.
///
/// Each provider renders Mermaid diagrams and may support different
/// file types and have different URL structures.
///
/// Provider support:
/// - Mermaid.ink: SVG, PNG, WebP, JPEG
/// - Kroki: SVG, PNG
enum MermaidUmlProvider implements UmlProvider {
  /// The Mermaid.ink server provider.
  ///
  /// Base URL: https://mermaid.ink
  ///
  /// Supports: SVG, PNG, WebP, JPEG
  ///
  /// Mermaid.ink uses a custom URL structure:
  /// - SVG files use `/svg/` path
  /// - Bitmap files (PNG, WebP, JPEG) use `/img/` path with query parameters
  mermaidink('https://mermaid.ink'),

  /// The Kroki diagram rendering service (supports Mermaid and many other diagram types).
  ///
  /// Base URL: https://kroki.io/mermaid
  ///
  /// Supports: SVG, PNG
  ///
  /// Kroki uses standard URL paths (e.g., `/svg/`, `/png/`)
  /// and deflate + base64url encoding.
  ///
  /// Kroki is a free public service that supports multiple diagram types
  /// including PlantUML, Mermaid, Graphviz, and more.
  kroki('https://kroki.io/mermaid');

  const MermaidUmlProvider(this.baseUrl);

  /// The base URL of the provider.
  @override
  final String baseUrl;

  @override
  List<FileType> get supportedFileTypes {
    switch (this) {
      case MermaidUmlProvider.mermaidink:
        return const [
          FileType.svg,
          FileType.png,
          FileType.webp,
          FileType.jpeg,
        ];
      case MermaidUmlProvider.kroki:
        return const [
          FileType.svg,
          FileType.png,
        ];
    }
  }

  @override
  bool supportsFileType(FileType type) => supportedFileTypes.contains(type);

  @override
  String getPathForFileType<FT extends FileTypeBase>(FT fileType) {
    if (this == MermaidUmlProvider.mermaidink) {
      // Mermaid.ink uses /svg/ for SVG, /img/ for PNG/WebP/JPEG with query params
      return fileType.type == FileType.svg ? 'svg' : 'img';
    }
    // Kroki uses standard paths (delegates to file type's getPath)
    return fileType.getPath();
  }
}
