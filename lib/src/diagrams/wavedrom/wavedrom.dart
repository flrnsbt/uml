import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/wavedrom/types/file_type.dart';
import 'package:uml/src/diagrams/wavedrom/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Wavedrom diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Wavedrom diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Wavedrom extends Uml<WavedromEncodingParameters, WavedromParameters> {
  Wavedrom._();
  static Wavedrom? _instance;

  static Wavedrom get instance => _instance ??= Wavedrom._();

  @override
  String encode(String text,
      [WavedromEncodingParameters parameters =
          const WavedromEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    WavedromParameters parameters = const WavedromParameters(),
    WavedromEncodingParameters encodingParameters =
        const WavedromEncodingParameters(),
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

/// Encoding parameters for Wavedrom diagrams.
class WavedromEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const WavedromEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  WavedromEncodingParameters copyWith({UmlTheme? theme}) {
    return WavedromEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WavedromEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Wavedrom diagram URLs.
class WavedromParameters
    extends UmlParameters<WavedromProvider, WavedromFileType> {
  const WavedromParameters({
    this.provider = WavedromProvider.kroki,
    this.type = WavedromFileType.svg,
  });

  @override
  final WavedromProvider provider;

  @override
  final WavedromFileType type;

  @override
  WavedromParameters copyWith({
    WavedromProvider? provider,
    WavedromFileType? type,
  }) {
    return WavedromParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Wavedrom diagrams.
final class WavedromConfig extends UmlConfig {
  const WavedromConfig({
    this.parameters = const WavedromParameters(),
    this.encodingParameters = const WavedromEncodingParameters(),
  });

  @override
  Wavedrom get umlBuilder => Wavedrom.instance;

  @override
  List<WavedromProvider> get allProviders => WavedromProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final WavedromParameters parameters;

  @override
  final WavedromEncodingParameters encodingParameters;

  @override
  WavedromConfig copyWith({
    WavedromParameters? parameters,
    WavedromEncodingParameters? encodingParameters,
  }) {
    return WavedromConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
