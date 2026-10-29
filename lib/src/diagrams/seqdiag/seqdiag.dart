import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/seqdiag/types/file_type.dart';
import 'package:uml/src/diagrams/seqdiag/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Seqdiag diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Seqdiag diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Seqdiag extends Uml<SeqdiagEncodingParameters, SeqdiagParameters> {
  Seqdiag._();
  static Seqdiag? _instance;

  static Seqdiag get instance => _instance ??= Seqdiag._();

  @override
  String encode(String text,
      [SeqdiagEncodingParameters parameters =
          const SeqdiagEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    SeqdiagParameters parameters = const SeqdiagParameters(),
    SeqdiagEncodingParameters encodingParameters =
        const SeqdiagEncodingParameters(),
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

/// Encoding parameters for Seqdiag diagrams.
class SeqdiagEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const SeqdiagEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  SeqdiagEncodingParameters copyWith({UmlTheme? theme}) {
    return SeqdiagEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SeqdiagEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Seqdiag diagram URLs.
class SeqdiagParameters
    extends UmlParameters<SeqdiagProvider, SeqdiagFileType> {
  const SeqdiagParameters({
    this.provider = SeqdiagProvider.kroki,
    this.type = SeqdiagFileType.svg,
  });

  @override
  final SeqdiagProvider provider;

  @override
  final SeqdiagFileType type;

  @override
  SeqdiagParameters copyWith({
    SeqdiagProvider? provider,
    SeqdiagFileType? type,
  }) {
    return SeqdiagParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Seqdiag diagrams.
final class SeqdiagConfig extends UmlConfig {
  const SeqdiagConfig({
    this.parameters = const SeqdiagParameters(),
    this.encodingParameters = const SeqdiagEncodingParameters(),
  });

  @override
  Seqdiag get umlBuilder => Seqdiag.instance;

  @override
  List<SeqdiagProvider> get allProviders => SeqdiagProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final SeqdiagParameters parameters;

  @override
  final SeqdiagEncodingParameters encodingParameters;

  @override
  SeqdiagConfig copyWith({
    SeqdiagParameters? parameters,
    SeqdiagEncodingParameters? encodingParameters,
  }) {
    return SeqdiagConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
