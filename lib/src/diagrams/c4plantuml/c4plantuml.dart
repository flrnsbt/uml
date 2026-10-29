import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/c4plantuml/types/file_type.dart';
import 'package:uml/src/diagrams/c4plantuml/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates C4Plantuml diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders C4Plantuml diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class C4Plantuml
    extends Uml<C4PlantumlEncodingParameters, C4PlantumlParameters> {
  C4Plantuml._();
  static C4Plantuml? _instance;

  static C4Plantuml get instance => _instance ??= C4Plantuml._();

  @override
  String encode(String text,
      [C4PlantumlEncodingParameters parameters =
          const C4PlantumlEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    C4PlantumlParameters parameters = const C4PlantumlParameters(),
    C4PlantumlEncodingParameters encodingParameters =
        const C4PlantumlEncodingParameters(),
  }) {
    final type = parameters.type;
    final provider = parameters.provider;

    if (!provider.supportsFileType(type.type)) {
      throw ArgumentError(
        'FileType $type.type is not supported by provider $provider.name. '
        'Supported types: $provider.supportedFileTypes.map((t) => t.name).join(", ")',
      );
    }

    final encodedCode = encode(code, encodingParameters);
    final base = provider.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final path = provider.getPathForFileType(type);
    return UmlURL('$base/$path/$encodedCode', type.type);
  }
}

/// Encoding parameters for C4Plantuml diagrams.
class C4PlantumlEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const C4PlantumlEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  C4PlantumlEncodingParameters copyWith({UmlTheme? theme}) {
    return C4PlantumlEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is C4PlantumlEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating C4Plantuml diagram URLs.
class C4PlantumlParameters
    extends UmlParameters<C4PlantumlProvider, C4PlantumlFileType> {
  const C4PlantumlParameters({
    this.provider = C4PlantumlProvider.kroki,
    this.type = C4PlantumlFileType.svg,
  });

  @override
  final C4PlantumlProvider provider;

  @override
  final C4PlantumlFileType type;

  @override
  C4PlantumlParameters copyWith({
    C4PlantumlProvider? provider,
    C4PlantumlFileType? type,
  }) {
    return C4PlantumlParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for C4Plantuml diagrams.
final class C4PlantumlConfig extends UmlConfig {
  const C4PlantumlConfig({
    this.parameters = const C4PlantumlParameters(),
    this.encodingParameters = const C4PlantumlEncodingParameters(),
  });

  @override
  C4Plantuml get umlBuilder => C4Plantuml.instance;

  @override
  List<C4PlantumlProvider> get allProviders => C4PlantumlProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final C4PlantumlParameters parameters;

  @override
  final C4PlantumlEncodingParameters encodingParameters;

  @override
  C4PlantumlConfig copyWith({
    C4PlantumlParameters? parameters,
    C4PlantumlEncodingParameters? encodingParameters,
  }) {
    return C4PlantumlConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
