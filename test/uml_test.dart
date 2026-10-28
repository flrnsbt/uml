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

    test('handles empty code', () {
      final encoded = PlantUmlUrl.instance.encode('');
      expect(encoded, isNotEmpty);
    });

    test('handles code with special characters', () {
      final code = '@startuml\nAlice -> Bob : Hello & Welcome!\n@enduml';
      final encoded = PlantUmlUrl.instance.encode(code);
      expect(encoded, isNotEmpty);
    });

    test('applies block-specific styling', () {
      final code = '@startuml\nAlice -> Bob\n@enduml';
      final encoded = PlantUmlUrl.instance.encode(
        code,
        parameters: PlantUmlEncodingParameters(
          rectangleBackgroundColor: Color(0xFFEEFFEE),
          rectangleFontColor: Color(0xFF006600),
          rectangleBorderColor: Color(0xFF009900),
          activityRoundCorner: 10.0,
        ),
      );
      expect(encoded, isNotEmpty);
    });

    test('applies activity styling', () {
      final code = '@startuml\nstart\n@enduml';
      final encoded = PlantUmlUrl.instance.encode(
        code,
        parameters: PlantUmlEncodingParameters(
          activityBackgroundColor: Color(0xFFFFF0EE),
          activityFontColor: Color(0xFF996600),
          activityBorderColor: Color(0xFFCC9900),
          activityStartColor: Color(0xFF00FF00),
          activityEndColor: Color(0xFFFF0000),
          activityEndBackgroundColor: Color(0xFFFFCCCC),
          activityEndBorderColor: Color(0xFFCC0000),
          activityDiamondBackgroundColor: Color(0xFFFFCC00),
        ),
      );
      expect(encoded, isNotEmpty);
    });

    test('applies component styling', () {
      final code = '@startuml\ncomponent A\n@enduml';
      final encoded = PlantUmlUrl.instance.encode(
        code,
        parameters: PlantUmlEncodingParameters(
          componentBackgroundColor: Color(0xFFEEEEFF),
          componentFontColor: Color(0xFF000099),
          componentBorderColor: Color(0xFF0000CC),
        ),
      );
      expect(encoded, isNotEmpty);
    });

    test('applies interface styling', () {
      final code = '@startuml\ninterface A\n@enduml';
      final encoded = PlantUmlUrl.instance.encode(
        code,
        parameters: PlantUmlEncodingParameters(
          interfaceBackgroundColor: Color(0xFFFFEEEE),
          interfaceFontColor: Color(0xFF990000),
          interfaceBorderColor: Color(0xFFCC0000),
        ),
      );
      expect(encoded, isNotEmpty);
    });

    test('applies package styling', () {
      final code = '@startuml\npackage A\n@enduml';
      final encoded = PlantUmlUrl.instance.encode(
        code,
        parameters: PlantUmlEncodingParameters(
          packageBackgroundColor: Color(0xFFEEEEEE),
          packageFontColor: Color(0xFF333333),
          packageBorderColor: Color(0xFF666666),
        ),
      );
      expect(encoded, isNotEmpty);
    });

    test('applies sequence styling', () {
      final code = '@startuml\nAlice -> Bob\n@enduml';
      final encoded = PlantUmlUrl.instance.encode(
        code,
        parameters: PlantUmlEncodingParameters(
          sequenceBackgroundColor: Color(0xFFFFFEEE),
          sequenceFontColor: Color(0xFF666600),
          sequenceBorderColor: Color(0xFF999900),
        ),
      );
      expect(encoded, isNotEmpty);
    });

    test('applies class styling', () {
      final code = '@startuml\nclass A\n@enduml';
      final encoded = PlantUmlUrl.instance.encode(
        code,
        parameters: PlantUmlEncodingParameters(
          classBackgroundColor: Color(0xFFEEF0FF),
          classFontColor: Color(0xFF000066),
          classBorderColor: Color(0xFF000099),
        ),
      );
      expect(encoded, isNotEmpty);
    });

    test('applies arrow color', () {
      final code = '@startuml\nAlice -> Bob\n@enduml';
      final encoded = PlantUmlUrl.instance.encode(
        code,
        parameters: const PlantUmlEncodingParameters(
          arrowColor: Color(0xFF0066CC),
        ),
      );
      expect(encoded, isNotEmpty);
    });

    test('applies note styling', () {
      final code = '@startuml\nnote: Hello\n@enduml';
      final encoded = PlantUmlUrl.instance.encode(
        code,
        parameters: const PlantUmlEncodingParameters(
          noteFontColor: Color(0xFFCC0000),
          noteBackgroundColor: Color(0xFFFFFFCC),
          noteBorderColor: Color(0xFFCCCC00),
        ),
      );
      expect(encoded, isNotEmpty);
    });

    test('applies partition styling', () {
      final code = '@startuml\n|partition|\n@enduml';
      final encoded = PlantUmlUrl.instance.encode(
        code,
        parameters: const PlantUmlEncodingParameters(
          partitionBackgroundColor: Color(0xFFF0F0FF),
          partitionFontColor: Color(0xFF333366),
          partitionBorderColor: Color(0xFF666699),
        ),
      );
      expect(encoded, isNotEmpty);
    });

    test('applies text alignment', () {
      final code = '@startuml\nAlice -> Bob\n@enduml';
      final encoded = PlantUmlUrl.instance.encode(
        code,
        parameters: const PlantUmlEncodingParameters(textAlign: TextAlign.left),
      );
      expect(encoded, isNotEmpty);
    });

    test('applies font size', () {
      final code = '@startuml\nAlice -> Bob\n@enduml';
      final encoded = PlantUmlUrl.instance.encode(
        code,
        parameters: const PlantUmlEncodingParameters(fontSize: 18),
      );
      expect(encoded, isNotEmpty);
    });
  });

  group('Color edge cases', () {
    test('toHex with zero value', () {
      final color = const Color(0xFF000000);
      expect(color.toHex(), equals('#000000'));
    });

    test('toHex with max value', () {
      final color = const Color(0xFFFFFFFF);
      expect(color.toHex(), equals('#FFFFFF'));
    });

    test('toHex with mixed values', () {
      final color = const Color(0xFF804020);
      expect(color.toHex(), equals('#804020'));
    });

    test('toString format', () {
      final color = const Color(0xFFFF0000);
      expect(color.toString(), contains('ffff0000'));
    });
  });

  group('UmlURL', () {
    test('toString format', () {
      final url = UmlURL('https://example.com/diagram.svg', FileType.svg);
      expect(url.toString(), contains('https://example.com/diagram.svg'));
      expect(url.toString(), contains('FileType.svg'));
    });
  });

  group('Mermaid edge cases', () {
    test('encode with empty code', () {
      final encoded = MermaidUrl.instance.encode('');
      expect(encoded, startsWith('pako:'));
    });

    test('encode with special characters', () {
      final encoded = MermaidUrl.instance.encode(
        'graph TD; A["Hello & World!"] --> B',
      );
      expect(encoded, startsWith('pako:'));
    });

    test('all file types generate valid URLs', () {
      final code = 'graph TD; A --> B';
      for (final type in MermaidUmlFileType.values) {
        final url = MermaidUrl.instance.getUrl(
          code,
          parameters: MermaidUmlParameters(type: type),
        );
        expect(url.url, startsWith('https://'));
      }
    });
  });

  group('PlantUML providers', () {
    test('planttext provider URL', () {
      final url = PlantUmlUrl.instance
          .getUrl(
            'test',
            parameters: const PlantUmlParameters(
              provider: PlantUMLProvider.planttext,
            ),
          )
          .url;
      expect(url, contains('planttext.com'));
    });

    test('plantuml provider URL', () {
      final url = PlantUmlUrl.instance
          .getUrl(
            'test',
            parameters: const PlantUmlParameters(
              provider: PlantUMLProvider.plantuml,
            ),
          )
          .url;
      expect(url, contains('plantuml.com'));
    });
  });

  group('PlantUML themes with external dependencies', () {
    test('darkula theme includes external dependency', () {
      final encoded = PlantUmlUrl.instance.encode(
        '@startuml\nAlice -> Bob\n@enduml',
        parameters: const PlantUmlEncodingParameters(
          theme: PlantUMLTheme.darkula,
        ),
      );
      expect(encoded, isNotEmpty);
    });

    test('all themes produce valid encoding', () {
      for (final theme in PlantUMLTheme.values) {
        final encoded = PlantUmlUrl.instance.encode(
          '@startuml\nAlice -> Bob\n@enduml',
          parameters: PlantUmlEncodingParameters(theme: theme),
        );
        expect(encoded, isNotEmpty, reason: 'Theme $theme should encode');
      }
    });
  });

  group('Mermaid themes', () {
    test('all themes produce valid encoding', () {
      for (final theme in MermaidUmlTheme.values) {
        final encoded = MermaidUrl.instance.encode(
          'graph TD; A --> B',
          parameters: MermaidUmlEncodingParameters(theme: theme),
        );
        expect(
          encoded,
          startsWith('pako:'),
          reason: 'Theme $theme should encode',
        );
      }
    });
  });
}
