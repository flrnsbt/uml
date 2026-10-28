import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:test/test.dart';
import 'package:uml/uml.dart';

String _decodePlantUml(String encoded) {
  const plantUml64 =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_';
  final bytes = <int>[];
  for (var i = 0; i < encoded.length; i += 4) {
    final c1 = plantUml64.indexOf(encoded[i]);
    final c2 = i + 1 < encoded.length ? plantUml64.indexOf(encoded[i + 1]) : 0;
    final c3 = i + 2 < encoded.length ? plantUml64.indexOf(encoded[i + 2]) : 0;
    final c4 = i + 3 < encoded.length ? plantUml64.indexOf(encoded[i + 3]) : 0;

    final b1 = (c1 << 2) | (c2 >> 4);
    final b2 = ((c2 & 0xF) << 4) | (c3 >> 2);
    final b3 = ((c3 & 0x3) << 6) | c4;

    bytes.add(b1);
    if (i + 2 < encoded.length) bytes.add(b2);
    if (i + 3 < encoded.length) bytes.add(b3);
  }
  final decompressed = Inflate(bytes).getBytes();
  return utf8.decode(decompressed);
}

void main() {
  group('PlantUml', () {
    test('singleton instance', () {
      expect(PlantUml.instance, PlantUml.instance);
    });

    test('encode returns non-empty string', () {
      final encoded = PlantUml.instance.encode('test');
      expect(encoded, isNotEmpty);
    });

    test('getUrl returns valid URL without trailing brace', () {
      final url = PlantUml.instance.getUrl('test diagram').url;
      expect(url, startsWith('https://'));
      expect(url, isNot(endsWith('}')));
    });

    test('getUrl with custom provider', () {
      final url = PlantUml.instance
          .getUrl(
            'test',
            parameters: PlantUmlParameters(provider: PlantUMLProvider.plantuml),
          )
          .url;
      expect(url, contains('plantuml.com'));
    });

    test('getUrl with custom file type', () {
      final url = PlantUml.instance
          .getUrl(
            'test',
            parameters: PlantUmlParameters(type: PlantUMLFileType.png),
          )
          .url;
      expect(url, contains('/png/'));
    });

    test('getUrl with theme', () {
      final url = PlantUml.instance
          .getUrl(
            'test',
            parameters: PlantUmlParameters(
              encodingParameters: PlantUmlEncodingParameters(
                theme: PlantUmlTheme.darkula,
              ),
            ),
          )
          .url;
      expect(url, isNotEmpty);
    });

    test('copyWith preserves values', () {
      final params = PlantUmlEncodingParameters(
        theme: PlantUmlTheme.darkula,
        backgroundColor: Color(0xFFFF0000),
      );
      final copied = params.copyWith(theme: PlantUmlTheme.plain);
      expect(copied.theme, PlantUmlTheme.plain);
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

  group('MermaidUml', () {
    test('singleton instance', () {
      expect(MermaidUml.instance, MermaidUml.instance);
    });

    test('encode returns pako encoded string', () {
      final encoded = MermaidUml.instance.encode('graph TD; A-->B;');
      expect(encoded, startsWith('pako:'));
    });

    test('getUrl returns valid URL without trailing brace', () {
      final url = MermaidUml.instance.getUrl('graph TD; A-->B;').url;
      expect(url, startsWith('https://'));
      expect(url, isNot(endsWith('}')));
    });

    test('getUrl with SVG type', () {
      final url = MermaidUml.instance
          .getUrl(
            'graph TD; A-->B;',
            parameters: MermaidUmlParameters(type: MermaidUmlFileType.svg),
          )
          .url;
      expect(url, contains('/svg/'));
    });

    test('getUrl with PNG type includes query', () {
      final url = MermaidUml.instance
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

  group('PlantUml theme application', () {
    test('wraps code without @startuml', () {
      final encoded = PlantUml.instance.encode(
        'Alice -> Bob',
        parameters: PlantUmlEncodingParameters(
          backgroundColor: Color(0xFFFFFFFF),
        ),
      );
      expect(encoded, isNotEmpty);
    });

    test('preserves @startuml/@enduml wrapping', () {
      final code = '@startuml\nAlice -> Bob\n@enduml';
      final encoded = PlantUml.instance.encode(
        code,
        parameters: PlantUmlEncodingParameters(fontColor: Color(0xFF000000)),
      );
      expect(encoded, isNotEmpty);
    });

    test('handles empty code', () {
      final encoded = PlantUml.instance.encode('');
      expect(encoded, isNotEmpty);
    });

    test('handles code with special characters', () {
      final code = '@startuml\nAlice -> Bob : Hello & Welcome!\n@enduml';
      final encoded = PlantUml.instance.encode(code);
      expect(encoded, isNotEmpty);
    });

    test('applies block-specific styling', () {
      final code = '@startuml\nAlice -> Bob\n@enduml';
      final encoded = PlantUml.instance.encode(
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
      final encoded = PlantUml.instance.encode(
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
      final encoded = PlantUml.instance.encode(
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
      final encoded = PlantUml.instance.encode(
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
      final encoded = PlantUml.instance.encode(
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
      final encoded = PlantUml.instance.encode(
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
      final encoded = PlantUml.instance.encode(
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
      final encoded = PlantUml.instance.encode(
        code,
        parameters: const PlantUmlEncodingParameters(
          arrowColor: Color(0xFF0066CC),
        ),
      );
      expect(encoded, isNotEmpty);
    });

    test('applies note styling', () {
      final code = '@startuml\nnote: Hello\n@enduml';
      final encoded = PlantUml.instance.encode(
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
      final encoded = PlantUml.instance.encode(
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
      final encoded = PlantUml.instance.encode(
        code,
        parameters: const PlantUmlEncodingParameters(textAlign: TextAlign.left),
      );
      expect(encoded, isNotEmpty);
    });

    test('applies font size', () {
      final code = '@startuml\nAlice -> Bob\n@enduml';
      final encoded = PlantUml.instance.encode(
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
      final encoded = MermaidUml.instance.encode('');
      expect(encoded, startsWith('pako:'));
    });

    test('encode with special characters', () {
      final encoded = MermaidUml.instance.encode(
        'graph TD; A["Hello & World!"] --> B',
      );
      expect(encoded, startsWith('pako:'));
    });

    test('all file types generate valid URLs', () {
      final code = 'graph TD; A --> B';
      for (final type in MermaidUmlFileType.values) {
        final url = MermaidUml.instance.getUrl(
          code,
          parameters: MermaidUmlParameters(type: type),
        );
        expect(url.url, startsWith('https://'));
      }
    });
  });

  group('PlantUML providers', () {
    test('planttext provider URL', () {
      final url = PlantUml.instance
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
      final url = PlantUml.instance
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
      final encoded = PlantUml.instance.encode(
        '@startuml\nAlice -> Bob\n@enduml',
        parameters: const PlantUmlEncodingParameters(
          theme: PlantUmlTheme.darkula,
        ),
      );
      expect(encoded, isNotEmpty);
    });

    test('all themes produce valid encoding', () {
      for (final theme in PlantUmlTheme.values) {
        final encoded = PlantUml.instance.encode(
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
        final encoded = MermaidUml.instance.encode(
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

  group('PlantUML URL structure and formatting', () {
    test('getUrl does not have double slashes in path', () {
      final url = PlantUml.instance.getUrl('Alice -> Bob').url;
      expect(url, isNot(contains('//svg')));
      expect(url, isNot(contains('//png')));
      expect(url, startsWith('https://uml.planttext.com/plantuml/svg/'));
    });

    test('preserves diagram title without corrupting directives', () {
      final encoded = PlantUml.instance.encode(
        '@startuml my_diagram\nAlice -> Bob\n@enduml',
        parameters: const PlantUmlEncodingParameters(
          theme: PlantUmlTheme.plain,
        ),
      );
      final decoded = _decodePlantUml(encoded);
      expect(decoded, contains('@startuml my_diagram\n'));
      expect(decoded, contains('!theme plain\n'));
      expect(decoded, isNot(contains('center my_diagram')));
      expect(decoded, isNot(contains('plain my_diagram')));
    });

    test('indented @startuml does not create nested @startuml blocks', () {
      const code = '''
    @startuml
    Alice -> Bob : Hello
    @enduml
''';
      final encoded = PlantUml.instance.encode(
        code,
        parameters: const PlantUmlEncodingParameters(
          theme: PlantUmlTheme.plain,
        ),
      );
      final decoded = _decodePlantUml(encoded);
      expect(RegExp(r'@startuml').allMatches(decoded).length, equals(1));
      expect(RegExp(r'@enduml').allMatches(decoded).length, equals(1));
    });
  });

  group('Mermaid URL structure', () {
    test('getUrl does not have double slashes in path', () {
      final url = MermaidUml.instance.getUrl('graph LR; A --> B;').url;
      expect(url, isNot(contains('//svg')));
      expect(url, startsWith('https://mermaid.ink/svg/'));
    });
  });

  group('Equality and Value Objects', () {
    test('Color operator == and hashCode', () {
      final c1 = const Color(0xFF112233);
      final c2 = const Color(0xFF112233);
      final c3 = const Color(0xFF445566);
      expect(c1, equals(c2));
      expect(c1.hashCode, equals(c2.hashCode));
      expect(c1, isNot(equals(c3)));
    });

    test('UmlURL operator ==, hashCode, and cachedBytes', () {
      final u1 = UmlURL('https://example.com/a.svg', FileType.svg);
      final u2 = UmlURL('https://example.com/a.svg', FileType.svg);
      final u3 = UmlURL('https://example.com/b.svg', FileType.svg);
      final u4 = UmlURL('https://example.com/a.svg', FileType.png);

      expect(u1, equals(u2));
      expect(u1.hashCode, equals(u2.hashCode));
      expect(u1, isNot(equals(u3)));
      expect(u1, isNot(equals(u4)));
      expect(u1.cachedBytes, isNull);
    });

    test('SavedFile operator == and hashCode', () {
      final s1 = const SavedFile(path: '/path/file.png', bytesWritten: 123);
      final s2 = const SavedFile(path: '/path/file.png', bytesWritten: 123);
      final s3 = const SavedFile(path: '/path/file.png', bytesWritten: 456);
      final s4 = const SavedFile(path: '/other/file.png', bytesWritten: 123);

      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      expect(s1, isNot(equals(s3)));
      expect(s1, isNot(equals(s4)));
    });
  });

  group('Save & Download Utilities', () {
    test('saveUml strips redundant file extension', () async {
      final tempDir = Directory.systemTemp.createTempSync('uml_test_');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final savedPng = await saveUml(
        Uint8List.fromList([1, 2, 3]),
        fileType: FileType.png,
        filename: 'my_diagram.png',
        location: tempDir.path,
      );
      expect(savedPng.path, endsWith('my_diagram.png'));
      expect(savedPng.path, isNot(endsWith('my_diagram.png.png')));

      final savedJpg = await saveUml(
        Uint8List.fromList([1, 2, 3]),
        fileType: FileType.jpeg,
        filename: 'photo.jpg',
        location: tempDir.path,
      );
      expect(savedJpg.path, endsWith('photo.jpeg'));
      expect(savedJpg.path, isNot(endsWith('photo.jpg.jpeg')));
    });
  });
}
