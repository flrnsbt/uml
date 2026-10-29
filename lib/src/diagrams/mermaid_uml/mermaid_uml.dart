import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/mermaid_uml/types/file_type.dart';
import 'package:uml/src/diagrams/mermaid_uml/types/provider.dart';
import 'package:uml/src/diagrams/mermaid_uml/types/theme.dart';
export 'package:uml/src/diagrams/mermaid_uml/types/file_type.dart';
export 'package:uml/src/diagrams/mermaid_uml/types/provider.dart';
export 'package:uml/src/diagrams/mermaid_uml/types/theme.dart';

/// Singleton that generates Mermaid diagram URLs.
///
/// Encodes Mermaid code with optional themes and builds a URL
/// that renders the diagram on a Mermaid server.
///
/// This class uses Mermaid's pako encoding: ZLib compression
/// followed by base64url encoding.
///
/// Example:
/// ```dart
/// final url = MermaidUml.instance.getUrl(
///   'graph LR; A --> B',
///   parameters: const MermaidUmlParameters(type: MermaidUmlFileType.svg),
/// );
/// ```
class MermaidUml
    extends Uml<MermaidUmlEncodingParameters, MermaidUmlParameters> {
  MermaidUml._();
  static MermaidUml? _instance;

  /// Returns the singleton instance of [MermaidUml].
  static MermaidUml get instance => _instance ??= MermaidUml._();

  /// Encodes Mermaid code with optional theme.
  ///
  /// Applies the specified theme to the code, then compresses it using
  /// ZLib and encodes it using base64url encoding (pako format).
  ///
  /// Returns a pako-encoded string suitable for use in Mermaid URLs.
  @override
  String encode(
    String text, [
    MermaidUmlEncodingParameters parameters =
        const MermaidUmlEncodingParameters(),
  ]) {
    final json = jsonEncode({
      'code': text,
      'mermaid': {'theme': parameters.theme.themeName},
    });
    final bytes = utf8.encode(json);

    final compressed = const ZLibEncoder().encode(bytes, level: 9);

    return 'pako:${base64UrlEncode(compressed)}';
  }

  /// Encodes Mermaid code using deflate + base64url for Kroki provider.
  String _encodeForKroki(String text) {
    return krokiEncode(text);
  }

  /// Builds a complete [UmlURL] from Mermaid code.
  ///
  /// Applies [parameters] for file type, provider, and theme.
  ///
  /// Throws [ArgumentError] if the requested file type is not supported by the provider.
  @override
  UmlURL getUrl(
    String code, {
    MermaidUmlParameters parameters = const MermaidUmlParameters(),
    MermaidUmlEncodingParameters encodingParameters =
        const MermaidUmlEncodingParameters(),
  }) {
    final type = parameters.type;
    final provider = parameters.provider;

    // Validate that the provider supports the requested file type
    if (!provider.supportsFileType(type.type)) {
      throw ArgumentError(
        'FileType ${type.type} is not supported by provider ${provider.name}. '
        'Supported types: ${provider.supportedFileTypes.map((t) => t.name).join(", ")}',
      );
    }

    final encodedCode = provider == MermaidUmlProvider.kroki
        ? _encodeForKroki(code)
        : encode(code, encodingParameters);
    String query = '';
    if (type.query != null && provider != MermaidUmlProvider.kroki) {
      query = '?${type.query}';
    }
    final base = provider.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final path = provider.getPathForFileType(type);
    return UmlURL('$base/$path/$encodedCode$query', type.type);
  }
}

/// Encoding parameters for Mermaid diagrams.
///
/// Currently supports theme selection.
class MermaidUmlEncodingParameters
    extends UmlEncodingParameters<MermaidUmlTheme> {
  /// Creates encoding parameters with an optional theme.
  const MermaidUmlEncodingParameters({this.theme = MermaidUmlTheme.default_});

  /// The visual theme for the diagram.
  @override
  final MermaidUmlTheme theme;

  /// Returns a copy of this [MermaidUmlEncodingParameters] with the given fields replaced.
  @override
  MermaidUmlEncodingParameters copyWith({MermaidUmlTheme? theme}) {
    return MermaidUmlEncodingParameters(theme: theme ?? this.theme);
  }
}

/// Parameters for generating Mermaid diagram URLs.
///
/// Wraps [encodingParameters] with a [provider] and optional [type].
/// These parameters are passed to [MermaidUml.getUrl] to configure the
/// diagram generation.
class MermaidUmlParameters
    extends UmlParameters<MermaidUmlProvider, MermaidUmlFileType> {
  /// Creates parameters for generating Mermaid diagram URLs.
  ///
  /// [provider] defaults to [MermaidUmlProvider.mermaidink].
  /// [type] defaults to [MermaidUmlFileType.svg].
  const MermaidUmlParameters({
    this.provider = MermaidUmlProvider.mermaidink,
    this.type = MermaidUmlFileType.svg,
  });

  /// The Mermaid server provider to use for rendering.
  ///
  /// Defaults to [MermaidUmlProvider.mermaidink].
  @override
  final MermaidUmlProvider provider;

  /// The output file type for the diagram.
  ///
  /// Supported types depend on the provider. Defaults to SVG.
  @override
  final MermaidUmlFileType type;

  /// Returns a copy of this [MermaidUmlParameters] with the given fields replaced.
  ///
  /// Use this to create modified parameter instances without mutating the original.
  @override
  MermaidUmlParameters copyWith({
    MermaidUmlProvider? provider,
    MermaidUmlFileType? type,
  }) {
    return MermaidUmlParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Mermaid diagrams.
final class MermaidUmlConfig extends UmlConfig {
  /// Creates a Mermaid UML configuration from [parameters].
  const MermaidUmlConfig(
      {this.parameters = const MermaidUmlParameters(),
      this.encodingParameters = const MermaidUmlEncodingParameters()});

  @override
  MermaidUml get umlBuilder => MermaidUml.instance;

  @override
  List<MermaidUmlProvider> get allProviders => MermaidUmlProvider.values;

  @override
  List<MermaidUmlTheme> get allThemes => MermaidUmlTheme.values;

  @override
  final MermaidUmlParameters parameters;

  /// The encoding-specific parameters for theme selection.
  @override
  final MermaidUmlEncodingParameters encodingParameters;

  @override
  MermaidUmlConfig copyWith({
    MermaidUmlParameters? parameters,
    MermaidUmlEncodingParameters? encodingParameters,
  }) {
    return MermaidUmlConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
