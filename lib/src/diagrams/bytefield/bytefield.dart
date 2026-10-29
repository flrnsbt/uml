import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/bytefield/types/file_type.dart';
import 'package:uml/src/diagrams/bytefield/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Bytefield diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Bytefield diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Bytefield extends Uml<BytefieldEncodingParameters, BytefieldParameters> {
  Bytefield._();
  static Bytefield? _instance;

  static Bytefield get instance => _instance ??= Bytefield._();

  @override
  String encode(String text,
      [BytefieldEncodingParameters parameters =
          const BytefieldEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    BytefieldParameters parameters = const BytefieldParameters(),
    BytefieldEncodingParameters encodingParameters =
        const BytefieldEncodingParameters(),
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

/// Encoding parameters for Bytefield diagrams.
class BytefieldEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const BytefieldEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  BytefieldEncodingParameters copyWith({UmlTheme? theme}) {
    return BytefieldEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BytefieldEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Bytefield diagram URLs.
class BytefieldParameters
    extends UmlParameters<BytefieldProvider, BytefieldFileType> {
  const BytefieldParameters({
    this.provider = BytefieldProvider.kroki,
    this.type = BytefieldFileType.svg,
  });

  @override
  final BytefieldProvider provider;

  @override
  final BytefieldFileType type;

  @override
  BytefieldParameters copyWith({
    BytefieldProvider? provider,
    BytefieldFileType? type,
  }) {
    return BytefieldParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Bytefield diagrams.
final class BytefieldConfig extends UmlConfig {
  const BytefieldConfig({
    this.parameters = const BytefieldParameters(),
    this.encodingParameters = const BytefieldEncodingParameters(),
  });

  @override
  Bytefield get umlBuilder => Bytefield.instance;

  @override
  List<BytefieldProvider> get allProviders => BytefieldProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final BytefieldParameters parameters;

  @override
  final BytefieldEncodingParameters encodingParameters;

  @override
  BytefieldConfig copyWith({
    BytefieldParameters? parameters,
    BytefieldEncodingParameters? encodingParameters,
  }) {
    return BytefieldConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
