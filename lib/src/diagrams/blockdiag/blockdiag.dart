import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/blockdiag/types/file_type.dart';
import 'package:uml/src/diagrams/blockdiag/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Blockdiag diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Blockdiag diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Blockdiag extends Uml<BlockdiagEncodingParameters, BlockdiagParameters> {
  Blockdiag._();
  static Blockdiag? _instance;

  static Blockdiag get instance => _instance ??= Blockdiag._();

  @override
  String encode(String text,
      [BlockdiagEncodingParameters parameters =
          const BlockdiagEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    BlockdiagParameters parameters = const BlockdiagParameters(),
    BlockdiagEncodingParameters encodingParameters =
        const BlockdiagEncodingParameters(),
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

/// Encoding parameters for Blockdiag diagrams.
class BlockdiagEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const BlockdiagEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  BlockdiagEncodingParameters copyWith({UmlTheme? theme}) {
    return BlockdiagEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BlockdiagEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Blockdiag diagram URLs.
class BlockdiagParameters
    extends UmlParameters<BlockdiagProvider, BlockdiagFileType> {
  const BlockdiagParameters({
    this.provider = BlockdiagProvider.kroki,
    this.type = BlockdiagFileType.svg,
  });

  @override
  final BlockdiagProvider provider;

  @override
  final BlockdiagFileType type;

  @override
  BlockdiagParameters copyWith({
    BlockdiagProvider? provider,
    BlockdiagFileType? type,
  }) {
    return BlockdiagParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Blockdiag diagrams.
final class BlockdiagConfig extends UmlConfig {
  const BlockdiagConfig({
    this.parameters = const BlockdiagParameters(),
    this.encodingParameters = const BlockdiagEncodingParameters(),
  });

  @override
  Blockdiag get umlBuilder => Blockdiag.instance;

  @override
  List<BlockdiagProvider> get allProviders => BlockdiagProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final BlockdiagParameters parameters;

  @override
  final BlockdiagEncodingParameters encodingParameters;

  @override
  BlockdiagConfig copyWith({
    BlockdiagParameters? parameters,
    BlockdiagEncodingParameters? encodingParameters,
  }) {
    return BlockdiagConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
