import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/d2/types/file_type.dart';
import 'package:uml/src/diagrams/d2/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates D2 diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders D2 diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class D2 extends Uml<D2EncodingParameters, D2Parameters> {
  D2._();
  static D2? _instance;

  static D2 get instance => _instance ??= D2._();

  @override
  String encode(String text,
      [D2EncodingParameters parameters = const D2EncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    D2Parameters parameters = const D2Parameters(),
    D2EncodingParameters encodingParameters = const D2EncodingParameters(),
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

/// Encoding parameters for D2 diagrams.
class D2EncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const D2EncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  D2EncodingParameters copyWith({UmlTheme? theme}) {
    return D2EncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is D2EncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating D2 diagram URLs.
class D2Parameters extends UmlParameters<D2Provider, D2FileType> {
  const D2Parameters({
    this.provider = D2Provider.kroki,
    this.type = D2FileType.svg,
  });

  @override
  final D2Provider provider;

  @override
  final D2FileType type;

  @override
  D2Parameters copyWith({
    D2Provider? provider,
    D2FileType? type,
  }) {
    return D2Parameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for D2 diagrams.
final class D2Config extends UmlConfig {
  const D2Config({
    this.parameters = const D2Parameters(),
    this.encodingParameters = const D2EncodingParameters(),
  });

  @override
  D2 get umlBuilder => D2.instance;

  @override
  List<D2Provider> get allProviders => D2Provider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final D2Parameters parameters;

  @override
  final D2EncodingParameters encodingParameters;

  @override
  D2Config copyWith({
    D2Parameters? parameters,
    D2EncodingParameters? encodingParameters,
  }) {
    return D2Config(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
