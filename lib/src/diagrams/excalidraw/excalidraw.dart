import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/excalidraw/types/file_type.dart';
import 'package:uml/src/diagrams/excalidraw/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Excalidraw diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Excalidraw diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Excalidraw
    extends Uml<ExcalidrawEncodingParameters, ExcalidrawParameters> {
  Excalidraw._();
  static Excalidraw? _instance;

  static Excalidraw get instance => _instance ??= Excalidraw._();

  @override
  String encode(String text,
      [ExcalidrawEncodingParameters parameters =
          const ExcalidrawEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    ExcalidrawParameters parameters = const ExcalidrawParameters(),
    ExcalidrawEncodingParameters encodingParameters =
        const ExcalidrawEncodingParameters(),
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

/// Encoding parameters for Excalidraw diagrams.
class ExcalidrawEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const ExcalidrawEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  ExcalidrawEncodingParameters copyWith({UmlTheme? theme}) {
    return ExcalidrawEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ExcalidrawEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Excalidraw diagram URLs.
class ExcalidrawParameters
    extends UmlParameters<ExcalidrawProvider, ExcalidrawFileType> {
  const ExcalidrawParameters({
    this.provider = ExcalidrawProvider.kroki,
    this.type = ExcalidrawFileType.svg,
  });

  @override
  final ExcalidrawProvider provider;

  @override
  final ExcalidrawFileType type;

  @override
  ExcalidrawParameters copyWith({
    ExcalidrawProvider? provider,
    ExcalidrawFileType? type,
  }) {
    return ExcalidrawParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Excalidraw diagrams.
final class ExcalidrawConfig extends UmlConfig {
  const ExcalidrawConfig({
    this.parameters = const ExcalidrawParameters(),
    this.encodingParameters = const ExcalidrawEncodingParameters(),
  });

  @override
  Excalidraw get umlBuilder => Excalidraw.instance;

  @override
  List<ExcalidrawProvider> get allProviders => ExcalidrawProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final ExcalidrawParameters parameters;

  @override
  final ExcalidrawEncodingParameters encodingParameters;

  @override
  ExcalidrawConfig copyWith({
    ExcalidrawParameters? parameters,
    ExcalidrawEncodingParameters? encodingParameters,
  }) {
    return ExcalidrawConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
