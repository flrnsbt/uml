// ignore_for_file: avoid_print

import 'dart:io';

import 'package:uml/uml.dart';

void main() async {
  print('=== UML Library Examples ===\n');

  plantUmlExamples();
  print('\n');

  mermaidExamples();
  print('\n');

  krokiDiagramExamples();
  print('\n');

  await downloadAndSaveExample();
}

// ---------------------------------------------------------------------------
// PlantUML examples
// ---------------------------------------------------------------------------

void plantUmlExamples() {
  print('--- PlantUML ---');

  const code = '''
    @startuml
    Alice -> Bob : Hello
    Bob --> Alice : Hi!
    @enduml
  ''';

  // 1. Default SVG URL (planttext provider)
  final defaultUrl = PlantUml.instance.getUrl(code);
  print('Default SVG: ${defaultUrl.url}');

  // 2. PNG export
  final pngUrl = PlantUml.instance.getUrl(
    code,
    parameters: const PlantUmlParameters(type: PlantUMLFileType.png),
  );
  print('PNG: ${pngUrl.url}');

  // 3. Different provider (plantuml.com)
  final plantumlCom = PlantUml.instance.getUrl(
    code,
    parameters: const PlantUmlParameters(provider: PlantUMLProvider.plantuml),
  );
  print('plantuml.com: ${plantumlCom.url}');

  // 3.5. Kroki provider (unified diagram API)
  final krokiUrl = PlantUml.instance.getUrl(
    code,
    parameters: const PlantUmlParameters(provider: PlantUMLProvider.kroki),
  );
  print('Kroki: ${krokiUrl.url}');

  // 4. With theme (Darkula)
  final themedUrl = PlantUml.instance.getUrl(
    code,
    parameters: const PlantUmlParameters(),
    encodingParameters: const PlantUmlEncodingParameters(
      theme: PlantUmlTheme.darkula,
    ),
  );
  print('Darkula theme: ${themedUrl.url}');

  // 5. With custom colors and styling
  final styledUrl = PlantUml.instance.getUrl(
    code,
    parameters: const PlantUmlParameters(),
    encodingParameters: const PlantUmlEncodingParameters(
      styleParameters: PlantUmlEncodingStyleParameters(
        backgroundColor: Color(0xFFF0F8FF),
        fontColor: Color(0xFF333333),
        arrowColor: Color(0xFF0066CC),
        fontSize: 16,
        textAlign: TextAlign.left,
        noteBackgroundColor: Color(0xFFFFFFCC),
        noteBorderColor: Color(0xFFCCCC00),
      ),
    ),
  );
  print('Styled: ${styledUrl.url}');

  // 6. Block-specific styling (activity, rectangle, class, etc.)
  final blockStyledUrl = PlantUml.instance.getUrl(
    code,
    parameters: const PlantUmlParameters(),
    encodingParameters: const PlantUmlEncodingParameters(
      styleParameters: PlantUmlEncodingStyleParameters(
        rectangleBackgroundColor: Color(0xFFEEFFEE),
        rectangleFontColor: Color(0xFF006600),
        rectangleBorderColor: Color(0xFF009900),
        activityRoundCorner: 10.0,
        activityBackgroundColor: Color(0xFFFFF0EE),
        activityFontColor: Color(0xFF996600),
        activityBorderColor: Color(0xFFCC9900),
        componentBackgroundColor: Color(0xFFEEEEFF),
        componentFontColor: Color(0xFF000099),
        componentBorderColor: Color(0xFF0000CC),
      ),
    ),
  );
  print('Block styled: ${blockStyledUrl.url}');

  // 7. Using copyWith to modify parameters
  final baseParams = const PlantUmlParameters(
    type: PlantUMLFileType.svg,
    provider: PlantUMLProvider.planttext,
  );
  final modifiedUrl = PlantUml.instance.getUrl(
    code,
    parameters: baseParams.copyWith(
      type: PlantUMLFileType.png,
      provider: PlantUMLProvider.plantuml,
    ),
  );
  print('copyWith modified: ${modifiedUrl.url}');
}

// ---------------------------------------------------------------------------
// Mermaid examples
// ---------------------------------------------------------------------------

