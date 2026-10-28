import 'dart:io';

import 'package:uml/uml.dart';

void main() {
  print('=== UML Library Examples ===\n');

  plantUmlExamples();
  print('\n');

  mermaidExamples();
  print('\n');

  downloadAndSaveExample();
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
  final defaultUrl = PlantUmlUrl.instance.getUrl(code);
  print('Default SVG: ${defaultUrl.url}');

  // 2. PNG export
  final pngUrl = PlantUmlUrl.instance.getUrl(
    code,
    parameters: const PlantUmlParameters(type: PlantUMLFileType.png),
  );
  print('PNG: ${pngUrl.url}');

  // 3. Different provider (plantuml.com)
  final plantumlCom = PlantUmlUrl.instance.getUrl(
    code,
    parameters: const PlantUmlParameters(provider: PlantUMLProvider.plantuml),
  );
  print('plantuml.com: ${plantumlCom.url}');

  // 4. With theme (Darkula)
  final themedUrl = PlantUmlUrl.instance.getUrl(
    code,
    parameters: const PlantUmlParameters(
      encodingParameters: PlantUmlEncodingParameters(
        theme: PlantUMLTheme.darkula,
      ),
    ),
  );
  print('Darkula theme: ${themedUrl.url}');

  // 5. With custom colors and styling
  final styledUrl = PlantUmlUrl.instance.getUrl(
    code,
    parameters: const PlantUmlParameters(
      encodingParameters: PlantUmlEncodingParameters(
        backgroundColor: Color(0xFF_F0_F8_FF),
        fontColor: Color(0xFF_33_33_33),
        arrowColor: Color(0xFF_00_66_CC),
        fontSize: 16,
        textAlign: TextAlign.left,
        noteBackgroundColor: Color(0xFF_FF_FF_CC),
        noteBorderColor: Color(0xFF_CC_CC_00),
      ),
    ),
  );
  print('Styled: ${styledUrl.url}');

  // 6. Block-specific styling (activity, rectangle, class, etc.)
  final blockStyledUrl = PlantUmlUrl.instance.getUrl(
    code,
    parameters: const PlantUmlParameters(
      encodingParameters: PlantUmlEncodingParameters(
        rectangleBackgroundColor: Color(0xFF_EE_FF_EE),
        rectangleFontColor: Color(0xFF_00_66_00),
        rectangleBorderColor: Color(0xFF_00_99_00),
        activityRoundCorner: 10.0,
        activityBackgroundColor: Color(0xFF_FF_F0_EE),
        activityFontColor: Color(0xFF_99_66_00),
        activityBorderColor: Color(0xFF_CC_99_00),
        componentBackgroundColor: Color(0xFF_EE_EE_FF),
        componentFontColor: Color(0xFF_00_00_99),
        componentBorderColor: Color(0xFF_00_00_CC),
      ),
    ),
  );
  print('Block styled: ${blockStyledUrl.url}');

  // 7. Using copyWith to modify parameters
  final baseParams = const PlantUmlParameters(
    type: PlantUMLFileType.svg,
    provider: PlantUMLProvider.planttext,
  );
  final modifiedUrl = PlantUmlUrl.instance.getUrl(
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

  // 1. Default SVG
  final defaultUrl = MermaidUrl.instance.getUrl(code);
  print('Default SVG: ${defaultUrl.url}');

  // 2. PNG export
  final pngUrl = MermaidUrl.instance.getUrl(
    code,
    parameters: const MermaidUmlParameters(type: MermaidUmlFileType.png),
  );
  print('PNG: ${pngUrl.url}');

  // 3. WebP export
  final webpUrl = MermaidUrl.instance.getUrl(
    code,
    parameters: const MermaidUmlParameters(type: MermaidUmlFileType.webp),
  );
  print('WebP: ${webpUrl.url}');

  // 4. JPEG export
  final jpegUrl = MermaidUrl.instance.getUrl(
    code,
    parameters: const MermaidUmlParameters(type: MermaidUmlFileType.jpeg),
  );
  print('JPEG: ${jpegUrl.url}');

  // 5. With dark theme
  final darkUrl = MermaidUrl.instance.getUrl(
    code,
    parameters: const MermaidUmlParameters(
      encodingParameters: MermaidUmlEncodingParameters(
        theme: MermaidUmlTheme.dark,
      ),
    ),
  );
  print('Dark theme: ${darkUrl.url}');

  // 6. With forest theme
  final forestUrl = MermaidUrl.instance.getUrl(
    code,
    parameters: const MermaidUmlParameters(
      encodingParameters: MermaidUmlEncodingParameters(
        theme: MermaidUmlTheme.forest,
      ),
    ),
  );
  print('Forest theme: ${forestUrl.url}');

  // 7. Using copyWith
  final baseParams = const MermaidUmlParameters(type: MermaidUmlFileType.svg);
  final modifiedUrl = MermaidUrl.instance.getUrl(
    code,
    parameters: baseParams.copyWith(
      type: MermaidUmlFileType.png,
      encodingParameters: const MermaidUmlEncodingParameters(
        theme: MermaidUmlTheme.neutral,
      ),
    ),
  );
  print('copyWith modified: ${modifiedUrl.url}');
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
  final umlUrl = PlantUmlUrl.instance.getUrl(
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
  final mermaidUrl = MermaidUrl.instance.getUrl(
    'graph LR; A --> B',
    parameters: const MermaidUmlParameters(type: MermaidUmlFileType.svg),
  );
  final mermaidSaved = await mermaidUrl.save(filename: 'mermaid-flow');
  print('Mermaid saved: ${mermaidSaved.path}');
}
