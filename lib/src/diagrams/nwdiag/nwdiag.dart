import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/nwdiag/types/file_type.dart';
import 'package:uml/src/diagrams/nwdiag/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Nwdiag diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Nwdiag diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Nwdiag extends Uml<NwdiagEncodingParameters, NwdiagParameters> {
  Nwdiag._();
  static Nwdiag? _instance;

  static Nwdiag get instance => _instance ??= Nwdiag._();

  @override
  String encode(String text,
      [NwdiagEncodingParameters parameters =
          const NwdiagEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    NwdiagParameters parameters = const NwdiagParameters(),
    NwdiagEncodingParameters encodingParameters =
        const NwdiagEncodingParameters(),
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

/// Encoding parameters for Nwdiag diagrams.
class NwdiagEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const NwdiagEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  NwdiagEncodingParameters copyWith({UmlTheme? theme}) {
    return NwdiagEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NwdiagEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Nwdiag diagram URLs.
class NwdiagParameters extends UmlParameters<NwdiagProvider, NwdiagFileType> {
  const NwdiagParameters({
    this.provider = NwdiagProvider.kroki,
    this.type = NwdiagFileType.svg,
  });

  @override
  final NwdiagProvider provider;

  @override
  final NwdiagFileType type;

  @override
  NwdiagParameters copyWith({
    NwdiagProvider? provider,
    NwdiagFileType? type,
  }) {
    return NwdiagParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Nwdiag diagrams.
final class NwdiagConfig extends UmlConfig {
  const NwdiagConfig({
    this.parameters = const NwdiagParameters(),
    this.encodingParameters = const NwdiagEncodingParameters(),
  });

  @override
  Nwdiag get umlBuilder => Nwdiag.instance;

  @override
  List<NwdiagProvider> get allProviders => NwdiagProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final NwdiagParameters parameters;

  @override
  final NwdiagEncodingParameters encodingParameters;

  @override
  NwdiagConfig copyWith({
    NwdiagParameters? parameters,
    NwdiagEncodingParameters? encodingParameters,
  }) {
    return NwdiagConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
