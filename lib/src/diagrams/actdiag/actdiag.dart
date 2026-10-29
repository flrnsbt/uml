import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/actdiag/types/file_type.dart';
import 'package:uml/src/diagrams/actdiag/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Actdiag diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Actdiag diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Actdiag extends Uml<ActdiagEncodingParameters, ActdiagParameters> {
  Actdiag._();
  static Actdiag? _instance;

  static Actdiag get instance => _instance ??= Actdiag._();

  @override
  String encode(String text,
      [ActdiagEncodingParameters parameters =
          const ActdiagEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    ActdiagParameters parameters = const ActdiagParameters(),
    ActdiagEncodingParameters encodingParameters =
        const ActdiagEncodingParameters(),
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

/// Encoding parameters for Actdiag diagrams.
class ActdiagEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const ActdiagEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  ActdiagEncodingParameters copyWith({UmlTheme? theme}) {
    return ActdiagEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ActdiagEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Actdiag diagram URLs.
class ActdiagParameters
    extends UmlParameters<ActdiagProvider, ActdiagFileType> {
  const ActdiagParameters({
    this.provider = ActdiagProvider.kroki,
    this.type = ActdiagFileType.svg,
  });

  @override
  final ActdiagProvider provider;

  @override
  final ActdiagFileType type;

  @override
  ActdiagParameters copyWith({
    ActdiagProvider? provider,
    ActdiagFileType? type,
  }) {
    return ActdiagParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Actdiag diagrams.
final class ActdiagConfig extends UmlConfig {
  const ActdiagConfig({
    this.parameters = const ActdiagParameters(),
    this.encodingParameters = const ActdiagEncodingParameters(),
  });

  @override
  Actdiag get umlBuilder => Actdiag.instance;

  @override
  List<ActdiagProvider> get allProviders => ActdiagProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final ActdiagParameters parameters;

  @override
  final ActdiagEncodingParameters encodingParameters;

  @override
  ActdiagConfig copyWith({
    ActdiagParameters? parameters,
    ActdiagEncodingParameters? encodingParameters,
  }) {
    return ActdiagConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
