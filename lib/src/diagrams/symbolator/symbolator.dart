import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/symbolator/types/file_type.dart';
import 'package:uml/src/diagrams/symbolator/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Symbolator diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Symbolator diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Symbolator
    extends Uml<SymbolatorEncodingParameters, SymbolatorParameters> {
  Symbolator._();
  static Symbolator? _instance;

  static Symbolator get instance => _instance ??= Symbolator._();

  @override
  String encode(String text,
      [SymbolatorEncodingParameters parameters =
          const SymbolatorEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    SymbolatorParameters parameters = const SymbolatorParameters(),
    SymbolatorEncodingParameters encodingParameters =
        const SymbolatorEncodingParameters(),
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

/// Encoding parameters for Symbolator diagrams.
class SymbolatorEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const SymbolatorEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  SymbolatorEncodingParameters copyWith({UmlTheme? theme}) {
    return SymbolatorEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SymbolatorEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Symbolator diagram URLs.
class SymbolatorParameters
    extends UmlParameters<SymbolatorProvider, SymbolatorFileType> {
  const SymbolatorParameters({
    this.provider = SymbolatorProvider.kroki,
    this.type = SymbolatorFileType.svg,
  });

  @override
  final SymbolatorProvider provider;

  @override
  final SymbolatorFileType type;

  @override
  SymbolatorParameters copyWith({
    SymbolatorProvider? provider,
    SymbolatorFileType? type,
  }) {
    return SymbolatorParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Symbolator diagrams.
final class SymbolatorConfig extends UmlConfig {
  const SymbolatorConfig({
    this.parameters = const SymbolatorParameters(),
    this.encodingParameters = const SymbolatorEncodingParameters(),
  });

  @override
  Symbolator get umlBuilder => Symbolator.instance;

  @override
  List<SymbolatorProvider> get allProviders => SymbolatorProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final SymbolatorParameters parameters;

  @override
  final SymbolatorEncodingParameters encodingParameters;

  @override
  SymbolatorConfig copyWith({
    SymbolatorParameters? parameters,
    SymbolatorEncodingParameters? encodingParameters,
  }) {
    return SymbolatorConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
