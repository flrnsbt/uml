import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/graphviz/types/file_type.dart';
import 'package:uml/src/diagrams/graphviz/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Graphviz diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Graphviz diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Graphviz extends Uml<GraphvizEncodingParameters, GraphvizParameters> {
  Graphviz._();
  static Graphviz? _instance;

  static Graphviz get instance => _instance ??= Graphviz._();

  @override
  String encode(String text,
      [GraphvizEncodingParameters parameters =
          const GraphvizEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    GraphvizParameters parameters = const GraphvizParameters(),
    GraphvizEncodingParameters encodingParameters =
        const GraphvizEncodingParameters(),
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

/// Encoding parameters for Graphviz diagrams.
class GraphvizEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const GraphvizEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  GraphvizEncodingParameters copyWith({UmlTheme? theme}) {
    return GraphvizEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GraphvizEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Graphviz diagram URLs.
class GraphvizParameters
    extends UmlParameters<GraphvizProvider, GraphvizFileType> {
  const GraphvizParameters({
    this.provider = GraphvizProvider.kroki,
    this.type = GraphvizFileType.svg,
  });

  @override
  final GraphvizProvider provider;

  @override
  final GraphvizFileType type;

  @override
  GraphvizParameters copyWith({
    GraphvizProvider? provider,
    GraphvizFileType? type,
  }) {
    return GraphvizParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Graphviz diagrams.
final class GraphvizConfig extends UmlConfig {
  const GraphvizConfig({
    this.parameters = const GraphvizParameters(),
    this.encodingParameters = const GraphvizEncodingParameters(),
  });

  @override
  Graphviz get umlBuilder => Graphviz.instance;

  @override
  List<GraphvizProvider> get allProviders => GraphvizProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final GraphvizParameters parameters;

  @override
  final GraphvizEncodingParameters encodingParameters;

  @override
  GraphvizConfig copyWith({
    GraphvizParameters? parameters,
    GraphvizEncodingParameters? encodingParameters,
  }) {
    return GraphvizConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
