import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/erd/types/file_type.dart';
import 'package:uml/src/diagrams/erd/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Erd diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Erd diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Erd extends Uml<ErdEncodingParameters, ErdParameters> {
  Erd._();
  static Erd? _instance;

  static Erd get instance => _instance ??= Erd._();

  @override
  String encode(String text,
      [ErdEncodingParameters parameters = const ErdEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    ErdParameters parameters = const ErdParameters(),
    ErdEncodingParameters encodingParameters = const ErdEncodingParameters(),
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

/// Encoding parameters for Erd diagrams.
class ErdEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const ErdEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  ErdEncodingParameters copyWith({UmlTheme? theme}) {
    return ErdEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ErdEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Erd diagram URLs.
class ErdParameters extends UmlParameters<ErdProvider, ErdFileType> {
  const ErdParameters({
    this.provider = ErdProvider.kroki,
    this.type = ErdFileType.svg,
  });

  @override
  final ErdProvider provider;

  @override
  final ErdFileType type;

  @override
  ErdParameters copyWith({
    ErdProvider? provider,
    ErdFileType? type,
  }) {
    return ErdParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Erd diagrams.
final class ErdConfig extends UmlConfig {
  const ErdConfig({
    this.parameters = const ErdParameters(),
    this.encodingParameters = const ErdEncodingParameters(),
  });

  @override
  Erd get umlBuilder => Erd.instance;

  @override
  List<ErdProvider> get allProviders => ErdProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final ErdParameters parameters;

  @override
  final ErdEncodingParameters encodingParameters;

  @override
  ErdConfig copyWith({
    ErdParameters? parameters,
    ErdEncodingParameters? encodingParameters,
  }) {
    return ErdConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
