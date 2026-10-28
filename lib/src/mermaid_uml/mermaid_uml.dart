import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:uml/src/base.dart';
import 'package:uml/src/mermaid_uml/types/file_type.dart';
import 'package:uml/src/mermaid_uml/types/provider.dart';
import 'package:uml/src/mermaid_uml/types/theme.dart';
export 'package:uml/src/mermaid_uml/types/file_type.dart';
export 'package:uml/src/mermaid_uml/types/provider.dart';
export 'package:uml/src/mermaid_uml/types/theme.dart';

/// Singleton that generates Mermaid diagram URLs.
///
/// Encodes Mermaid code with optional themes and builds a URL
/// that renders the diagram on a Mermaid server.
///
/// Example:
/// ```dart
/// final url = MermaidUrl.instance.getUrl(
///   'graph LR; A --> B',
///   parameters: const MermaidUmlParameters(type: MermaidUmlFileType.svg),
/// );
/// ```
class MermaidUrl {
  MermaidUrl._();
  static MermaidUrl? _instance;
  static MermaidUrl get instance => _instance ??= MermaidUrl._();

  /// Encodes Mermaid code with optional theme.
  ///
  /// Returns a pako-encoded string suitable for use in Mermaid URLs.
  String encode(
    String text, {
    MermaidUmlEncodingParameters parameters =
        const MermaidUmlEncodingParameters(),
  }) {
    final json = jsonEncode({
      'code': text,
      'mermaid': {'theme': parameters.theme.name},
    });
    final bytes = utf8.encode(json);

    final compressed = const ZLibEncoder().encode(bytes, level: 9);

    return 'pako:${base64UrlEncode(compressed)}';
  }

  /// Builds a complete [UmlURL] from Mermaid code.
  ///
  /// Applies [parameters] for file type, provider, and theme.
  UmlURL getUrl(
    String code, {
    MermaidUmlParameters parameters = const MermaidUmlParameters(),
  }) {
    final type = parameters.type ?? MermaidUmlFileType.default_;
    final encodedCode = encode(code, parameters: parameters.encodingParameters);
    String query = '';
    if (type.query != null) {
      query = '?${type.query}';
    }
    return UmlURL(
      '${parameters.provider.baseUrl}/${type.path}/$encodedCode$query',
      type.type,
    );
  }
}

/// Encoding parameters for Mermaid diagrams.
///
/// Currently supports theme selection.
class MermaidUmlEncodingParameters extends UmlEncodingParameters {
  const MermaidUmlEncodingParameters({this.theme = MermaidUmlTheme.default_});

  /// The visual theme for the diagram.
  final MermaidUmlTheme theme;

  MermaidUmlEncodingParameters copyWith({MermaidUmlTheme? theme}) {
    return MermaidUmlEncodingParameters(theme: theme ?? this.theme);
  }
}

/// Parameters for generating Mermaid diagram URLs.
///
/// Wraps [encodingParameters] with a [provider] and optional [type].
class MermaidUmlParameters extends UmlParameters<MermaidUmlEncodingParameters> {
  const MermaidUmlParameters({
    this.encodingParameters = const MermaidUmlEncodingParameters(),
    this.provider = MermaidUmlProvider.mermaidink,
    this.type,
  });
  @override
  final MermaidUmlEncodingParameters encodingParameters;

  /// The Mermaid server provider.
  final MermaidUmlProvider provider;

  /// The output file type (SVG, PNG, WebP, or JPEG). Defaults to SVG.
  final MermaidUmlFileType? type;

  MermaidUmlParameters copyWith({
    MermaidUmlEncodingParameters? encodingParameters,
    MermaidUmlProvider? provider,
    MermaidUmlFileType? type,
  }) {
    return MermaidUmlParameters(
      encodingParameters: encodingParameters ?? this.encodingParameters,
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}
