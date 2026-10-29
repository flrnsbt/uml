import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/pikchr/types/file_type.dart';
import 'package:uml/src/diagrams/pikchr/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Pikchr diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Pikchr diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Pikchr extends Uml<PikchrEncodingParameters, PikchrParameters> {
  Pikchr._();
  static Pikchr? _instance;

  static Pikchr get instance => _instance ??= Pikchr._();

  @override
  String encode(String text,
      [PikchrEncodingParameters parameters =
          const PikchrEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    PikchrParameters parameters = const PikchrParameters(),
    PikchrEncodingParameters encodingParameters =
        const PikchrEncodingParameters(),
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

/// Encoding parameters for Pikchr diagrams.
class PikchrEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const PikchrEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  PikchrEncodingParameters copyWith({UmlTheme? theme}) {
    return PikchrEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PikchrEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Pikchr diagram URLs.
class PikchrParameters extends UmlParameters<PikchrProvider, PikchrFileType> {
  const PikchrParameters({
    this.provider = PikchrProvider.kroki,
    this.type = PikchrFileType.svg,
  });

  @override
  final PikchrProvider provider;

  @override
  final PikchrFileType type;

  @override
  PikchrParameters copyWith({
    PikchrProvider? provider,
    PikchrFileType? type,
  }) {
    return PikchrParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Pikchr diagrams.
final class PikchrConfig extends UmlConfig {
  const PikchrConfig({
    this.parameters = const PikchrParameters(),
    this.encodingParameters = const PikchrEncodingParameters(),
  });

  @override
  Pikchr get umlBuilder => Pikchr.instance;

  @override
  List<PikchrProvider> get allProviders => PikchrProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final PikchrParameters parameters;

  @override
  final PikchrEncodingParameters encodingParameters;

  @override
  PikchrConfig copyWith({
    PikchrParameters? parameters,
    PikchrEncodingParameters? encodingParameters,
  }) {
    return PikchrConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
