import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/lini/types/file_type.dart';
import 'package:uml/src/diagrams/lini/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Lini diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Lini diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Lini extends Uml<LiniEncodingParameters, LiniParameters> {
  Lini._();
  static Lini? _instance;

  static Lini get instance => _instance ??= Lini._();

  @override
  String encode(String text,
      [LiniEncodingParameters parameters = const LiniEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    LiniParameters parameters = const LiniParameters(),
    LiniEncodingParameters encodingParameters = const LiniEncodingParameters(),
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

/// Encoding parameters for Lini diagrams.
class LiniEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const LiniEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  LiniEncodingParameters copyWith({UmlTheme? theme}) {
    return LiniEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LiniEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Lini diagram URLs.
class LiniParameters extends UmlParameters<LiniProvider, LiniFileType> {
  const LiniParameters({
    this.provider = LiniProvider.kroki,
    this.type = LiniFileType.svg,
  });

  @override
  final LiniProvider provider;

  @override
  final LiniFileType type;

  @override
  LiniParameters copyWith({
    LiniProvider? provider,
    LiniFileType? type,
  }) {
    return LiniParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Lini diagrams.
final class LiniConfig extends UmlConfig {
  const LiniConfig({
    this.parameters = const LiniParameters(),
    this.encodingParameters = const LiniEncodingParameters(),
  });

  @override
  Lini get umlBuilder => Lini.instance;

  @override
  List<LiniProvider> get allProviders => LiniProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final LiniParameters parameters;

  @override
  final LiniEncodingParameters encodingParameters;

  @override
  LiniConfig copyWith({
    LiniParameters? parameters,
    LiniEncodingParameters? encodingParameters,
  }) {
    return LiniConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
