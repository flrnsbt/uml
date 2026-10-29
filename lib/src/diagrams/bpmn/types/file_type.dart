import 'package:uml/src/base.dart';
import 'package:uml/src/download/download.dart';

/// Supported file types for Bpmn diagram exports via Kroki.
enum BpmnFileType implements FileTypeBase {
  svg(FileType.svg),
  ;

  const BpmnFileType(this.type);

  @override
  final FileType type;

  @override
  String getPath() => type.name;
}
