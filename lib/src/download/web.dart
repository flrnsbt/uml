import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

import 'download.dart';

/// Downloads the binary content of a UML URL on web platforms.
Future<Uint8List> downloadUmlURL(String url) async {
  final response = await window.fetch(url.toJS).toDart;
  if (!response.ok) {
    throw Exception(
      'Failed to download: ${response.status} ${response.statusText}',
    );
  }
  final buffer = await response.arrayBuffer().toDart;
  return buffer.toDart.asUint8List();
}

/// Saves a UML diagram by triggering a browser download on web platforms.
/// Returns a [SavedFile] with the intended filename, as the actual save location
/// is controlled by the browser. The [location] parameter is ignored on web.
Future<SavedFile> saveUml(
  Uint8List bytes, {
  required FileType fileType,
  String? filename,
  String? location,
}) async {
  // Use FileType to determine the file extension
  final extension = fileType.name;

  // Build the filename, stripping redundant extension if already present
  var name = filename ?? 'diagram';
  final extWithDot = '.$extension';
  final lowerName = name.toLowerCase();
  if (lowerName.endsWith(extWithDot)) {
    name = name.substring(0, name.length - extWithDot.length);
  } else if (extension == 'jpeg' && lowerName.endsWith('.jpg')) {
    name = name.substring(0, name.length - 4);
  }
  final fileName = '$name.$extension';

  // Trigger browser download using a Blob and anchor element
  final blobParts = [bytes.toJS].toJS;
  final blob = Blob(blobParts);
  final blobUrl = URL.createObjectURL(blob);

  final anchor = document.createElement('a') as HTMLAnchorElement;
  anchor.href = blobUrl;
  anchor.download = fileName;
  anchor.style.display = 'none';
  document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  URL.revokeObjectURL(blobUrl);

  // On web, we can't know the actual path, so return a virtual path (filename only)
  return SavedFile(path: fileName, bytesWritten: bytes.length);
}
