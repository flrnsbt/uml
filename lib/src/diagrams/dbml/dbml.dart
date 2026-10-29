import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/dbml/types/file_type.dart';
import 'package:uml/src/diagrams/dbml/types/provider.dart';

export 'types/file_type.dart';
export 'types/provider.dart';

/// Singleton that generates Dbml diagram URLs via Kroki.
/// Kroki (https://kroki.io) renders Dbml diagrams from plain text.
/// Diagram code is compressed with deflate (zlib) + URL-safe base64
/// encoding and embedded in the Kroki URL.
class Dbml extends Uml<DbmlEncodingParameters, DbmlParameters> {
  Dbml._();
  static Dbml? _instance;

  static Dbml get instance => _instance ??= Dbml._();

  @override
  String encode(String text,
      [DbmlEncodingParameters parameters = const DbmlEncodingParameters()]) {
    return krokiEncode(text);
  }

  @override
  UmlURL getUrl(
    String code, {
    DbmlParameters parameters = const DbmlParameters(),
    DbmlEncodingParameters encodingParameters = const DbmlEncodingParameters(),
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

/// Encoding parameters for Dbml diagrams.
class DbmlEncodingParameters extends UmlEncodingParameters<UmlTheme> {
  const DbmlEncodingParameters();

  @override
  final UmlTheme? theme = null;

  @override
  DbmlEncodingParameters copyWith({UmlTheme? theme}) {
    return DbmlEncodingParameters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DbmlEncodingParameters;

  @override
  int get hashCode => 0;
}

/// Parameters for generating Dbml diagram URLs.
class DbmlParameters extends UmlParameters<DbmlProvider, DbmlFileType> {
  const DbmlParameters({
    this.provider = DbmlProvider.kroki,
    this.type = DbmlFileType.svg,
  });

  @override
  final DbmlProvider provider;

  @override
  final DbmlFileType type;

  @override
  DbmlParameters copyWith({
    DbmlProvider? provider,
    DbmlFileType? type,
  }) {
    return DbmlParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for Dbml diagrams.
final class DbmlConfig extends UmlConfig {
  const DbmlConfig({
    this.parameters = const DbmlParameters(),
    this.encodingParameters = const DbmlEncodingParameters(),
  });

  @override
  Dbml get umlBuilder => Dbml.instance;

  @override
  List<DbmlProvider> get allProviders => DbmlProvider.values;

  @override
  List<UmlTheme> get allThemes => const [];

  @override
  final DbmlParameters parameters;

  @override
  final DbmlEncodingParameters encodingParameters;

  @override
  DbmlConfig copyWith({
    DbmlParameters? parameters,
    DbmlEncodingParameters? encodingParameters,
  }) {
    return DbmlConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
