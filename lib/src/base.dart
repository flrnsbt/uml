import 'dart:typed_data';

import 'package:uml/src/download/download.dart';

/// Base class for UML diagram generators (e.g., [PlantUml], [MermaidUml]).
abstract class Uml {
  /// Creates a UML diagram generator.
  const Uml();

  /// Encodes UML code
  String encode(String code);

  /// Builds a complete [UmlURL] from UML code.
  UmlURL getUrl(String code);
}

/// Base class for UML encoding parameters.
///
/// Subclasses define the theme, colors, and other styling options
/// specific to each UML type (PlantUML, Mermaid, etc.).
abstract class UmlEncodingParameters<U extends UmlTheme> {
  /// Creates encoding parameters for a UML diagram.
  const UmlEncodingParameters();

  /// Returns the theme for this encoding.
  U get theme;
}

/// Base class for UML parameters that wrap encoding parameters.
///
/// Provides provider, file type, and encoding configuration.
abstract class UmlParameters<P extends UmlEncodingParameters> {
  /// Creates UML parameters with encoding configuration.
  const UmlParameters();

  /// The UML server provider.
  UmlProvider get provider;

  /// The output file type (SVG or PNG).
  FileTypeBase get type;

  /// The encoding-specific parameters for this UML type.
  P get encodingParameters;
}

/// Base interface for file type enums.
///
/// Implemented by [PlantUMLFileType] and [MermaidUmlFileType].
abstract class FileTypeBase {
  /// The underlying [FileType] enum value.
  FileType get type;
}

/// A URL wrapper for UML diagrams that supports downloading and saving.
///
/// Provides convenient methods to download diagram bytes and save them
/// to a file on disk (native) or trigger a browser download (web).
class UmlURL {
  /// Creates a URL wrapper for a UML diagram.
  UmlURL(this.url, this.fileType);

  /// The full URL of the diagram.
  final String url;

  /// The file type of the diagram (SVG, PNG, etc.).
  final FileType fileType;

  /// Cached bytes from a previous download.
  Uint8List? _bytes;

  /// Cached bytes from a previous download, or `null` if not yet downloaded.
  Uint8List? get cachedBytes => _bytes;

  /// Downloads the diagram as raw bytes.
  ///
  /// If [forceFetch] is `false` (default), returns cached bytes if available.
  Future<Uint8List> download({bool forceFetch = false}) async {
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
    final bytes = await download(forceFetch: forceFetch);
    return saveUml(
      bytes,
      fileType: fileType,
      filename: filename,
      location: location,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UmlURL &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          fileType == other.fileType;

  @override
  int get hashCode => Object.hash(url, fileType);

  @override
  String toString() => 'UmlURL(url: $url, fileType: $fileType)';
}

/// A color value used for PlantUML skinparam styling.
///
/// Stores an ARGB32 integer and provides [toHex] for PlantUML-compatible
/// hex color strings (e.g., `#FF0000`).
class Color {
  /// Creates a color from an ARGB32 integer value.
  const Color(this.aRGB32);

  /// The ARGB32 color value.
  final int aRGB32;

  /// Converts this color to a PlantUML-compatible hex string (e.g., `#FF0000`).
  /// The alpha channel is ignored.
  String toHex() {
    final rgb = aRGB32 & 0x00FFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Color &&
          runtimeType == other.runtimeType &&
          aRGB32 == other.aRGB32;

  @override
  int get hashCode => aRGB32.hashCode;

  @override
  String toString() => 'Color(${aRGB32.toRadixString(16).padLeft(8, '0')})';
}

/// Text alignment options for PlantUML diagrams.
enum TextAlign {
  /// Align text to the left.
  left,

  /// Align text to the right.
  right,

  /// Align text to the center.
  center,
}

/// Base UML server providers.
abstract class UmlProvider {
  /// The base URL of the provider.
  String get baseUrl;

  /// All available UML server providers.
  List<UmlProvider> get all;
}

/// UML Theme
abstract class UmlTheme {
  /// The theme name
  String get themeName;

  /// The theme brightness
  UmlBrightness get brightness;

  /// All the themes available
  List<UmlTheme> get all;
}

/// UML Theme Brightness
enum UmlBrightness {
  /// Dark brightness
  dark,

  /// Light brightness
  light,
}
