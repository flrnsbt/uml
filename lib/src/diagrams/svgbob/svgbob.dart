import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/svgbob/types/file_type.dart';
import 'package:uml/src/diagrams/svgbob/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Svgbob diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Svgbob diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Svgbob extends Uml<SvgbobEncodingParameters, SvgbobParameters> {
  Svgbob._();
  static Svgbob? _instance;

  static Svgbob get instance => _instance ??= Svgbob._();

  @override
  String encode(String text,
      [SvgbobEncodingParameters parameters =
          const SvgbobEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    SvgbobParameters parameters = const SvgbobParameters(),
    SvgbobEncodingParameters encodingParameters =
        const SvgbobEncodingParameters(),
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

/// Encoding parameters for Svgbob diagrams.
class SvgbobEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const SvgbobEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  SvgbobEncodingParameters copyWith({UmlTheme? theme}) {
    return SvgbobEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SvgbobEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Svgbob diagram URLs.
class SvgbobParameters extends UmlParameters<SvgbobProvider, SvgbobFileType> {
  const SvgbobParameters({
    this.provider = SvgbobProvider.kroki,
    this.type = SvgbobFileType.svg,
  });

  @override
  final SvgbobProvider provider;

  @override
  final SvgbobFileType type;

  @override
  SvgbobParameters copyWith({
    SvgbobProvider? provider,
    SvgbobFileType? type,
  }) {
    return SvgbobParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Svgbob diagrams.
final class SvgbobConfig extends UmlConfig {
  const SvgbobConfig({
    this.parameters = const SvgbobParameters(),
    this.encodingParameters = const SvgbobEncodingParameters(),
  });

  @override
  Svgbob get umlBuilder => Svgbob.instance;

  @override
  List<SvgbobProvider> get allProviders => SvgbobProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final SvgbobParameters parameters;

  @override
  final SvgbobEncodingParameters encodingParameters;

  @override
  SvgbobConfig copyWith({
    SvgbobParameters? parameters,
    SvgbobEncodingParameters? encodingParameters,
  }) {
    return SvgbobConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
