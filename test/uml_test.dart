import 'package:test/test.dart';
import 'package:uml/uml.dart';

void main() {
  group('PlantUmlUrl', () {
    test('singleton instance', () {
      expect(PlantUmlUrl.instance, PlantUmlUrl.instance);
    });

    test('encode returns non-empty string', () {
      final encoded = PlantUmlUrl.instance.encode('test');
      expect(encoded, isNotEmpty);
    });

    test('getUrl returns valid URL without trailing brace', () {
      final url = PlantUmlUrl.instance.getUrl('test diagram').url;
      expect(url, startsWith('https://'));
      expect(url, isNot(endsWith('}')));
    });

    test('getUrl with custom provider', () {
      final url = PlantUmlUrl.instance
          .getUrl(
            'test',
            parameters: PlantUmlParameters(provider: PlantUMLProvider.plantuml),
          )
          .url;
      expect(url, contains('plantuml.com'));
    });

    test('getUrl with custom file type', () {
      final url = PlantUmlUrl.instance
          .getUrl(
            'test',
            parameters: PlantUmlParameters(type: PlantUMLFileType.png),
          )
          .url;
      expect(url, contains('/png/'));
    });

    test('getUrl with theme', () {
      final url = PlantUmlUrl.instance
          .getUrl(
            'test',
            parameters: PlantUmlParameters(
              encodingParameters: PlantUmlEncodingParameters(
                theme: PlantUMLTheme.darkula,
              ),
            ),
          )
          .url;
      expect(url, isNotEmpty);
    });

    test('copyWith preserves values', () {
      final params = PlantUmlEncodingParameters(
        theme: PlantUMLTheme.darkula,
        backgroundColor: Color(0xFFFF0000),
      );
      final copied = params.copyWith(theme: PlantUMLTheme.plain);
      expect(copied.theme, PlantUMLTheme.plain);
      expect(copied.backgroundColor, params.backgroundColor);
    });

    test('copyWith on PlantUmlParameters', () {
      final params = PlantUmlParameters(
        provider: PlantUMLProvider.plantuml,
        type: PlantUMLFileType.png,
      );
      final copied = params.copyWith(provider: PlantUMLProvider.planttext);
      expect(copied.provider, PlantUMLProvider.planttext);
      expect(copied.type, PlantUMLFileType.png);
    });
  });

  group('MermaidUrl', () {
    test('singleton instance', () {
      expect(MermaidUrl.instance, MermaidUrl.instance);
    });

    test('encode returns pako encoded string', () {
      final encoded = MermaidUrl.instance.encode('graph TD; A-->B;');
      expect(encoded, startsWith('pako:'));
    });

    test('getUrl returns valid URL without trailing brace', () {
      final url = MermaidUrl.instance.getUrl('graph TD; A-->B;').url;
      expect(url, startsWith('https://'));
      expect(url, isNot(endsWith('}')));
    });

    test('getUrl with SVG type', () {
      final url = MermaidUrl.instance
          .getUrl(
            'graph TD; A-->B;',
            parameters: MermaidUmlParameters(type: MermaidUmlFileType.svg),
          )
          .url;
      expect(url, contains('/svg/'));
    });

    test('getUrl with PNG type includes query', () {
      final url = MermaidUrl.instance
          .getUrl(
            'graph TD; A-->B;',
            parameters: MermaidUmlParameters(type: MermaidUmlFileType.png),
          )
          .url;
      expect(url, contains('type=png'));
    });

    test('copyWith on MermaidUmlEncodingParameters', () {
      final params = MermaidUmlEncodingParameters(theme: MermaidUmlTheme.dark);
      final copied = params.copyWith(theme: MermaidUmlTheme.forest);
      expect(copied.theme, MermaidUmlTheme.forest);
    });

    test('copyWith on MermaidUmlParameters', () {
      final params = MermaidUmlParameters(type: MermaidUmlFileType.svg);
      final copied = params.copyWith(type: MermaidUmlFileType.png);
      expect(copied.type, MermaidUmlFileType.png);
    });
  });

  group('Color', () {
    test('toHex converts correctly', () {
      final color = Color(0xFFFF0000);
      expect(color.toHex(), equals('#FF0000'));
    });

    test('toHex ignores alpha channel', () {
      final color = Color(0x80FF0000);
      expect(color.toHex(), equals('#FF0000'));
    });

    test('toHex pads short values', () {
      final color = Color(0xFF00000A);
      expect(color.toHex(), equals('#00000A'));
    });
  });

  group('PlantUmlUrl theme application', () {
    test('wraps code without @startuml', () {
      final encoded = PlantUmlUrl.instance.encode(
        'Alice -> Bob',
        parameters: PlantUmlEncodingParameters(
          backgroundColor: Color(0xFFFFFFFF),
        ),
      );
      expect(encoded, isNotEmpty);
    });

    test('preserves @startuml/@enduml wrapping', () {
      final code = '@startuml\nAlice -> Bob\n@enduml';
      final encoded = PlantUmlUrl.instance.encode(
        code,
        parameters: PlantUmlEncodingParameters(fontColor: Color(0xFF000000)),
      );
      expect(encoded, isNotEmpty);
    });
  });
}
