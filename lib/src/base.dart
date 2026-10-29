import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:uml/src/download/download.dart';

/// Encodes binary data using PlantUML's custom base64 alphabet.
///
/// This base64 variant is used by PlantUML for encoding
/// deflate-compressed diagram source in diagram URLs.
String plantUmlBase64Encode(List<int> data) {
  const plantUml64 =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_';
  final sb = StringBuffer();
  for (var i = 0; i < data.length; i += 3) {
    final c1 = data[i];
    final c2 = i + 1 < data.length ? data[i + 1] : 0;
    final c3 = i + 2 < data.length ? data[i + 2] : 0;
    sb.write(plantUml64[c1 >> 2]);
    sb.write(plantUml64[((c1 & 0x3) << 4) | (c2 >> 4)]);
    sb.write(plantUml64[((c2 & 0xF) << 2) | (c3 >> 6)]);
    sb.write(plantUml64[c3 & 0x3F]);
  }
  return sb.toString();
}

/// Encodes diagram source text for Kroki diagram URLs.
///
/// Kroki expects diagram source to be:
/// 1. UTF-8 encoded
/// 2. Compressed using Deflate (zlib format, RFC 1950, compression level 9)
/// 3. Encoded using URL-safe base64 (RFC 4648)
String krokiEncode(String text) {
  final bytes = utf8.encode(text);
  final compressed = const ZLibEncoder().encode(bytes, level: 9);
  return base64UrlEncode(compressed);
}

/// Base class for UML diagram generators (e.g., [PlantUml], [MermaidUml]).
///
/// Provides a common interface for encoding UML code and building diagram URLs.
abstract class Uml<EP extends UmlEncodingParameters, P extends UmlParameters> {
  /// Creates a UML diagram generator.
  const Uml();

  /// Encodes UML code using the provider-specific encoding format.
  ///
  /// - For PlantUML: Uses deflate compression + PlantUML-specific base64 encoding
  /// - For Mermaid: Uses pako encoding (ZLib compression + base64url)
  /// - For Kroki: Uses ZLib compression + URL-safe base64 encoding
  ///
  /// The [encodingParameters] can include themes, colors, and other styling options
  /// that are applied to the code before encoding.
  ///
  /// Returns an encoded string suitable for use in diagram URLs.
  String encode(String code, [EP encodingParameters]);

  /// Builds a complete [UmlURL] from UML code.
  ///
  /// Applies the specified [parameters] (provider, file type) and
  /// [encodingParameters] (theme, styling) to generate a complete URL
  /// that can be used to render the diagram.
  ///
  /// Throws [ArgumentError] if the requested file type is not supported
  /// by the selected provider.
  ///
  /// Returns a [UmlURL] object that can be used to download or save the diagram.
  UmlURL getUrl(String code, {P parameters, EP encodingParameters});
}

/// Base class for UML encoding parameters.
///
/// Subclasses define the theme, colors, and other styling options
/// specific to each UML type (PlantUML, Mermaid, etc.).
///
/// These parameters are applied to the UML code before encoding.
abstract class UmlEncodingParameters<TH extends UmlTheme> {
  /// Creates encoding parameters for a UML diagram.
  const UmlEncodingParameters();

  /// The theme to apply to the diagram, or `null` for no theme.
  TH? get theme;

  /// Returns a copy of this [UmlEncodingParameters] with the given fields replaced.
  ///
  /// Use this to create modified parameter instances without mutating the original.
  UmlEncodingParameters<TH> copyWith({TH? theme});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UmlEncodingParameters &&
          runtimeType == other.runtimeType &&
          theme == other.theme;

  @override
  int get hashCode => theme.hashCode;
}

/// Base configuration class holding diagram parameters, available themes,
/// server providers, and the corresponding UML builder.
///
/// This class bundles together all the components needed to generate UML diagrams.
abstract class UmlConfig {
  /// Creates a UML configuration.
  const UmlConfig();

  /// The active UML parameters (provider, file type).
  UmlParameters get parameters;

  /// The active UML encoding parameters (theme, styling).
  UmlEncodingParameters get encodingParameters;

  /// All themes available for this UML type.
  List<UmlTheme> get allThemes;

  /// All available UML server providers for this UML type.
  List<UmlProvider> get allProviders;

  /// The UML diagram generator instance (e.g., [PlantUml], [MermaidUml]).
  Uml get umlBuilder;

