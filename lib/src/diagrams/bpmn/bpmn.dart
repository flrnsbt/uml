import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/bpmn/types/file_type.dart';
import 'package:uml/src/diagrams/bpmn/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Bpmn diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Bpmn diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Bpmn extends Uml<BpmnEncodingParameters, BpmnParameters> {
  Bpmn._();
  static Bpmn? _instance;

  static Bpmn get instance => _instance ??= Bpmn._();

  @override
  String encode(String text,
      [BpmnEncodingParameters parameters = const BpmnEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    BpmnParameters parameters = const BpmnParameters(),
    BpmnEncodingParameters encodingParameters = const BpmnEncodingParameters(),
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

/// Encoding parameters for Bpmn diagrams.
class BpmnEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const BpmnEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  BpmnEncodingParameters copyWith({UmlTheme? theme}) {
    return BpmnEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BpmnEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Bpmn diagram URLs.
class BpmnParameters extends UmlParameters<BpmnProvider, BpmnFileType> {
  const BpmnParameters({
    this.provider = BpmnProvider.kroki,
    this.type = BpmnFileType.svg,
  });

  @override
  final BpmnProvider provider;

  @override
  final BpmnFileType type;

  @override
  BpmnParameters copyWith({
    BpmnProvider? provider,
    BpmnFileType? type,
  }) {
    return BpmnParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Bpmn diagrams.
final class BpmnConfig extends UmlConfig {
  const BpmnConfig({
    this.parameters = const BpmnParameters(),
    this.encodingParameters = const BpmnEncodingParameters(),
  });

  @override
  Bpmn get umlBuilder => Bpmn.instance;

  @override
  List<BpmnProvider> get allProviders => BpmnProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final BpmnParameters parameters;

  @override
  final BpmnEncodingParameters encodingParameters;

  @override
  BpmnConfig copyWith({
    BpmnParameters? parameters,
    BpmnEncodingParameters? encodingParameters,
  }) {
    return BpmnConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
