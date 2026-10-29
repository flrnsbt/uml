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

/// Helper to check if bytes match expected file signatures
bool _isValidFileFormat(Uint8List bytes, FileType type) {
  if (bytes.isEmpty) return false;

  switch (type) {
    case FileType.png:
      // PNG magic bytes: 89 50 4E 47 0D 0A 1A 0A
      return bytes.length >= 8 &&
          bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47 &&
          bytes[4] == 0x0D &&
          bytes[5] == 0x0A &&
          bytes[6] == 0x1A &&
          bytes[7] == 0x0A;
    case FileType.jpeg:
      // JPEG magic bytes: FF D8 FF
      return bytes.length >= 3 &&
          bytes[0] == 0xFF &&
          bytes[1] == 0xD8 &&
          bytes[2] == 0xFF;
    case FileType.webp:
      // WebP magic bytes: 52 49 46 46 ... 57 45 42 50 (RIFF...WEBP)
      return bytes.length >= 12 &&
          bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46 &&
          bytes[8] == 0x57 &&
          bytes[9] == 0x45 &&
          bytes[10] == 0x42 &&
          bytes[11] == 0x50;
    case FileType.svg:
      // SVG should start with <svg or <?xml (or contain it near the start)
      final header = String.fromCharCodes(bytes.take(1024));
      return header.contains('<svg') || header.contains('<?xml');
    case FileType.pdf:
      // PDF magic bytes: 25 50 44 46 (%PDF)
      return bytes.length >= 4 &&
          bytes[0] == 0x25 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x44 &&
          bytes[3] == 0x46;
    case FileType.txt:
      // Text should be valid UTF-8
      try {
        utf8.decode(bytes);
        return true;
      } catch (_) {
        return false;
      }
  }
}

