import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/rackdiag/types/file_type.dart';
import 'package:uml/src/diagrams/rackdiag/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Rackdiag diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Rackdiag diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Rackdiag extends Uml<RackdiagEncodingParameters, RackdiagParameters> {
  Rackdiag._();
  static Rackdiag? _instance;

  static Rackdiag get instance => _instance ??= Rackdiag._();

  @override
  String encode(String text,
      [RackdiagEncodingParameters parameters =
          const RackdiagEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    RackdiagParameters parameters = const RackdiagParameters(),
    RackdiagEncodingParameters encodingParameters =
        const RackdiagEncodingParameters(),
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

/// Encoding parameters for Rackdiag diagrams.
class RackdiagEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const RackdiagEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  RackdiagEncodingParameters copyWith({UmlTheme? theme}) {
    return RackdiagEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RackdiagEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Rackdiag diagram URLs.
class RackdiagParameters
    extends UmlParameters<RackdiagProvider, RackdiagFileType> {
  const RackdiagParameters({
    this.provider = RackdiagProvider.kroki,
    this.type = RackdiagFileType.svg,
  });

  @override
  final RackdiagProvider provider;

  @override
  final RackdiagFileType type;

  @override
  RackdiagParameters copyWith({
    RackdiagProvider? provider,
    RackdiagFileType? type,
  }) {
    return RackdiagParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Rackdiag diagrams.
final class RackdiagConfig extends UmlConfig {
  const RackdiagConfig({
    this.parameters = const RackdiagParameters(),
    this.encodingParameters = const RackdiagEncodingParameters(),
  });

  @override
  Rackdiag get umlBuilder => Rackdiag.instance;

  @override
  List<RackdiagProvider> get allProviders => RackdiagProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final RackdiagParameters parameters;

  @override
  final RackdiagEncodingParameters encodingParameters;

  @override
  RackdiagConfig copyWith({
    RackdiagParameters? parameters,
    RackdiagEncodingParameters? encodingParameters,
  }) {
    return RackdiagConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
