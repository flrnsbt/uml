import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/structurizr/types/file_type.dart';
import 'package:uml/src/diagrams/structurizr/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Structurizr diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Structurizr diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Structurizr
    extends Uml<StructurizrEncodingParameters, StructurizrParameters> {
  Structurizr._();
  static Structurizr? _instance;

  static Structurizr get instance => _instance ??= Structurizr._();

  @override
  String encode(String text,
      [StructurizrEncodingParameters parameters =
          const StructurizrEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    StructurizrParameters parameters = const StructurizrParameters(),
    StructurizrEncodingParameters encodingParameters =
        const StructurizrEncodingParameters(),
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

/// Encoding parameters for Structurizr diagrams.
class StructurizrEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const StructurizrEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  StructurizrEncodingParameters copyWith({UmlTheme? theme}) {
    return StructurizrEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is StructurizrEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Structurizr diagram URLs.
class StructurizrParameters
    extends UmlParameters<StructurizrProvider, StructurizrFileType> {
  const StructurizrParameters({
    this.provider = StructurizrProvider.kroki,
    this.type = StructurizrFileType.svg,
  });

  @override
  final StructurizrProvider provider;

  @override
  final StructurizrFileType type;

  @override
  StructurizrParameters copyWith({
    StructurizrProvider? provider,
    StructurizrFileType? type,
  }) {
    return StructurizrParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Structurizr diagrams.
final class StructurizrConfig extends UmlConfig {
  const StructurizrConfig({
    this.parameters = const StructurizrParameters(),
    this.encodingParameters = const StructurizrEncodingParameters(),
  });

  @override
  Structurizr get umlBuilder => Structurizr.instance;

  @override
  List<StructurizrProvider> get allProviders => StructurizrProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final StructurizrParameters parameters;

  @override
  final StructurizrEncodingParameters encodingParameters;

  @override
  StructurizrConfig copyWith({
    StructurizrParameters? parameters,
    StructurizrEncodingParameters? encodingParameters,
  }) {
    return StructurizrConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