  /// Returns a copy of this [UmlConfig] with the given fields replaced.
  UmlConfig copyWith({
    covariant UmlParameters? parameters,
    covariant UmlEncodingParameters? encodingParameters,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UmlConfig &&
          runtimeType == other.runtimeType &&
          parameters == other.parameters &&
          encodingParameters == other.encodingParameters;

  @override
  int get hashCode => Object.hash(parameters, encodingParameters);
}

/// Base class for UML parameters that wrap encoding parameters.
///
/// Provides provider selection, file type specification, and links to encoding configuration.
/// Each UML type (PlantUML, Mermaid) has its own concrete implementation.
abstract class UmlParameters<PR extends UmlProvider, FT extends FileTypeBase> {
  /// Creates UML parameters with encoding configuration.
  const UmlParameters();

  /// The UML server provider to use for rendering the diagram.
  ///
  /// Different providers may support different file types and have different URL structures.
  PR get provider;

  /// The output file type for the diagram (e.g., SVG, PNG, PDF).
  ///
  /// The available file types depend on the selected provider.
  FT get type;

  /// Returns a copy of this [UmlParameters] with the given fields replaced.
  ///
  /// Use this to create modified parameter instances without mutating the original.
  UmlParameters<PR, FT> copyWith({
    PR? provider,
    FT? type,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UmlParameters &&
          runtimeType == other.runtimeType &&
          provider == other.provider &&
          type == other.type;

  @override
  int get hashCode => Object.hash(provider, type);
}

/// Base interface for file type enums.
///
/// Implemented by [PlantUMLFileType] and [MermaidUmlFileType].
/// Each UML type defines its own file types with provider-specific behavior.
abstract class FileTypeBase {
  /// The underlying [FileType] enum value (e.g., svg, png, pdf).
  FileType get type;

  /// Returns the URL path segment for this file type.
  ///
  /// Different providers may use different URL structures. This method
  /// allows file types to define their default path logic, which providers
  /// can override if needed.
  ///
  /// For example, most providers use `/svg/` for SVG files, but Mermaid.ink
  /// uses `/img/` for bitmap formats like PNG.
  String getPath();
}

/// A URL wrapper for UML diagrams that supports downloading and saving.
///
/// Provides convenient methods to download diagram bytes and save them
/// to a file on disk (native platforms) or trigger a browser download (web).
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
  ///
  /// Use this to avoid re-downloading the same diagram multiple times.
  Uint8List? get cachedBytes => _bytes;

  /// Downloads the diagram as raw bytes.
  ///
  /// If [forceFetch] is `false` (default), returns cached bytes if available.
  /// Otherwise, always fetches from the URL.
  ///
  /// Returns the diagram bytes as a [Uint8List].
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
  /// If [filename] is not provided, a default filename is generated based on the file type.
  /// If [forceFetch] is `true`, re-downloads the bytes even if cached.
  ///
  /// Returns a [SavedFile] object containing the file path and bytes written.
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
///
/// The alpha channel is ignored when converting to hex, as PlantUML
/// does not support alpha in skinparam colors.
class Color {
  /// Creates a color from an ARGB32 integer value.
  ///
  /// The value should be in the format 0xAARRGGBB where:
  /// - AA is the alpha channel (0-255)
  /// - RR is the red channel (0-255)
  /// - GG is the green channel (0-255)
  /// - BB is the blue channel (0-255)
  const Color(this.aRGB32);

  /// The ARGB32 color value.
  final int aRGB32;

  /// Converts this color to a PlantUML-compatible hex string (e.g., `#FF0000`).
  ///
  /// The alpha channel is ignored. Returns a 6-digit hex string with uppercase letters.
  String toHex() {
    final rgb = aRGB32 & 0x00FFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Color && aRGB32 == other.aRGB32;

  @override
  int get hashCode => aRGB32.hashCode;

  @override
  String toString() => 'Color(${aRGB32.toRadixString(16).padLeft(8, '0')})';
}

/// Text alignment options for PlantUML diagrams.
///
/// Used in skinparam styling to control how text is aligned within diagram elements.
enum TextAlign {
  /// Align text to the left.
  left,

  /// Align text to the right.
  right,

  /// Align text to the center.
  center,
}

/// Base class for UML server providers.
///
/// Each provider has a base URL, supports specific file types, and defines
/// URL path structures for those file types.
///
/// Concrete implementations are provided for PlantUML and Mermaid:
/// - [PlantUMLProvider]: planttext, plantuml, kroki
/// - [MermaidUmlProvider]: mermaidink, kroki
mixin UmlProvider on Enum {
  /// The base URL of the provider.
  ///
  /// This is the root URL used to construct diagram URLs.
  /// For example: `https://uml.planttext.com/plantuml`
  String get baseUrl;

  /// Returns the list of file types supported by this provider.
  ///
  /// Different providers may support different file types. For example:
  /// - Mermaid.ink supports SVG, PNG, WebP, JPEG
  /// - Kroki for Mermaid supports SVG, PNG, PDF
  ///
  /// Use [supportsFileType] to check if a specific file type is supported.
  List<FileType> get supportedFileTypes;

  /// Checks if a given file type is supported by this provider.
  ///
  /// Returns `true` if the file type is in [supportedFileTypes], `false` otherwise.
  bool supportsFileType(FileType type);

  /// Returns the URL path segment for a given file type.
  ///
  /// The default implementation delegates to the file type's [FileTypeBase.getPath] method.
  /// Providers can override this for custom path logic.
  ///
  /// For example:
  /// - Mermaid.ink uses `/svg/` for SVG, `/img/` for PNG/WebP/JPEG
  /// - Kroki uses standard paths like `/svg/`, `/png/`, `/pdf/`
  String getPathForFileType<FT extends FileTypeBase>(FT fileType) =>
      fileType.getPath();
}

/// Base class for UML themes.
///
/// Themes define the visual appearance of diagrams, including colors,
/// fonts, and styling. Each UML type (PlantUML, Mermaid) has its own
/// set of theme implementations.
abstract class UmlTheme {
  /// The name of the theme (e.g., "default", "dark", "forest").
  ///
  /// This name is used in the encoded URL to specify which theme to apply.
  String get themeName;

  /// The brightness level of the theme (dark or light).
  ///
  /// This can be used to automatically select appropriate themes based
  /// on user preferences or system settings.
  UmlBrightness get brightness;
}

/// The brightness level of a UML theme.
enum UmlBrightness {
  /// Dark theme brightness.
  dark,

  /// Light theme brightness.
  light,
}
