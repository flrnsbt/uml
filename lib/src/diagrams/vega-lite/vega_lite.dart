import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/vega-lite/types/file_type.dart';
import 'package:uml/src/diagrams/vega-lite/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates VegaLite diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders VegaLite diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class VegaLite extends Uml<VegaLiteEncodingParameters, VegaLiteParameters> {
  VegaLite._();
  static VegaLite? _instance;

  static VegaLite get instance => _instance ??= VegaLite._();

  @override
  String encode(String text,
      [VegaLiteEncodingParameters parameters =
          const VegaLiteEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    VegaLiteParameters parameters = const VegaLiteParameters(),
    VegaLiteEncodingParameters encodingParameters =
        const VegaLiteEncodingParameters(),
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

/// Encoding parameters for VegaLite diagrams.
class VegaLiteEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const VegaLiteEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  VegaLiteEncodingParameters copyWith({UmlTheme? theme}) {
    return VegaLiteEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is VegaLiteEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating VegaLite diagram URLs.
class VegaLiteParameters
    extends UmlParameters<VegaLiteProvider, VegaLiteFileType> {
  const VegaLiteParameters({
    this.provider = VegaLiteProvider.kroki,
    this.type = VegaLiteFileType.svg,
  });

  @override
  final VegaLiteProvider provider;

  @override
  final VegaLiteFileType type;

  @override
  VegaLiteParameters copyWith({
    VegaLiteProvider? provider,
    VegaLiteFileType? type,
  }) {
    return VegaLiteParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for VegaLite diagrams.
final class VegaLiteConfig extends UmlConfig {
  const VegaLiteConfig({
    this.parameters = const VegaLiteParameters(),
    this.encodingParameters = const VegaLiteEncodingParameters(),
  });

  @override
  VegaLite get umlBuilder => VegaLite.instance;

  @override
  List<VegaLiteProvider> get allProviders => VegaLiteProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final VegaLiteParameters parameters;

  @override
  final VegaLiteEncodingParameters encodingParameters;

  @override
  VegaLiteConfig copyWith({
    VegaLiteParameters? parameters,
    VegaLiteEncodingParameters? encodingParameters,
  }) {
    return VegaLiteConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
