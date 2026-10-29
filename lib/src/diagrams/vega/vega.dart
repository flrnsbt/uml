import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/vega/types/file_type.dart';
import 'package:uml/src/diagrams/vega/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Vega diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Vega diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Vega extends Uml<VegaEncodingParameters, VegaParameters> {
  Vega._();
  static Vega? _instance;

  static Vega get instance => _instance ??= Vega._();

  @override
  String encode(String text,
      [VegaEncodingParameters parameters = const VegaEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    VegaParameters parameters = const VegaParameters(),
    VegaEncodingParameters encodingParameters = const VegaEncodingParameters(),
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

/// Encoding parameters for Vega diagrams.
class VegaEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const VegaEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  VegaEncodingParameters copyWith({UmlTheme? theme}) {
    return VegaEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is VegaEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Vega diagram URLs.
class VegaParameters extends UmlParameters<VegaProvider, VegaFileType> {
  const VegaParameters({
    this.provider = VegaProvider.kroki,
    this.type = VegaFileType.svg,
  });

  @override
  final VegaProvider provider;

  @override
  final VegaFileType type;

  @override
  VegaParameters copyWith({
    VegaProvider? provider,
    VegaFileType? type,
  }) {
    return VegaParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Vega diagrams.
final class VegaConfig extends UmlConfig {
  const VegaConfig({
    this.parameters = const VegaParameters(),
    this.encodingParameters = const VegaEncodingParameters(),
  });

  @override
  Vega get umlBuilder => Vega.instance;

  @override
  List<VegaProvider> get allProviders => VegaProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final VegaParameters parameters;

  @override
  final VegaEncodingParameters encodingParameters;

  @override
  VegaConfig copyWith({
    VegaParameters? parameters,
    VegaEncodingParameters? encodingParameters,
  }) {
    return VegaConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
