import 'dart:typed_data';

import 'package:uml/src/download/download.dart';

abstract class UmlParameters<P extends UmlEncodingParameters> {
  const UmlParameters();
  P get encodingParameters;
}

abstract class UmlEncodingParameters {
  const UmlEncodingParameters();
}

abstract class FileTypeBase {
  FileType get type;
}

/// A URL wrapper for UML diagrams that supports downloading and saving.
class UmlURL {
  final String url;
  final FileType fileType;

  UmlURL(this.url, this.fileType);

  Uint8List? _bytes;

  /// Downloads the diagram as raw bytes.
  Future<Uint8List> download([bool forceFetch = false]) async {
    if (!forceFetch && _bytes != null) {
      return _bytes!;
    }
    return _bytes = await downloadUmlURL(url);
  }

  /// Saves the diagram to a file.
  Future<SavedFile> save({
    String? filename,
    String? location,
    bool forceFetch = false,
  }) async {
    Uint8List? bytes;
    if (!forceFetch && _bytes != null) {
      bytes = _bytes!;
    }

    return saveUml(
      bytes ??= _bytes = await download(),
      fileType: fileType,
      filename: filename,
      location: location,
    );
  }
}
