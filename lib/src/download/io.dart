import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import 'download.dart';

/// Downloads the binary content of a UML URL on native platforms.
/// Throws an [Exception] if the HTTP response status indicates an error.
Future<Uint8List> downloadUmlURL(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to download: ${response.statusCode} ${response.reasonPhrase}',
      );
    }
    final buffer = BytesBuilder(copy: false);
    await response.forEach(buffer.add);
    return buffer.takeBytes();
  } finally {
    client.close(force: true);
  }
}

/// Returns the platform-specific downloads directory path.
String _getDefaultPath() {
  switch (Platform.operatingSystem) {
    case 'macos':
    case 'darwin':
    case 'linux':
      final home = Platform.environment['HOME'];
      if (home != null && home.isNotEmpty) {
        return p.join(home, 'Downloads');
      }
      return Directory.current.path;
    case 'windows':
      final userProfile =
          Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
      if (userProfile != null && userProfile.isNotEmpty) {
        return p.join(userProfile, 'Downloads');
      }
      return Directory.current.path;
    default:
      return Directory.current.path;
  }
}

/// Saves a UML diagram from a URL to the downloads folder on native platforms.
Future<SavedFile> saveUml(
  Uint8List bytes, {
  required FileType fileType,
  String? filename,
  String? location,
}) async {
  // Use FileType to determine the file extension
  final extension = fileType.name;

  // Build the full file path, stripping redundant extension if already present
  var name = filename ?? 'diagram';
  final extWithDot = '.$extension';
  final lowerName = name.toLowerCase();
  if (lowerName.endsWith(extWithDot)) {
    name = name.substring(0, name.length - extWithDot.length);
  } else if (extension == 'jpeg' && lowerName.endsWith('.jpg')) {
    name = name.substring(0, name.length - 4);
  }

  final dir = location ?? _getDefaultPath();
  await Directory(dir).create(recursive: true);
  final fullPath = p.join(dir, '$name.$extension');

  final file = File(fullPath);
  await file.writeAsBytes(bytes, flush: true);

  return SavedFile(path: fullPath, bytesWritten: bytes.length);
}
