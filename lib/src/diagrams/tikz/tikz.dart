import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/tikz/types/file_type.dart';
import 'package:uml/src/diagrams/tikz/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Tikz diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Tikz diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Tikz extends Uml<TikzEncodingParameters, TikzParameters> {
  Tikz._();
  static Tikz? _instance;

  static Tikz get instance => _instance ??= Tikz._();

  @override
  String encode(String text,
      [TikzEncodingParameters parameters = const TikzEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    TikzParameters parameters = const TikzParameters(),
    TikzEncodingParameters encodingParameters = const TikzEncodingParameters(),
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

/// Encoding parameters for Tikz diagrams.
class TikzEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const TikzEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  TikzEncodingParameters copyWith({UmlTheme? theme}) {
    return TikzEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TikzEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Tikz diagram URLs.
class TikzParameters extends UmlParameters<TikzProvider, TikzFileType> {
  const TikzParameters({
    this.provider = TikzProvider.kroki,
    this.type = TikzFileType.svg,
  });

  @override
  final TikzProvider provider;

  @override
  final TikzFileType type;

  @override
  TikzParameters copyWith({
    TikzProvider? provider,
    TikzFileType? type,
  }) {
    return TikzParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Tikz diagrams.
final class TikzConfig extends UmlConfig {
  const TikzConfig({
    this.parameters = const TikzParameters(),
    this.encodingParameters = const TikzEncodingParameters(),
  });

  @override
  Tikz get umlBuilder => Tikz.instance;

  @override
  List<TikzProvider> get allProviders => TikzProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final TikzParameters parameters;

  @override
  final TikzEncodingParameters encodingParameters;

  @override
  TikzConfig copyWith({
    TikzParameters? parameters,
    TikzEncodingParameters? encodingParameters,
  }) {
    return TikzConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