void main() {
  group('URL Generation', () {
    group('PlantUML', () {
      test('generates valid URLs with different providers', () {
        final planttextUrl = PlantUml.instance
            .getUrl('Alice -> Bob',
                parameters: const PlantUmlParameters(
                    provider: PlantUMLProvider.planttext))
            .url;
        expect(planttextUrl, contains('planttext.com'));

        final plantumlUrl = PlantUml.instance
            .getUrl('Alice -> Bob',
                parameters: const PlantUmlParameters(
                    provider: PlantUMLProvider.plantuml))
            .url;
        expect(plantumlUrl, contains('plantuml.com'));

        final krokiUrl = PlantUml.instance
            .getUrl('Alice -> Bob',
                parameters: const PlantUmlParameters(
                    provider: PlantUMLProvider.kroki))
            .url;
        expect(krokiUrl, contains('kroki.io'));
      });

      test('generates URLs without trailing brace', () {
        final url = PlantUml.instance.getUrl('test diagram').url;
        expect(url, startsWith('https://'));
        expect(url, isNot(endsWith('}')));
      });

      test('includes file type in URL path', () {
        final pngUrl = PlantUml.instance
            .getUrl('test',
                parameters: const PlantUmlParameters(type: PlantUMLFileType.png))
            .url;
        expect(pngUrl, contains('/png/'));

        final txtUrl = PlantUml.instance
            .getUrl('test',
                parameters: const PlantUmlParameters(type: PlantUMLFileType.txt))
            .url;
        expect(txtUrl, contains('/txt/'));
      });
    });

    group('Mermaid', () {
      test('generates valid URLs with different providers', () {
        final mermaidinkUrl = MermaidUml.instance
            .getUrl('graph TD; A-->B;',
                parameters: const MermaidUmlParameters(
                    provider: MermaidUmlProvider.mermaidink))
            .url;
        expect(mermaidinkUrl, contains('mermaid.ink'));

        final krokiUrl = MermaidUml.instance
            .getUrl('graph TD; A-->B;',
                parameters: const MermaidUmlParameters(
                    provider: MermaidUmlProvider.kroki))
            .url;
        expect(krokiUrl, contains('kroki.io'));
      });

      test('generates URLs without trailing brace', () {
        final url = MermaidUml.instance.getUrl('graph TD; A-->B;').url;
        expect(url, startsWith('https://'));
        expect(url, isNot(endsWith('}')));
      });

      test('includes file type in URL path or query', () {
        final pngUrl = MermaidUml.instance
            .getUrl('graph TD; A-->B;',
                parameters: const MermaidUmlParameters(
                    type: MermaidUmlFileType.png))
            .url;
        expect(pngUrl, contains('type=png'));
      });

      test('throws for unsupported file type combinations', () {
        expect(
            () => MermaidUml.instance.getUrl('graph TD; A-->B;',
                parameters: const MermaidUmlParameters(
                    provider: MermaidUmlProvider.kroki,
                    type: MermaidUmlFileType.webp)),
            throwsArgumentError);

        expect(
            () => MermaidUml.instance.getUrl('graph TD; A-->B;',
                parameters: const MermaidUmlParameters(
                    provider: MermaidUmlProvider.kroki,
                    type: MermaidUmlFileType.pdf)),
            throwsArgumentError);

        expect(
            () => MermaidUml.instance.getUrl('graph TD; A-->B;',
                parameters: const MermaidUmlParameters(
                    provider: MermaidUmlProvider.mermaidink,
                    type: MermaidUmlFileType.pdf)),
            throwsArgumentError);
      });
    });

    group('Kroki Diagrams', () {
      test('generates valid URLs for all diagram types', () {
        final instances = <Uml<dynamic, dynamic>>[
          Graphviz.instance,
          Erd.instance,
          Blockdiag.instance,
          Seqdiag.instance,
          Actdiag.instance,
          Nwdiag.instance,
          Packetdiag.instance,
          Rackdiag.instance,
          Bpmn.instance,
          Bytefield.instance,
          Ditaa.instance,
          Nomnoml.instance,
          Pikchr.instance,
          Structurizr.instance,
          Tikz.instance,
          Umlet.instance,
          Vega.instance,
          VegaLite.instance,
          Wavedrom.instance,
          Wireviz.instance,
          C4Plantuml.instance,
          D2.instance,
          Dbml.instance,
          Excalidraw.instance,
          Goat.instance,
          Lini.instance,
          Svgbob.instance,
          Symbolator.instance,
        ];
        for (final instance in instances) {
          final url = instance.getUrl('test');
          expect(url.url, startsWith('https://kroki.io/'),
              reason: '${instance.runtimeType} should produce a kroki URL');
        }
      });

      test('generates URLs with different file types for Graphviz', () {
        final svgUrl = Graphviz.instance.getUrl('digraph G { A -> B }');
        expect(svgUrl.url, startsWith('https://kroki.io/graphviz/svg/'));

        final pngUrl = Graphviz.instance.getUrl('digraph G { A -> B }',
            parameters: const GraphvizParameters(type: GraphvizFileType.png));
        expect(pngUrl.url, startsWith('https://kroki.io/graphviz/png/'));

        final pdfUrl = Graphviz.instance.getUrl('digraph G { A -> B }',
            parameters: const GraphvizParameters(type: GraphvizFileType.pdf));
        expect(pdfUrl.url, startsWith('https://kroki.io/graphviz/pdf/'));
      });

      test('generates correct URL for VegaLite using vegalite slug', () {
        final url = VegaLite.instance.getUrl('{"mark": "point"}');
        expect(url.url, startsWith('https://kroki.io/vegalite/svg/'));
      });
    });
  });

  group('Provider Support', () {
    test('PlantUML providers support correct file types', () {
      expect(PlantUMLProvider.planttext.supportsFileType(FileType.svg), isTrue);
      expect(PlantUMLProvider.planttext.supportsFileType(FileType.png), isTrue);
      expect(PlantUMLProvider.planttext.supportsFileType(FileType.txt), isTrue);
      expect(PlantUMLProvider.planttext.supportsFileType(FileType.webp), isFalse);
      expect(PlantUMLProvider.planttext.supportsFileType(FileType.pdf), isFalse);
    });

    test('Mermaid providers support correct file types', () {
      expect(MermaidUmlProvider.mermaidink.supportsFileType(FileType.svg), isTrue);
      expect(MermaidUmlProvider.mermaidink.supportsFileType(FileType.png), isTrue);
      expect(MermaidUmlProvider.mermaidink.supportsFileType(FileType.webp), isTrue);
      expect(MermaidUmlProvider.mermaidink.supportsFileType(FileType.jpeg), isTrue);
      expect(MermaidUmlProvider.mermaidink.supportsFileType(FileType.pdf), isFalse);

      expect(MermaidUmlProvider.kroki.supportsFileType(FileType.svg), isTrue);
      expect(MermaidUmlProvider.kroki.supportsFileType(FileType.png), isTrue);
      expect(MermaidUmlProvider.kroki.supportsFileType(FileType.pdf), isFalse);
      expect(MermaidUmlProvider.kroki.supportsFileType(FileType.webp), isFalse);
    });

    test('Kroki providers support correct file types', () {
      expect(GraphvizProvider.kroki.supportsFileType(FileType.svg), isTrue);
      expect(GraphvizProvider.kroki.supportsFileType(FileType.png), isTrue);
      expect(GraphvizProvider.kroki.supportsFileType(FileType.jpeg), isTrue);
      expect(GraphvizProvider.kroki.supportsFileType(FileType.pdf), isTrue);
      expect(GraphvizProvider.kroki.supportsFileType(FileType.txt), isFalse);

      expect(BpmnProvider.kroki.supportsFileType(FileType.svg), isTrue);
      expect(BpmnProvider.kroki.supportsFileType(FileType.png), isFalse);
    });
  });

  group('Encoding', () {
    test('PlantUML encoding produces valid output', () {
      final encoded = PlantUml.instance.encode('Alice -> Bob');
      expect(encoded, isNotEmpty);

      final decoded = _decodePlantUml(encoded);
      expect(decoded, contains('Alice -> Bob'));
    });

    test('PlantUML encoding with theme includes theme directive', () {
      final encoded = PlantUml.instance.encode(
          '@startuml\nAlice -> Bob\n@enduml',
          const PlantUmlEncodingParameters(theme: PlantUmlTheme.darkula));
      final decoded = _decodePlantUml(encoded);
      expect(decoded, contains('!theme darkula'));
    });

    test('PlantUML encoding preserves diagram title', () {
      final encoded = PlantUml.instance.encode(
          '@startuml my_diagram\nAlice -> Bob\n@enduml',
          const PlantUmlEncodingParameters(theme: PlantUmlTheme.plain));
      final decoded = _decodePlantUml(encoded);
      expect(decoded, contains('@startuml my_diagram\n'));
      expect(decoded, isNot(contains('plain my_diagram')));
    });

    test('Mermaid encoding produces pako format', () {
      final encoded = MermaidUml.instance.encode('graph TD; A-->B;');
      expect(encoded, startsWith('pako:'));
    });

    test('all PlantUML themes produce valid encoding', () {
      for (final theme in PlantUmlTheme.values) {
        final encoded = PlantUml.instance.encode(
            '@startuml\nAlice -> Bob\n@enduml',
            PlantUmlEncodingParameters(theme: theme));
        expect(encoded, isNotEmpty, reason: 'Theme $theme should encode');
      }
    });

    test('all Mermaid themes produce valid encoding', () {
      for (final theme in MermaidUmlTheme.values) {
        final encoded = MermaidUml.instance.encode('graph TD; A --> B',
            MermaidUmlEncodingParameters(theme: theme));
        expect(encoded, startsWith('pako:'),
            reason: 'Theme $theme should encode');
      }
    });

    test('krokiEncode produces valid URL-safe base64', () {
      final encoded = krokiEncode('digraph G { A -> B }');
      expect(encoded, isNotEmpty);
      expect(encoded, isNot(contains('+')));
      expect(encoded, isNot(contains('/')));
      final decompressed =
          const ZLibDecoder().decodeBytes(base64Url.decode(encoded));
      expect(utf8.decode(decompressed), 'digraph G { A -> B }');
    });
  });

  group('Value Objects Equality', () {
    test('Color equality and hashCode', () {
      final c1 = const Color(0xFF112233);
      final c2 = const Color(0xFF112233);
      final c3 = const Color(0xFF445566);
      expect(c1, equals(c2));
      expect(c1.hashCode, equals(c2.hashCode));
      expect(c1, isNot(equals(c3)));
    });

    test('UmlURL equality and hashCode', () {
      final u1 = UmlURL('https://example.com/a.svg', FileType.svg);
      final u2 = UmlURL('https://example.com/a.svg', FileType.svg);
      final u3 = UmlURL('https://example.com/b.svg', FileType.svg);
      final u4 = UmlURL('https://example.com/a.svg', FileType.png);

      expect(u1, equals(u2));
      expect(u1.hashCode, equals(u2.hashCode));
      expect(u1, isNot(equals(u3)));
      expect(u1, isNot(equals(u4)));
    });

    test('SavedFile equality and hashCode', () {
      final s1 = const SavedFile(path: '/path/file.png', bytesWritten: 123);
      final s2 = const SavedFile(path: '/path/file.png', bytesWritten: 123);
      final s3 = const SavedFile(path: '/path/file.png', bytesWritten: 456);
      final s4 = const SavedFile(path: '/other/file.png', bytesWritten: 123);

      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      expect(s1, isNot(equals(s3)));
      expect(s1, isNot(equals(s4)));
    });

    test('Cross-type equality on Config, Parameters, and EncodingParameters returns false without throwing', () {
      final svgbobConfig = const SvgbobConfig();
      final symbolatorConfig = const SymbolatorConfig();
      final wavedromConfig = const WavedromConfig();
      final goatConfig = const GoatConfig();

      // Config cross-equality
      expect(svgbobConfig == symbolatorConfig, isFalse);
      expect(wavedromConfig == goatConfig, isFalse);
      expect(svgbobConfig == 'not a config', isFalse);

      // Parameters cross-equality (previously threw TypeError when covariant)
      final svgbobParams = const SvgbobParameters();
      final symbolatorParams = const SymbolatorParameters();
      final wavedromParams = const WavedromParameters();
      final goatParams = const GoatParameters();

      expect(svgbobParams == symbolatorParams, isFalse);
      expect(symbolatorParams == svgbobParams, isFalse);
      expect(goatParams == wavedromParams, isFalse);
      expect(wavedromParams == goatParams, isFalse);
      expect(svgbobParams == 'not params', isFalse);

      // EncodingParameters cross-equality
      final svgbobEnc = const SvgbobEncodingParameters();
      final symbolatorEnc = const SymbolatorEncodingParameters();
      expect(svgbobEnc == symbolatorEnc, isFalse);
      expect(svgbobEnc == 'not enc', isFalse);
    });
  });

  group('Color Conversion', () {
    test('toHex converts correctly and ignores alpha', () {
      expect(Color(0xFFFF0000).toHex(), equals('#FF0000'));
      expect(Color(0x80FF0000).toHex(), equals('#FF0000'));
      expect(Color(0xFF00000A).toHex(), equals('#00000A'));
    });
  });

  group('Save Utilities', () {
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

  group('Download Validation (Integration)', () {
    group('PlantUML - All Provider × File Type Combinations', () {
      for (final provider in PlantUMLProvider.values) {
        for (final fileType in provider.supportedFileTypes) {
          test('PlantUML ${provider.name} downloads valid ${fileType.name}', () async {
            final plantUmlFileType = PlantUMLFileType.values.firstWhere(
              (ft) => ft.type == fileType,
            );
            final url = PlantUml.instance.getUrl(
              'Alice -> Bob : Hello',
              parameters: PlantUmlParameters(provider: provider, type: plantUmlFileType),
            );
            final bytes = await url.download();
            expect(bytes, isNotEmpty);
            expect(_isValidFileFormat(bytes, fileType), isTrue,
                reason: '${provider.name} should produce valid ${fileType.name}');
          });
        }
      }
    });

    group('Mermaid - mermaidink Provider × File Type Combinations', () {
      for (final fileType in MermaidUmlProvider.mermaidink.supportedFileTypes) {
        test('Mermaid mermaidink downloads valid ${fileType.name}', () async {
          final mermaidFileType = MermaidUmlFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = MermaidUml.instance.getUrl(
            'graph TD; A-->B;',
            parameters: MermaidUmlParameters(
              provider: MermaidUmlProvider.mermaidink,
              type: mermaidFileType,
            ),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'mermaidink should produce valid ${fileType.name}');
        });
      }
    });

    group('Mermaid - kroki Provider × File Type Combinations', () {
      for (final fileType in MermaidUmlProvider.kroki.supportedFileTypes) {
        test('Mermaid kroki downloads valid ${fileType.name}', () async {
          final mermaidFileType = MermaidUmlFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = MermaidUml.instance.getUrl(
            'graph TD; A-->B;',
            parameters: MermaidUmlParameters(
              provider: MermaidUmlProvider.kroki,
              type: mermaidFileType,
            ),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'kroki should produce valid ${fileType.name}');
        });
      }
    });

    group('Kroki Diagrams - Download Validation', () {
      test('Graphviz - all file types', () async {
        for (final fileType in GraphvizProvider.kroki.supportedFileTypes) {
          final graphvizFileType = GraphvizFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Graphviz.instance.getUrl(
            'digraph G { A -> B }',
            parameters: GraphvizParameters(type: graphvizFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Graphviz should produce valid ${fileType.name}');
        }
      });

      test('Erd - all file types', () async {
        for (final fileType in ErdProvider.kroki.supportedFileTypes) {
          final erdFileType = ErdFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Erd.instance.getUrl(
            '[Person]\n*name',
            parameters: ErdParameters(type: erdFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Erd should produce valid ${fileType.name}');
        }
      });

      test('Blockdiag - all file types', () async {
        for (final fileType in BlockdiagProvider.kroki.supportedFileTypes) {
          final blockdiagFileType = BlockdiagFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Blockdiag.instance.getUrl(
            'blockdiag { A -> B; }',
            parameters: BlockdiagParameters(type: blockdiagFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Blockdiag should produce valid ${fileType.name}');
        }
      });

      test('Seqdiag - all file types', () async {
        for (final fileType in SeqdiagProvider.kroki.supportedFileTypes) {
          final seqdiagFileType = SeqdiagFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Seqdiag.instance.getUrl(
            'seqdiag { A -> B; }',
            parameters: SeqdiagParameters(type: seqdiagFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Seqdiag should produce valid ${fileType.name}');
        }
      });

      test('Actdiag - all file types', () async {
        for (final fileType in ActdiagProvider.kroki.supportedFileTypes) {
          final actdiagFileType = ActdiagFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Actdiag.instance.getUrl(
            'actdiag { A -> B; }',
            parameters: ActdiagParameters(type: actdiagFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Actdiag should produce valid ${fileType.name}');
        }
      });

      test('Nwdiag - all file types', () async {
        for (final fileType in NwdiagProvider.kroki.supportedFileTypes) {
          final nwdiagFileType = NwdiagFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Nwdiag.instance.getUrl(
            'nwdiag { A -- B; }',
            parameters: NwdiagParameters(type: nwdiagFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Nwdiag should produce valid ${fileType.name}');
        }
      });

      test('Packetdiag - all file types', () async {
        for (final fileType in PacketdiagProvider.kroki.supportedFileTypes) {
          final packetdiagFileType = PacketdiagFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Packetdiag.instance.getUrl(
            'packetdiag { 0-15: Source Port; }',
            parameters: PacketdiagParameters(type: packetdiagFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Packetdiag should produce valid ${fileType.name}');
        }
      });

      test('Rackdiag - all file types', () async {
        for (final fileType in RackdiagProvider.kroki.supportedFileTypes) {
          final rackdiagFileType = RackdiagFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Rackdiag.instance.getUrl(
            'rackdiag {\n  16U;\n  1: Server;\n}',
            parameters: RackdiagParameters(type: rackdiagFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Rackdiag should produce valid ${fileType.name}');
        }
      });

      test('Bpmn - all file types', () async {
        for (final fileType in BpmnProvider.kroki.supportedFileTypes) {
          final bpmnFileType = BpmnFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Bpmn.instance.getUrl(
            '<?xml version="1.0" encoding="UTF-8"?>\n'
            '<bpmn:definitions xmlns:bpmn="http://www.omg.org/spec/BPMN/20100524/MODEL"\n'
            '                  xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI"\n'
            '                  xmlns:dc="http://www.omg.org/spec/DD/20100524/DC"\n'
            '                  id="Definitions_1"\n'
            '                  targetNamespace="http://bpmn.io/schema/bpmn">\n'
            '  <bpmn:process id="Process_1" isExecutable="false">\n'
            '    <bpmn:startEvent id="StartEvent_1"/>\n'
            '  </bpmn:process>\n'
            '  <bpmndi:BPMNDiagram id="BPMNDiagram_1">\n'
            '    <bpmndi:BPMNPlane id="BPMNPlane_1" bpmnElement="Process_1">\n'
            '      <bpmndi:BPMNShape id="_BPMNShape_StartEvent_2" bpmnElement="StartEvent_1">\n'
            '        <dc:Bounds x="173" y="102" width="36" height="36" />\n'
            '      </bpmndi:BPMNShape>\n'
            '    </bpmndi:BPMNPlane>\n'
            '  </bpmndi:BPMNDiagram>\n'
            '</bpmn:definitions>',
            parameters: BpmnParameters(type: bpmnFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Bpmn should produce valid ${fileType.name}');
        }
      });

      test('Bytefield - all file types', () async {
        for (final fileType in BytefieldProvider.kroki.supportedFileTypes) {
          final bytefieldFileType = BytefieldFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Bytefield.instance.getUrl(
            '(draw-box "Field")',
            parameters: BytefieldParameters(type: bytefieldFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Bytefield should produce valid ${fileType.name}');
        }
      });

      test('Ditaa - all file types', () async {
        for (final fileType in DitaaProvider.kroki.supportedFileTypes) {
          final ditaaFileType = DitaaFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Ditaa.instance.getUrl(
            '+---+\n| A |\n+---+',
            parameters: DitaaParameters(type: ditaaFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Ditaa should produce valid ${fileType.name}');
        }
      });

      test('Nomnoml - all file types', () async {
        for (final fileType in NomnomlProvider.kroki.supportedFileTypes) {
          final nomnomlFileType = NomnomlFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Nomnoml.instance.getUrl(
            '[A] -> [B]',
            parameters: NomnomlParameters(type: nomnomlFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Nomnoml should produce valid ${fileType.name}');
        }
      });

      test('Pikchr - all file types', () async {
        for (final fileType in PikchrProvider.kroki.supportedFileTypes) {
          final pikchrFileType = PikchrFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Pikchr.instance.getUrl(
            'L: circle "A"',
            parameters: PikchrParameters(type: pikchrFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Pikchr should produce valid ${fileType.name}');
        }
      });

      test('Structurizr - all file types', () async {
        for (final fileType in StructurizrProvider.kroki.supportedFileTypes) {
          final structurizrFileType = StructurizrFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Structurizr.instance.getUrl(
            'workspace {\n'
            '    model {\n'
            '        user = person "User"\n'
            '    }\n'
            '    views {\n'
            '        systemLandscape "SystemLandscape" {\n'
            '            include *\n'
            '            autoLayout\n'
            '        }\n'
            '    }\n'
            '}',
            parameters: StructurizrParameters(type: structurizrFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Structurizr should produce valid ${fileType.name}');
        }
      });

      test('Tikz - all file types', () async {
        for (final fileType in TikzProvider.kroki.supportedFileTypes) {
          final tikzFileType = TikzFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Tikz.instance.getUrl(
            '\\documentclass{standalone}\n'
            '\\usepackage{tikz}\n'
            '\\begin{document}\n'
            '\\begin{tikzpicture}\n'
            '  \\draw (0,0) circle (1cm);\n'
            '\\end{tikzpicture}\n'
            '\\end{document}',
            parameters: TikzParameters(type: tikzFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Tikz should produce valid ${fileType.name}');
        }
      });

      test('Umlet - all file types', () async {
        for (final fileType in UmletProvider.kroki.supportedFileTypes) {
          final umletFileType = UmletFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Umlet.instance.getUrl(
            '<panel_attributes>\n'
            'bg=lavender\n'
            'layer=1\n'
            'printCoordinates=true\n'
            '--50--50--100--100--\n'
            'lt=dashed\n'
            '</panel_attributes>',
            parameters: UmletParameters(type: umletFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Umlet should produce valid ${fileType.name}');
        }
      });

      test('Vega - all file types', () async {
        for (final fileType in VegaProvider.kroki.supportedFileTypes) {
          final vegaFileType = VegaFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Vega.instance.getUrl(
            '{\n'
            '  "\$schema": "https://vega.github.io/schema/vega/v5.json",\n'
            '  "width": 100,\n'
            '  "height": 100,\n'
            '  "data": []\n'
            '}',
            parameters: VegaParameters(type: vegaFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Vega should produce valid ${fileType.name}');
        }
      });

      test('VegaLite - all file types', () async {
        for (final fileType in VegaLiteProvider.kroki.supportedFileTypes) {
          final vegaLiteFileType = VegaLiteFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = VegaLite.instance.getUrl(
            '{\n'
            '  "\$schema": "https://vega.github.io/schema/vega-lite/v5.json",\n'
            '  "data": {"values": [{"a": "A", "b": 28}]},\n'
            '  "mark": "bar",\n'
            '  "encoding": {\n'
            '    "x": {"field": "a", "type": "nominal"},\n'
            '    "y": {"field": "b", "type": "quantitative"}\n'
            '  }\n'
            '}',
            parameters: VegaLiteParameters(type: vegaLiteFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'VegaLite should produce valid ${fileType.name}');
        }
      });

      test('Wavedrom - all file types', () async {
        for (final fileType in WavedromProvider.kroki.supportedFileTypes) {
          final wavedromFileType = WavedromFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Wavedrom.instance.getUrl(
            '{"signal": [{"name": "clk", "wave": "p"}]}',
            parameters: WavedromParameters(type: wavedromFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Wavedrom should produce valid ${fileType.name}');
        }
      });

      test('Wireviz - all file types', () async {
        for (final fileType in WirevizProvider.kroki.supportedFileTypes) {
          final wirevizFileType = WirevizFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Wireviz.instance.getUrl(
            'connectors:\n'
            '  X1:\n'
            '    type: D-Sub\n'
            '    pins: [1, 2]\n',
            parameters: WirevizParameters(type: wirevizFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Wireviz should produce valid ${fileType.name}');
        }
      });

      test('C4Plantuml - all file types', () async {
        for (final fileType in C4PlantumlProvider.kroki.supportedFileTypes) {
          final c4PlantumlFileType = C4PlantumlFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = C4Plantuml.instance.getUrl(
            '@startuml\nperson U\n@enduml',
            parameters: C4PlantumlParameters(type: c4PlantumlFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'C4Plantuml should produce valid ${fileType.name}');
        }
      });

      test('D2 - all file types', () async {
        for (final fileType in D2Provider.kroki.supportedFileTypes) {
          final d2FileType = D2FileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = D2.instance.getUrl(
            'x -> y',
            parameters: D2Parameters(type: d2FileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'D2 should produce valid ${fileType.name}');
        }
      });

      test('Dbml - all file types', () async {
        for (final fileType in DbmlProvider.kroki.supportedFileTypes) {
          final dbmlFileType = DbmlFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Dbml.instance.getUrl(
            'Table users { id int }',
            parameters: DbmlParameters(type: dbmlFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Dbml should produce valid ${fileType.name}');
        }
      });

      test('Excalidraw - all file types', () async {
        for (final fileType in ExcalidrawProvider.kroki.supportedFileTypes) {
          final excalidrawFileType = ExcalidrawFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Excalidraw.instance.getUrl(
            '{"type": "excalidraw", "version": 2, "elements": []}',
            parameters: ExcalidrawParameters(type: excalidrawFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Excalidraw should produce valid ${fileType.name}');
              
        }
      });

      test('Goat - all file types', () async {
        for (final fileType in GoatProvider.kroki.supportedFileTypes) {
          final goatFileType = GoatFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Goat.instance.getUrl(
            'A -> B',
            parameters: GoatParameters(type: goatFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Goat should produce valid ${fileType.name}');
        }
      });

      test('Lini - all file types', () async {
        for (final fileType in LiniProvider.kroki.supportedFileTypes) {
          final liniFileType = LiniFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Lini.instance.getUrl(
            'A -> B',
            parameters: LiniParameters(type: liniFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Lini should produce valid ${fileType.name}');
        }
      });

      test('Svgbob - all file types', () async {
        for (final fileType in SvgbobProvider.kroki.supportedFileTypes) {
          final svgbobFileType = SvgbobFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Svgbob.instance.getUrl(
            'A -> B',
            parameters: SvgbobParameters(type: svgbobFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Svgbob should produce valid ${fileType.name}');
        }
      });

      test('Symbolator - all file types', () async {
        for (final fileType in SymbolatorProvider.kroki.supportedFileTypes) {
          final symbolatorFileType = SymbolatorFileType.values.firstWhere(
            (ft) => ft.type == fileType,
          );
          final url = Symbolator.instance.getUrl(
            'package demo is\n'
            '    component demo_device is\n'
            '        port (\n'
            '            Clock : in std_ulogic;\n'
            '            Data_out : out std_ulogic\n'
            '        );\n'
            '    end component;\n'
            'end package;',
            parameters: SymbolatorParameters(type: symbolatorFileType),
          );
          final bytes = await url.download();
          expect(bytes, isNotEmpty);
          expect(_isValidFileFormat(bytes, fileType), isTrue,
              reason: 'Symbolator should produce valid ${fileType.name}');
        }
      });
    });

    group('Download Caching Behavior', () {
      test('UmlURL caches downloaded bytes', () async {
        final url = PlantUml.instance.getUrl('Alice -> Bob');
        
        final bytes1 = await url.download();
        expect(url.cachedBytes, isNotNull);
        
        final bytes2 = await url.download(forceFetch: false);
        expect(bytes2, same(bytes1));
      });

      test('UmlURL forceFetch re-downloads', () async {
        final url = PlantUml.instance.getUrl('Alice -> Bob');
        
        final bytes1 = await url.download();
        final bytes2 = await url.download(forceFetch: true);
        
        expect(bytes2, isNot(same(bytes1)));
        expect(bytes2, equals(bytes1));
      });
    });
  });
}
