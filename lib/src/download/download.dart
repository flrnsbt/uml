import 'dart:typed_data';

import 'io.dart' if (dart.library.js_interop) 'web.dart' as platform;

/// Supported file types for UML diagram exports.
///
/// Each file type represents a different output format for diagrams.
/// Not all providers support all file types; check [UmlProvider.supportedFileTypes].
enum FileType {
  /// Scalable Vector Graphics format.
  ///
  /// A vector graphics format that scales without loss of quality.
  /// Supported by all providers.
  svg(isBitmap: false),

  /// Portable Network Graphics format.
  ///
  /// A lossless bitmap image format.
  /// Supported by all providers.
  png,

  /// WebP image format.
  ///
  /// A modern bitmap image format with excellent compression.
  /// Supported by Mermaid.ink, not by Kroki.
  webp,

  /// JPEG image format.
  ///
  /// A lossy bitmap image format suitable for photographs.
  /// Supported by Mermaid.ink, not by Kroki.
  jpeg,

  /// PDF document format.
  ///
  /// A portable document format suitable for printing.
  /// Supported by Kroki for Mermaid, not by Mermaid.ink.
  pdf(reader: FileReader.pdf),

  /// Plain text format (ASCII art).
  ///
  /// Generates ASCII art diagrams, primarily for sequence diagrams.
  /// Supported by PlantUML providers.
  txt(reader: FileReader.text),
  ;

  const FileType({this.isBitmap = true, this.reader = FileReader.image});

  /// Whether the file type is a bitmap image (lossy or lossless compression).
  ///
  /// Bitmap formats include PNG, WebP, JPEG, and PDF.
  /// Vector formats include SVG.
  final bool isBitmap;

  final FileReader reader;

  /// Whether the file type is a vector image (scales without loss of quality).
  ///
  /// Currently only SVG is a vector format.
  bool get isVector => !isBitmap;
}

enum FileReader {
  image,
  text,
  pdf;
}

/// Result of saving a UML diagram to a file.
///
/// Contains the file path and the number of bytes written.
class SavedFile {
  /// Creates a saved file result with the file path and byte count.
  const SavedFile({required this.path, required this.bytesWritten});

  /// The absolute path to the saved file.
  ///
  /// On web platforms, this may be a placeholder or `null`-equivalent value
  /// since browser downloads don't provide file paths.
  final String path;

  /// The number of bytes written to the file.
  final int bytesWritten;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedFile &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          bytesWritten == other.bytesWritten;

  @override
  int get hashCode => Object.hash(path, bytesWritten);

  @override
  String toString() => 'SavedFile(path: $path, bytes: $bytesWritten)';
}

/// Downloads the binary content of a UML URL.
///
/// Makes an HTTP GET request to the specified URL and returns the response body as bytes.
///
/// This function is platform-agnostic and delegates to the appropriate implementation
/// for native (IO) or web (JS interop) platforms.
///
/// Returns the diagram bytes as a [Uint8List].
Future<Uint8List> downloadUmlURL(String url) => platform.downloadUmlURL(url);

/// Saves a UML diagram from bytes to a file.
///
/// On native platforms, writes the bytes to a file in the specified [location]
/// (defaults to the Downloads folder). If [filename] is not provided, a default
/// filename is generated based on the [fileType].
///
/// On web platforms, triggers a browser download. The [location] parameter is ignored
/// on web, and the [filename] is used as the download filename.
///
/// Returns a [SavedFile] object containing the file path and bytes written.
Future<SavedFile> saveUml(
  Uint8List bytes, {
  required FileType fileType,
  String? filename,
  String? location,
}) =>
    platform.saveUml(
      bytes,
      fileType: fileType,
      filename: filename,
      location: location,
    );
