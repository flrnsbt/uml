import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/goat/types/file_type.dart';
import 'package:uml/src/diagrams/goat/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Goat diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Goat diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Goat extends Uml<GoatEncodingParameters, GoatParameters> {
  Goat._();
  static Goat? _instance;

  static Goat get instance => _instance ??= Goat._();

  @override
  String encode(String text,
      [GoatEncodingParameters parameters = const GoatEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    GoatParameters parameters = const GoatParameters(),
    GoatEncodingParameters encodingParameters = const GoatEncodingParameters(),
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

/// Encoding parameters for Goat diagrams.
class GoatEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const GoatEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  GoatEncodingParameters copyWith({UmlTheme? theme}) {
    return GoatEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GoatEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Goat diagram URLs.
class GoatParameters extends UmlParameters<GoatProvider, GoatFileType> {
  const GoatParameters({
    this.provider = GoatProvider.kroki,
    this.type = GoatFileType.svg,
  });

  @override
  final GoatProvider provider;

  @override
  final GoatFileType type;

  @override
  GoatParameters copyWith({
    GoatProvider? provider,
    GoatFileType? type,
  }) {
    return GoatParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Goat diagrams.
final class GoatConfig extends UmlConfig {
  const GoatConfig({
    this.parameters = const GoatParameters(),
    this.encodingParameters = const GoatEncodingParameters(),
  });

  @override
  Goat get umlBuilder => Goat.instance;

  @override
  List<GoatProvider> get allProviders => GoatProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final GoatParameters parameters;

  @override
  final GoatEncodingParameters encodingParameters;

  @override
  GoatConfig copyWith({
    GoatParameters? parameters,
    GoatEncodingParameters? encodingParameters,
  }) {
    return GoatConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
