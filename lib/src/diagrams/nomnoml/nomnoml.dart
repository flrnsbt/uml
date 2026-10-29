import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/nomnoml/types/file_type.dart';
import 'package:uml/src/diagrams/nomnoml/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Nomnoml diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Nomnoml diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Nomnoml extends Uml<NomnomlEncodingParameters, NomnomlParameters> {
  Nomnoml._();
  static Nomnoml? _instance;

  static Nomnoml get instance => _instance ??= Nomnoml._();

  @override
  String encode(String text,
      [NomnomlEncodingParameters parameters =
          const NomnomlEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    NomnomlParameters parameters = const NomnomlParameters(),
    NomnomlEncodingParameters encodingParameters =
        const NomnomlEncodingParameters(),
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

/// Encoding parameters for Nomnoml diagrams.
class NomnomlEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const NomnomlEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  NomnomlEncodingParameters copyWith({UmlTheme? theme}) {
    return NomnomlEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NomnomlEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Nomnoml diagram URLs.
class NomnomlParameters
    extends UmlParameters<NomnomlProvider, NomnomlFileType> {
  const NomnomlParameters({
    this.provider = NomnomlProvider.kroki,
    this.type = NomnomlFileType.svg,
  });

  @override
  final NomnomlProvider provider;

  @override
  final NomnomlFileType type;

  @override
  NomnomlParameters copyWith({
    NomnomlProvider? provider,
    NomnomlFileType? type,
  }) {
    return NomnomlParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Nomnoml diagrams.
final class NomnomlConfig extends UmlConfig {
  const NomnomlConfig({
    this.parameters = const NomnomlParameters(),
    this.encodingParameters = const NomnomlEncodingParameters(),
  });

  @override
  Nomnoml get umlBuilder => Nomnoml.instance;

  @override
  List<NomnomlProvider> get allProviders => NomnomlProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final NomnomlParameters parameters;

  @override
  final NomnomlEncodingParameters encodingParameters;

  @override
  NomnomlConfig copyWith({
    NomnomlParameters? parameters,
    NomnomlEncodingParameters? encodingParameters,
  }) {
    return NomnomlConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
