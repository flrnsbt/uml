import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for PlantUML diagram exports.
///
/// Each file type represents a different output format. Not all
/// PlantUML providers support all file types; check
/// [PlantUMLProvider.supportedFileTypes].
///
/// Currently, all PlantUML providers support: SVG, PNG, and TXT.
enum PlantUMLFileType implements FileTypeBase {
  /// Scalable Vector Graphics format.
  ///
  /// A vector graphics format that scales without loss of quality.
  /// Suitable for diagrams that need to be resized or printed at high resolution.
  svg(FileType.svg),

  /// Portable Network Graphics format.
  ///
  /// A lossless bitmap image format.
  /// Suitable for most use cases where a raster image is needed.
  png(FileType.png),

  /// Plain text format (ASCII art).
  ///
  /// Generates ASCII art diagrams, primarily for sequence diagrams.
  /// Useful for embedding diagrams in plain text environments.
  txt(FileType.txt);

  const PlantUMLFileType(this.type);

  /// The underlying [FileType] enum value.
  @override
  final FileType type;

  /// Returns the URL path segment for this file type.
  ///
  /// All PlantUML providers use the same path structure: the file type name
  /// (e.g., "svg", "png", "txt").
  @override
  String getPath() => type.name;
}
