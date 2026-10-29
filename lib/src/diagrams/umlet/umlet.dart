import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/umlet/types/file_type.dart';
import 'package:uml/src/diagrams/umlet/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Umlet diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Umlet diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Umlet extends Uml<UmletEncodingParameters, UmletParameters> {
  Umlet._();
  static Umlet? _instance;

  static Umlet get instance => _instance ??= Umlet._();

  @override
  String encode(String text,
      [UmletEncodingParameters parameters = const UmletEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    UmletParameters parameters = const UmletParameters(),
    UmletEncodingParameters encodingParameters =
        const UmletEncodingParameters(),
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

/// Encoding parameters for Umlet diagrams.
class UmletEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const UmletEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  UmletEncodingParameters copyWith({UmlTheme? theme}) {
    return UmletEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UmletEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Umlet diagram URLs.
class UmletParameters extends UmlParameters<UmletProvider, UmletFileType> {
  const UmletParameters({
    this.provider = UmletProvider.kroki,
    this.type = UmletFileType.svg,
  });

  @override
  final UmletProvider provider;

  @override
  final UmletFileType type;

  @override
  UmletParameters copyWith({
    UmletProvider? provider,
    UmletFileType? type,
  }) {
    return UmletParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Umlet diagrams.
final class UmletConfig extends UmlConfig {
  const UmletConfig({
    this.parameters = const UmletParameters(),
    this.encodingParameters = const UmletEncodingParameters(),
  });

  @override
  Umlet get umlBuilder => Umlet.instance;

  @override
  List<UmletProvider> get allProviders => UmletProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final UmletParameters parameters;

  @override
  final UmletEncodingParameters encodingParameters;

  @override
  UmletConfig copyWith({
    UmletParameters? parameters,
    UmletEncodingParameters? encodingParameters,
  }) {
    return UmletConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
