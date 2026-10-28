import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:uml/src/base.dart';
import 'package:uml/src/mermaid_uml/types/file_type.dart';
import 'package:uml/src/mermaid_uml/types/provider.dart';
import 'package:uml/src/mermaid_uml/types/theme.dart';
export 'package:uml/src/mermaid_uml/types/file_type.dart';
export 'package:uml/src/mermaid_uml/types/provider.dart';
export 'package:uml/src/mermaid_uml/types/theme.dart';

class MermaidUrl {
  static MermaidUrl? _instance;
  static MermaidUrl get instance => _instance ??= MermaidUrl._();
  MermaidUrl._();

  String encode(
    String text, {
    MermaidUmlEncodingParameters parameters =
        const MermaidUmlEncodingParameters(),
  }) {
    final json = jsonEncode({
      'code': text,
      "mermaid": {"theme": parameters.theme.name},
    });
    final bytes = utf8.encode(json);

    final compressed = const ZLibEncoder().encode(bytes, level: 9);

    return 'pako:${base64UrlEncode(compressed)}';
  }

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

class MermaidUmlEncodingParameters extends UmlEncodingParameters {
  const MermaidUmlEncodingParameters({this.theme = MermaidUmlTheme.default_});

  final MermaidUmlTheme theme;

  MermaidUmlEncodingParameters copyWith({MermaidUmlTheme? theme}) {
    return MermaidUmlEncodingParameters(theme: theme ?? this.theme);
  }
}

class MermaidUmlParameters extends UmlParameters<MermaidUmlEncodingParameters> {
  @override
  final MermaidUmlEncodingParameters encodingParameters;

  final MermaidUmlProvider provider;
  final MermaidUmlFileType? type;

  const MermaidUmlParameters({
    this.encodingParameters = const MermaidUmlEncodingParameters(),
    this.provider = MermaidUmlProvider.mermaidink,
    this.type,
  });

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
