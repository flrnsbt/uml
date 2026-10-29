import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/packetdiag/types/file_type.dart';
import 'package:uml/src/diagrams/packetdiag/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Packetdiag diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Packetdiag diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Packetdiag
    extends Uml<PacketdiagEncodingParameters, PacketdiagParameters> {
  Packetdiag._();
  static Packetdiag? _instance;

  static Packetdiag get instance => _instance ??= Packetdiag._();

  @override
  String encode(String text,
      [PacketdiagEncodingParameters parameters =
          const PacketdiagEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    PacketdiagParameters parameters = const PacketdiagParameters(),
    PacketdiagEncodingParameters encodingParameters =
        const PacketdiagEncodingParameters(),
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

/// Encoding parameters for Packetdiag diagrams.
class PacketdiagEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const PacketdiagEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  PacketdiagEncodingParameters copyWith({UmlTheme? theme}) {
    return PacketdiagEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PacketdiagEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Packetdiag diagram URLs.
class PacketdiagParameters
    extends UmlParameters<PacketdiagProvider, PacketdiagFileType> {
  const PacketdiagParameters({
    this.provider = PacketdiagProvider.kroki,
    this.type = PacketdiagFileType.svg,
  });

  @override
  final PacketdiagProvider provider;

  @override
  final PacketdiagFileType type;

  @override
  PacketdiagParameters copyWith({
    PacketdiagProvider? provider,
    PacketdiagFileType? type,
  }) {
    return PacketdiagParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Packetdiag diagrams.
final class PacketdiagConfig extends UmlConfig {
  const PacketdiagConfig({
    this.parameters = const PacketdiagParameters(),
    this.encodingParameters = const PacketdiagEncodingParameters(),
  });

  @override
  Packetdiag get umlBuilder => Packetdiag.instance;

  @override
  List<PacketdiagProvider> get allProviders => PacketdiagProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final PacketdiagParameters parameters;

  @override
  final PacketdiagEncodingParameters encodingParameters;

  @override
  PacketdiagConfig copyWith({
    PacketdiagParameters? parameters,
    PacketdiagEncodingParameters? encodingParameters,
  }) {
    return PacketdiagConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
