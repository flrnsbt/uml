import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/wireviz/types/file_type.dart';
import 'package:uml/src/diagrams/wireviz/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Wireviz diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Wireviz diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Wireviz extends Uml<WirevizEncodingParameters, WirevizParameters> {
  Wireviz._();
  static Wireviz? _instance;

  static Wireviz get instance => _instance ??= Wireviz._();

  @override
  String encode(String text,
      [WirevizEncodingParameters parameters =
          const WirevizEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    WirevizParameters parameters = const WirevizParameters(),
    WirevizEncodingParameters encodingParameters =
        const WirevizEncodingParameters(),
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

/// Encoding parameters for Wireviz diagrams.
class WirevizEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const WirevizEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  WirevizEncodingParameters copyWith({UmlTheme? theme}) {
    return WirevizEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WirevizEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Wireviz diagram URLs.
class WirevizParameters
    extends UmlParameters<WirevizProvider, WirevizFileType> {
  const WirevizParameters({
    this.provider = WirevizProvider.kroki,
    this.type = WirevizFileType.svg,
  });

  @override
  final WirevizProvider provider;

  @override
  final WirevizFileType type;

  @override
  WirevizParameters copyWith({
    WirevizProvider? provider,
    WirevizFileType? type,
  }) {
    return WirevizParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Wireviz diagrams.
final class WirevizConfig extends UmlConfig {
  const WirevizConfig({
    this.parameters = const WirevizParameters(),
    this.encodingParameters = const WirevizEncodingParameters(),
  });

  @override
  Wireviz get umlBuilder => Wireviz.instance;

  @override
  List<WirevizProvider> get allProviders => WirevizProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final WirevizParameters parameters;

  @override
  final WirevizEncodingParameters encodingParameters;

  @override
  WirevizConfig copyWith({
    WirevizParameters? parameters,
    WirevizEncodingParameters? encodingParameters,
  }) {
    return WirevizConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
