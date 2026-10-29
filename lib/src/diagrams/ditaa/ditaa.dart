import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/ditaa/types/file_type.dart';
import 'package:uml/src/diagrams/ditaa/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Ditaa diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Ditaa diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Ditaa extends Uml<DitaaEncodingParameters, DitaaParameters> {
  Ditaa._();
  static Ditaa? _instance;

  static Ditaa get instance => _instance ??= Ditaa._();

  @override
  String encode(String text,
      [DitaaEncodingParameters parameters = const DitaaEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    DitaaParameters parameters = const DitaaParameters(),
    DitaaEncodingParameters encodingParameters =
        const DitaaEncodingParameters(),
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

/// Encoding parameters for Ditaa diagrams.
class DitaaEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const DitaaEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  DitaaEncodingParameters copyWith({UmlTheme? theme}) {
    return DitaaEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DitaaEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Ditaa diagram URLs.
class DitaaParameters extends UmlParameters<DitaaProvider, DitaaFileType> {
  const DitaaParameters({
    this.provider = DitaaProvider.kroki,
    this.type = DitaaFileType.svg,
  });

  @override
  final DitaaProvider provider;

  @override
  final DitaaFileType type;

  @override
  DitaaParameters copyWith({
    DitaaProvider? provider,
    DitaaFileType? type,
  }) {
    return DitaaParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Ditaa diagrams.
final class DitaaConfig extends UmlConfig {
  const DitaaConfig({
    this.parameters = const DitaaParameters(),
    this.encodingParameters = const DitaaEncodingParameters(),
  });

  @override
  Ditaa get umlBuilder => Ditaa.instance;

  @override
  List<DitaaProvider> get allProviders => DitaaProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final DitaaParameters parameters;

  @override
  final DitaaEncodingParameters encodingParameters;

  @override
  DitaaConfig copyWith({
    DitaaParameters? parameters,
    DitaaEncodingParameters? encodingParameters,
  }) {
    return DitaaConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
