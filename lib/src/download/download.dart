import 'dart:typed_data';

import 'io.dart' if (dart.library.js_interop) 'web.dart' as platform;

/// Supported file types for UML diagram exports.
enum FileType {
  /// Scalable Vector Graphics format.
  svg(isBitmap: false),

  /// Portable Network Graphics format.
  png,

  /// WebP image format.
  webp,

  /// JPEG image format.
  jpeg;

  const FileType({this.isBitmap = true});

  /// Whether the file type is a bitmap image.
  final bool isBitmap;

  /// Whether the file type is a vector image.
  bool get isVector => !isBitmap;
}

/// Result of saving a UML diagram to a file.
class SavedFile {
  /// Creates a saved file result with the file path and byte count.
  const SavedFile({required this.path, required this.bytesWritten});

  /// The absolute path to the saved file.
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
Future<Uint8List> downloadUmlURL(String url) => platform.downloadUmlURL(url);

/// Saves a UML diagram from a URL to a file.
Future<SavedFile> saveUml(
  Uint8List bytes, {
  required FileType fileType,
  String? filename,
  String? location,
}) => platform.saveUml(
  bytes,
  fileType: fileType,
  filename: filename,
  location: location,
);
