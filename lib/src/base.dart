import 'dart:typed_data';

import 'package:uml/src/download/download.dart';

/// Base class for UML encoding parameters.
///
/// Subclasses define the theme, colors, and other styling options
/// specific to each UML type (PlantUML, Mermaid, etc.).
abstract class UmlEncodingParameters {
  const UmlEncodingParameters();
}

/// Base class for UML parameters that wrap encoding parameters.
///
/// Provides provider, file type, and encoding configuration.
abstract class UmlParameters<P extends UmlEncodingParameters> {
  const UmlParameters();
  P get encodingParameters;
}

/// Base interface for file type enums.
///
/// Implemented by [PlantUMLFileType] and [MermaidUmlFileType].
abstract class FileTypeBase {
  FileType get type;
}

/// A URL wrapper for UML diagrams that supports downloading and saving.
///
/// Provides convenient methods to download diagram bytes and save them
/// to a file on disk (native) or trigger a browser download (web).
class UmlURL {
  UmlURL(this.url, this.fileType);

  /// The full URL of the diagram.
  final String url;

  /// The file type of the diagram (SVG, PNG, etc.).
  final FileType fileType;

  /// Cached bytes from a previous download.
  Uint8List? _bytes;

  /// Downloads the diagram as raw bytes.
  ///
  /// If [forceFetch] is `false` (default), returns cached bytes if available.
  Future<Uint8List> download([bool forceFetch = false]) async {
    if (!forceFetch && _bytes != null) {
      return _bytes!;
    }
    return _bytes = await downloadUmlURL(url);
  }

  /// Saves the diagram to a file.
  ///
  /// On native platforms, saves to [location] (defaults to Downloads folder).
  /// On web, triggers a browser download. The [location] parameter is ignored on web.
  ///
  /// If [forceFetch] is `true`, re-downloads the bytes even if cached.
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

  @override
  String toString() => 'UmlURL(url: $url, fileType: $fileType)';
}
