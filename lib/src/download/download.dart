import 'dart:typed_data';

import 'io.dart' if (dart.library.html) 'web.dart' as platform;

/// Supported file types for UML diagram exports.
enum FileType { svg, png, webp, jpeg }

/// Result of saving a UML diagram to a file.
class SavedFile {
  final String path;
  final int bytesWritten;

  const SavedFile({required this.path, required this.bytesWritten});

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