void mermaidExamples() {
  print('--- Mermaid ---');

  const code = '''
    graph LR
      A[Hello] --> B[World]
  ''';

  // Check supported file types for each provider
  print(
      'Mermaid.ink supports: ${MermaidUmlProvider.mermaidink.supportedFileTypes.map((t) => t.name).join(", ")}');
  print(
      'Kroki supports: ${MermaidUmlProvider.kroki.supportedFileTypes.map((t) => t.name).join(", ")}');
  print('');

  // 1. Default SVG
  final defaultUrl = MermaidUml.instance.getUrl(code);
  print('Default SVG: ${defaultUrl.url}');

  // 2. PNG export
  final pngUrl = MermaidUml.instance.getUrl(
    code,
    parameters: const MermaidUmlParameters(type: MermaidUmlFileType.png),
  );
  print('PNG: ${pngUrl.url}');

  // 2.5. Kroki provider (unified diagram API)
  final krokiUrl = MermaidUml.instance.getUrl(
    code,
    parameters: const MermaidUmlParameters(provider: MermaidUmlProvider.kroki),
  );
  print('Kroki: ${krokiUrl.url}');

  // 3. WebP export
  final webpUrl = MermaidUml.instance.getUrl(
    code,
    parameters: const MermaidUmlParameters(type: MermaidUmlFileType.webp),
  );
  print('WebP: ${webpUrl.url}');

  // 4. JPEG export
  final jpegUrl = MermaidUml.instance.getUrl(
    code,
    parameters: const MermaidUmlParameters(type: MermaidUmlFileType.jpeg),
  );
  print('JPEG: ${jpegUrl.url}');

  // 5. PDF export (only supported by Kroki)
  final pdfUrl = MermaidUml.instance.getUrl(
    code,
    parameters: const MermaidUmlParameters(
      provider: MermaidUmlProvider.kroki,
      type: MermaidUmlFileType.pdf,
    ),
  );
  print('PDF (Kroki): ${pdfUrl.url}');

  // 6. With dark theme
  final darkUrl = MermaidUml.instance.getUrl(
    code,
    parameters: const MermaidUmlParameters(),
    encodingParameters: const MermaidUmlEncodingParameters(
      theme: MermaidUmlTheme.dark,
    ),
  );
  print('Dark theme: ${darkUrl.url}');

  // 7. With forest theme
  final forestUrl = MermaidUml.instance.getUrl(
    code,
    parameters: const MermaidUmlParameters(),
    encodingParameters: const MermaidUmlEncodingParameters(
      theme: MermaidUmlTheme.forest,
    ),
  );
  print('Forest theme: ${forestUrl.url}');

  // 8. Using copyWith
  final baseParams = const MermaidUmlParameters(type: MermaidUmlFileType.webp);
  final modifiedUrl = MermaidUml.instance.getUrl(
    code,
    parameters: baseParams.copyWith(
      type: MermaidUmlFileType.png,
    ),
    encodingParameters: const MermaidUmlEncodingParameters(
      theme: MermaidUmlTheme.neutral,
    ),
  );
  print('copyWith modified: ${modifiedUrl.url}');
}

// ---------------------------------------------------------------------------
// Kroki diagram examples (all kroki.io diagram types)
// ---------------------------------------------------------------------------

void krokiDiagramExamples() {
  print('--- Kroki Diagram Types ---');

  final graphvizUrl = Graphviz.instance.getUrl('digraph G { Hello -> World }');
  print('Graphviz (svg): ${graphvizUrl.url}');

  final erdUrl = Erd.instance.getUrl(
    '[Person] *name\nPerson *--1 Location',
    parameters: const ErdParameters(type: ErdFileType.png),
  );
  print('ERD (png): ${erdUrl.url}');

  final blockdiagUrl = Blockdiag.instance.getUrl(
    'blockdiag { A => B; }',
    parameters: const BlockdiagParameters(type: BlockdiagFileType.pdf),
  );
  print('BlockDiag (pdf): ${blockdiagUrl.url}');

  final seqdiagUrl = Seqdiag.instance.getUrl('seqdiag { A => B; }');
  print('SeqDiag (svg): ${seqdiagUrl.url}');
}

// ---------------------------------------------------------------------------
// Download and save example (async)
// ---------------------------------------------------------------------------

Future<void> downloadAndSaveExample() async {
  print('--- Download & Save ---');

  const code = '''
    @startuml
    Alice -> Bob : Hello
    Bob --> Alice : Hi!
    @enduml
  ''';

  // Generate a URL
  final umlUrl = PlantUml.instance.getUrl(
    code,
    parameters: const PlantUmlParameters(type: PlantUMLFileType.png),
  );

  // Download raw bytes
  print('Downloading bytes...');
  final bytes = await umlUrl.download();
  print('Downloaded ${bytes.length} bytes');

  // Save to file with custom filename
  print('Saving to file...');
  final saved = await umlUrl.save(
    filename: 'hello-diagram',
    location: '${Directory.current.path}/output',
  );
  print('Saved: ${saved.path} (${saved.bytesWritten} bytes)');

  // Save with explicit location
  final savedWithLocation = await umlUrl.save(
    filename: 'hello-diagram-2',
    location: '${Directory.current.path}/output',
  );
  print('Saved to location: ${savedWithLocation.path}');

  // Mermaid save example
  final mermaidUml = MermaidUml.instance.getUrl(
    'graph LR; A --> B',
    parameters: const MermaidUmlParameters(type: MermaidUmlFileType.webp),
  );
  final mermaidSaved = await mermaidUml.save(filename: 'mermaid-flow');
  print('Mermaid saved: ${mermaidSaved.path}');
}
