# UML

Generate [PlantUML](https://plantuml.com/) and [Mermaid](https://mermaid.js.org/) diagram URLs with customizable themes, colors, and styling. Supports downloading and saving diagrams as SVG, PNG, WebP, or JPEG.

## Features

- **PlantUML support**: Generate URLs for sequence diagrams, activity diagrams, class diagrams, and more.
- **Mermaid support**: Generate URLs for flowcharts, sequence diagrams, Gantt charts, and more.
- **Customizable themes**: Choose from built-in themes (Darkula, Spacelab, etc.) for PlantUML and (Dark, Forest, etc.) for Mermaid.
- **Fine-grained styling**: Control background colors, font colors, border colors, and more for each diagram element type.
- **Download & save**: Download diagram bytes and save to file on native platforms or trigger browser downloads on web.
- **Multiple providers**: Switch between PlantUML servers (planttext, plantuml.com).
- **Multiple formats**: Export as SVG, PNG, WebP, or JPEG.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  uml: ^1.0.0
```

Then run:

```bash
dart pub get
```

## Usage

### PlantUML

```dart
import 'package:uml/uml.dart';

void main() {
  const code = '''
    @startuml
    Alice -> Bob : Hello
    Bob --> Alice : Hi!
    @enduml
  ''';

  // Generate a default SVG URL
  final url = PlantUml.instance.getUrl(code);
  print(url.url);

  // Generate with custom styling
  final styledUrl = PlantUml.instance.getUrl(
    code,
    parameters: const PlantUmlParameters(
      type: PlantUMLFileType.png,
      encodingParameters: PlantUmlEncodingParameters(
        theme: PlantUMLTheme.darkula,
        backgroundColor: Color(0xFFF0F8FF),
        arrowColor: Color(0xFF0066CC),
        fontSize: 16,
      ),
    ),
  );
  print(styledUrl.url);

  // Download and save
  // final saved = await styledUrl.save(filename: 'my-diagram');
  // print('Saved: ${saved.path}');
}
```

### Mermaid

```dart
import 'package:uml/uml.dart';

void main() {
  const code = 'graph LR; A[Hello] --> B[World]';

  // Generate a default SVG URL
  final url = MermaidUml.instance.getUrl(code);
  print(url.url);

  // Generate with dark theme and PNG format
  final darkUrl = MermaidUml.instance.getUrl(
    code,
    parameters: const MermaidUmlParameters(
      type: MermaidUmlFileType.png,
      encodingParameters: MermaidUmlEncodingParameters(
        theme: MermaidUmlTheme.dark,
      ),
    ),
  );
  print(darkUrl.url);
}
```

### Download & Save

```dart
// Download raw bytes
final bytes = await url.download();
print('Downloaded ${bytes.length} bytes');

// Save to file (native) or trigger download (web)
final saved = await url.save(
  filename: 'my-diagram',
  location: '/path/to/output', // ignored on web
);
print('Saved: ${saved.path}');
```

## API Reference

### PlantUML

| Class | Description |
|-------|-------------|
| `PlantUml` | Singleton for generating PlantUML URLs |
| `PlantUmlParameters` | Provider, file type, and encoding parameters |
| `PlantUmlEncodingParameters` | Theme, colors, fonts, and block-specific styling |
| `PlantUMLFileType` | SVG or PNG |
| `PlantUMLProvider` | planttext or plantuml.com |
| `PlantUMLTheme` | Built-in themes (darkula, spacelab, etc.) |
| `Color` | ARGB32 color with `toHex()` method |
| `TextAlign` | left, right, or center |

### Mermaid

| Class | Description |
|-------|-------------|
| `MermaidUml` | Singleton for generating Mermaid URLs |
| `MermaidUmlParameters` | Provider, file type, and encoding parameters |
| `MermaidUmlEncodingParameters` | Theme selection |
| `MermaidUmlFileType` | SVG, PNG, WebP, or JPEG |
| `MermaidUmlProvider` | mermaid.ink |
| `MermaidUmlTheme` | Built-in themes (default, dark, forest, neutral) |

### Common

| Class | Description |
|-------|-------------|
| `UmlURL` | URL wrapper with `download()` and `save()` methods |
| `SavedFile` | Result of saving a diagram (path and bytes written) |
| `FileType` | Enum: svg, png, webp, jpeg |

## License

MIT License. See [LICENSE](LICENSE) for details.
