import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:uml/src/base.dart';
import 'package:uml/src/plant_uml/types/file_type.dart';
import 'package:uml/src/plant_uml/types/provider.dart';
import 'package:uml/src/plant_uml/types/theme.dart';

export 'types/file_type.dart';
export 'types/provider.dart';
export 'types/theme.dart';

/// Singleton that generates PlantUML diagram URLs.
///
/// Encodes PlantUML code with optional themes, colors, and styling,
/// then builds a URL that renders the diagram on a PlantUML server.
///
/// Example:
/// ```dart
/// final url = PlantUmlUrl.instance.getUrl(
///   '@startuml\nAlice -> Bob\n@enduml',
///   parameters: const PlantUmlParameters(type: PlantUMLFileType.svg),
/// );
/// ```
class PlantUmlUrl {
  static PlantUmlUrl? _instance;
  static PlantUmlUrl get instance => _instance ??= PlantUmlUrl._();

  PlantUmlUrl._();

  static const _plantUml64 =
      "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_";

  /// Encodes PlantUML code with optional theme and styling.
  ///
  /// Returns a PlantUML-compatible encoded string suitable for use in URLs.
  String encode(
    String text, {
    PlantUmlEncodingParameters parameters = const PlantUmlEncodingParameters(),
  }) {
    final themedCode = _applyCustomTheme(
      text,
      theme: parameters.theme,
      backgroundColor: parameters.backgroundColor,
      fontColor: parameters.fontColor,
      textAlign: parameters.textAlign,
      activityRoundCorner: parameters.activityRoundCorner,
      noteFontColor: parameters.noteFontColor,
      noteBackgroundColor: parameters.noteBackgroundColor,
      noteBorderColor: parameters.noteBorderColor,
      activityBackgroundColor: parameters.activityBackgroundColor,
      activityFontColor: parameters.activityFontColor,
      activityBorderColor: parameters.activityBorderColor,
      rectangleBackgroundColor: parameters.rectangleBackgroundColor,
      rectangleFontColor: parameters.rectangleFontColor,
      rectangleBorderColor: parameters.rectangleBorderColor,
      partitionBackgroundColor: parameters.partitionBackgroundColor,
      partitionFontColor: parameters.partitionFontColor,
      partitionBorderColor: parameters.partitionBorderColor,
      activityStartColor: parameters.activityStartColor,
      activityEndBackgroundColor: parameters.activityEndBackgroundColor,
      activityEndBorderColor: parameters.activityEndBorderColor,
      activityEndColor: parameters.activityEndColor,
      activityDiamondBackgroundColor: parameters.activityDiamondBackgroundColor,
      fontSize: parameters.fontSize,
      componentBackgroundColor: parameters.componentBackgroundColor,
      componentFontColor: parameters.componentFontColor,
      componentBorderColor: parameters.componentBorderColor,
      interfaceBackgroundColor: parameters.interfaceBackgroundColor,
      interfaceFontColor: parameters.interfaceFontColor,
      interfaceBorderColor: parameters.interfaceBorderColor,
      packageBackgroundColor: parameters.packageBackgroundColor,
      packageFontColor: parameters.packageFontColor,
      packageBorderColor: parameters.packageBorderColor,
      sequenceBackgroundColor: parameters.sequenceBackgroundColor,
      sequenceFontColor: parameters.sequenceFontColor,
      sequenceBorderColor: parameters.sequenceBorderColor,
      classBackgroundColor: parameters.classBackgroundColor,
      classFontColor: parameters.classFontColor,
      classBorderColor: parameters.classBorderColor,
      arrowColor: parameters.arrowColor,
    );
    return _encodePlantUml(themedCode);
  }

  /// Builds a complete [UmlURL] from PlantUML code.
  ///
  /// Applies [parameters] for file type, provider, theme, and styling.
  UmlURL getUrl(
    String code, {
    PlantUmlParameters parameters = const PlantUmlParameters(),
  }) {
    final type = parameters.type ?? PlantUMLFileType.svg;
    final encodedCode = encode(code, parameters: parameters.encodingParameters);
    return UmlURL(
      '${parameters.provider.baseUrl}/${type.name}/$encodedCode',
      type.type,
    );
  }

  String _encodePlantUml(String text) {
    final bytes = utf8.encode(text);
    final compressed = Deflate(bytes).getBytes();
    return _encode64(compressed);
  }

  String _encode64(List<int> data) {
    String encodeChunk(int c1, int c2, int c3) {
      final b1 = c1 >> 2;
      final b2 = ((c1 & 0x3) << 4) | (c2 >> 4);
      final b3 = ((c2 & 0xF) << 2) | (c3 >> 6);
      final b4 = c3 & 0x3F;
      final sb = StringBuffer();
      sb.write(_plantUml64[b1]);
      sb.write(_plantUml64[b2]);
      sb.write(_plantUml64[b3]);
      sb.write(_plantUml64[b4]);
      return sb.toString();
    }

    final sb = StringBuffer();
    for (var i = 0; i < data.length; i += 3) {
      final c1 = data[i];
      final c2 = i + 1 < data.length ? data[i + 1] : 0;
      final c3 = i + 2 < data.length ? data[i + 2] : 0;
      sb.write(encodeChunk(c1, c2, c3));
    }
    return sb.toString();
  }

  static String _applyCustomTheme(
    String code, {
    PlantUMLTheme? theme,
    Color? backgroundColor,
    Color? fontColor,
    Color? noteFontColor,
    Color? noteBackgroundColor,
    Color? noteBorderColor,
    Color? activityBackgroundColor,
    Color? activityFontColor,
    Color? activityBorderColor,
    Color? rectangleBackgroundColor,
    Color? rectangleFontColor,
    Color? rectangleBorderColor,
    Color? partitionBackgroundColor,
    Color? partitionFontColor,
    Color? partitionBorderColor,
    Color? activityStartColor,
    Color? activityEndColor,
    Color? activityEndBackgroundColor,
    Color? activityEndBorderColor,
    Color? arrowColor,
    double? activityRoundCorner,
    double? fontSize,
    Color? activityDiamondBackgroundColor,
    Color? componentBackgroundColor,
    Color? componentFontColor,
    Color? componentBorderColor,
    Color? interfaceBackgroundColor,
    Color? interfaceFontColor,
    Color? interfaceBorderColor,
    Color? packageBackgroundColor,
    Color? packageFontColor,
    Color? packageBorderColor,
    Color? sequenceBackgroundColor,
    Color? sequenceFontColor,
    Color? sequenceBorderColor,
    Color? classBackgroundColor,
    Color? classFontColor,
    Color? classBorderColor,
    TextAlign textAlign = TextAlign.center,
  }) {
    String insertAfterStartuml(String code, String snippet) {
      final startumlRegex = RegExp(r'^@startuml', multiLine: true);
      final match = startumlRegex.firstMatch(code);
      if (match != null) {
        final insertIndex = match.end; // right after @startuml
        return '${code.substring(0, insertIndex)}\n$snippet${code.substring(insertIndex)}';
      }
      // No @startuml found: wrap diagram
      return '@startuml\n$snippet\n$code\n@enduml';
    }

    // --- Helper: merge block params ---
    String mergeBlock(
      String blockName,
      Map<String, String> newParams,
      String code,
    ) {
      final blockRegex = RegExp(
        r'^skinparam\s+' +
            RegExp.escape(blockName) +
            r'\s*\{\s*([\s\S]*?)\s*\}',
        multiLine: true,
      );
      final match = blockRegex.firstMatch(code);
      if (match != null) {
        final existingBlock = match.group(1)!;
        final existingKeys = <String>{};
        final updatedBlock = StringBuffer(existingBlock.trimRight());

        for (final line in existingBlock.split('\n')) {
          final kv = line.trim().split(RegExp(r'\s+'));
          if (kv.isNotEmpty) {
            existingKeys.add(kv.first);
          }
        }

        newParams.forEach((key, value) {
          if (!existingKeys.contains(key)) {
            updatedBlock.writeln('  $key $value');
          }
        });

        return code.replaceFirst(
          match.group(0)!,
          'skinparam $blockName {\n${updatedBlock.toString().trimRight()}\n}',
        );
      } else {
        return insertAfterStartuml(
          code,
          'skinparam $blockName {\n${newParams.entries.map((e) => '  ${e.key} ${e.value}').join('\n')}\n}',
        );
      }
    }

    // --- Helper: merge single-line params ---
    String mergeSingle(String key, String value, String code) {
      // Use multiLine: true instead of (?m)
      final regex = RegExp(
        r'^\s*' + RegExp.escape(key) + r'\s+',
        multiLine: true,
      );
      if (regex.hasMatch(code)) {
        // Already exists → don't override
        return code;
      }
      return insertAfterStartuml(code, '$key $value');
    }

    // --- Build all blocks ---
    final Map<String, Map<String, String>> blocks = {};

    void addBlock(
      String name, {
      Color? bg,
      Color? font,
      Color? border,
      double? round,
    }) {
      final params = <String, String>{};
      if (bg != null) params['BackgroundColor'] = bg.toHex();
      if (font != null) params['FontColor'] = font.toHex();
      if (border != null) params['BorderColor'] = border.toHex();
      if (round != null) params['RoundCorner'] = round.toStringAsFixed(2);
      if (params.isNotEmpty) {
        blocks[name] = params;
      }
    }

    addBlock(
      'rectangle',
      bg: rectangleBackgroundColor,
      font: rectangleFontColor,
      border: rectangleBorderColor,
    );
    addBlock(
      'note',
      bg: noteBackgroundColor,
      font: noteFontColor,
      border: noteBorderColor,
    );
    addBlock(
      'activity',
      bg: activityBackgroundColor,
      font: activityFontColor,
      border: activityBorderColor,
      round: activityRoundCorner,
    );
    addBlock(
      'partition',
      bg: partitionBackgroundColor,
      font: partitionFontColor,
      border: partitionBorderColor,
    );
    addBlock(
      'component',
      bg: componentBackgroundColor,
      font: componentFontColor,
      border: componentBorderColor,
    );
    addBlock(
      'interface',
      bg: interfaceBackgroundColor,
      font: interfaceFontColor,
      border: interfaceBorderColor,
    );
    addBlock(
      'package',
      bg: packageBackgroundColor,
      font: packageFontColor,
      border: packageBorderColor,
    );
    addBlock(
      'sequence',
      bg: sequenceBackgroundColor,
      font: sequenceFontColor,
      border: sequenceBorderColor,
    );
    addBlock(
      'class',
      bg: classBackgroundColor,
      font: classFontColor,
      border: classBorderColor,
    );

    // --- Merge into code ---
    String newCode = code;

    // Single-line params
    if (fontSize != null) {
      newCode = mergeSingle(
        'skinparam defaultFontSize',
        fontSize.toInt().toString(),
        newCode,
      );
    }
    if (backgroundColor != null) {
      newCode = mergeSingle(
        'skinparam backgroundColor',
        backgroundColor.toHex(),
        newCode,
      );
    }
    if (fontColor != null) {
      newCode = mergeSingle(
        'skinparam defaultFontColor',
        fontColor.toHex(),
        newCode,
      );
    }
    if (activityStartColor != null) {
      newCode = mergeSingle(
        'skinparam activityStartColor',
        activityStartColor.toHex(),
        newCode,
      );
    }
    if (activityEndColor != null) {
      newCode = mergeSingle(
        'skinparam activityEndColor',
        activityEndColor.toHex(),
        newCode,
      );
    }
    if (activityDiamondBackgroundColor != null) {
      newCode = mergeSingle(
        'skinparam activityDiamondBackgroundColor',
        activityDiamondBackgroundColor.toHex(),
        newCode,
      );
    }
    if (arrowColor != null) {
      newCode = mergeSingle(
        'skinparam ArrowColor',
        arrowColor.toHex(),
        newCode,
      );
    }
    if (activityEndBackgroundColor != null) {
      newCode = mergeSingle(
        'skinparam activityEndBackgroundColor',
        activityEndBackgroundColor.toHex(),
        newCode,
      );
    }
    if (activityEndBorderColor != null) {
      newCode = mergeSingle(
        'skinparam activityEndBorderColor',
        activityEndBorderColor.toHex(),
        newCode,
      );
    }

    newCode = mergeSingle(
      'skinparam defaultTextAlignment',
      textAlign.name,
      newCode,
    );

    // Merge all block params
    blocks.forEach((blockName, params) {
      newCode = mergeBlock(blockName, params, newCode);
    });

    // Theme
    if (theme != null) {
      if (!newCode.contains('!theme')) {
        String themeSnippet = '';
        if (theme.externalDependency != null) {
          themeSnippet = '!include ${theme.externalDependency}\n';
        }
        themeSnippet += '!theme ${theme.name}';
        newCode = insertAfterStartuml(newCode, themeSnippet);
      }
    }

    // Ensure @startuml wrapping
    if (!newCode.trimLeft().startsWith('@startuml')) {
      newCode = '@startuml\n$newCode\n@enduml';
    }

    return newCode;
  }
}

/// Encoding parameters for PlantUML diagrams.
///
/// Controls themes, colors, fonts, and block-specific styling.
/// Use [copyWith] to create modified copies.
class PlantUmlEncodingParameters extends UmlEncodingParameters {
  const PlantUmlEncodingParameters({
    this.theme,
    this.backgroundColor,
    this.fontColor,
    this.textAlign = TextAlign.center,
    this.activityRoundCorner,
    this.fontSize,
    this.noteFontColor,
    this.noteBackgroundColor,
    this.noteBorderColor,
    this.activityBackgroundColor,
    this.activityFontColor,
    this.activityBorderColor,
    this.rectangleBackgroundColor,
    this.rectangleFontColor,
    this.rectangleBorderColor,
    this.partitionBackgroundColor,
    this.partitionFontColor,
    this.partitionBorderColor,
    this.activityStartColor,
    this.activityEndColor,
    this.activityEndBackgroundColor,
    this.activityEndBorderColor,
    this.activityDiamondBackgroundColor,
    this.arrowColor,
    this.componentBackgroundColor,
    this.componentFontColor,
    this.componentBorderColor,
    this.interfaceBackgroundColor,
    this.interfaceFontColor,
    this.interfaceBorderColor,
    this.packageBackgroundColor,
    this.packageFontColor,
    this.packageBorderColor,
    this.sequenceBackgroundColor,
    this.sequenceFontColor,
    this.sequenceBorderColor,
    this.classBackgroundColor,
    this.classFontColor,
    this.classBorderColor,
  });

  final PlantUMLTheme? theme;
  final Color? backgroundColor;
  final Color? fontColor;
  final TextAlign textAlign;
  final double? activityRoundCorner;
  final double? fontSize;
  final Color? noteFontColor;
  final Color? noteBackgroundColor;
  final Color? noteBorderColor;
  final Color? activityBackgroundColor;
  final Color? activityFontColor;
  final Color? activityBorderColor;
  final Color? rectangleBackgroundColor;
  final Color? rectangleFontColor;
  final Color? rectangleBorderColor;
  final Color? partitionBackgroundColor;
  final Color? partitionFontColor;
  final Color? partitionBorderColor;
  final Color? activityStartColor;
  final Color? activityEndColor;
  final Color? activityEndBackgroundColor;
  final Color? activityEndBorderColor;
  final Color? activityDiamondBackgroundColor;
  final Color? arrowColor;
  final Color? componentBackgroundColor;
  final Color? componentFontColor;
  final Color? componentBorderColor;
  final Color? interfaceBackgroundColor;
  final Color? interfaceFontColor;
  final Color? interfaceBorderColor;
  final Color? packageBackgroundColor;
  final Color? packageFontColor;
  final Color? packageBorderColor;
  final Color? sequenceBackgroundColor;
  final Color? sequenceFontColor;
  final Color? sequenceBorderColor;
  final Color? classBackgroundColor;
  final Color? classFontColor;
  final Color? classBorderColor;

  /// Returns a copy of this [PlantUmlEncodingParameters] with the given fields replaced.
  PlantUmlEncodingParameters copyWith({
    PlantUMLTheme? theme,
    Color? backgroundColor,
    Color? fontColor,
    TextAlign? textAlign,
    double? activityRoundCorner,
    double? fontSize,
    Color? noteFontColor,
    Color? noteBackgroundColor,
    Color? noteBorderColor,
    Color? activityBackgroundColor,
    Color? activityFontColor,
    Color? activityBorderColor,
    Color? rectangleBackgroundColor,
    Color? rectangleFontColor,
    Color? rectangleBorderColor,
    Color? partitionBackgroundColor,
    Color? partitionFontColor,
    Color? partitionBorderColor,
    Color? activityStartColor,
    Color? activityEndColor,
    Color? activityEndBackgroundColor,
    Color? activityEndBorderColor,
    Color? activityDiamondBackgroundColor,
    Color? arrowColor,
    Color? componentBackgroundColor,
    Color? componentFontColor,
    Color? componentBorderColor,
    Color? interfaceBackgroundColor,
    Color? interfaceFontColor,
    Color? interfaceBorderColor,
    Color? packageBackgroundColor,
    Color? packageFontColor,
    Color? packageBorderColor,
    Color? sequenceBackgroundColor,
    Color? sequenceFontColor,
    Color? sequenceBorderColor,
    Color? classBackgroundColor,
    Color? classFontColor,
    Color? classBorderColor,
  }) {
    return PlantUmlEncodingParameters(
      theme: theme ?? this.theme,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      fontColor: fontColor ?? this.fontColor,
      textAlign: textAlign ?? this.textAlign,
      activityRoundCorner: activityRoundCorner ?? this.activityRoundCorner,
      fontSize: fontSize ?? this.fontSize,
      noteFontColor: noteFontColor ?? this.noteFontColor,
      noteBackgroundColor: noteBackgroundColor ?? this.noteBackgroundColor,
      noteBorderColor: noteBorderColor ?? this.noteBorderColor,
      activityBackgroundColor:
          activityBackgroundColor ?? this.activityBackgroundColor,
      activityFontColor: activityFontColor ?? this.activityFontColor,
      activityBorderColor: activityBorderColor ?? this.activityBorderColor,
      rectangleBackgroundColor:
          rectangleBackgroundColor ?? this.rectangleBackgroundColor,
      rectangleFontColor: rectangleFontColor ?? this.rectangleFontColor,
      rectangleBorderColor: rectangleBorderColor ?? this.rectangleBorderColor,
      partitionBackgroundColor:
          partitionBackgroundColor ?? this.partitionBackgroundColor,
      partitionFontColor: partitionFontColor ?? this.partitionFontColor,
      partitionBorderColor: partitionBorderColor ?? this.partitionBorderColor,
      activityStartColor: activityStartColor ?? this.activityStartColor,
      activityEndColor: activityEndColor ?? this.activityEndColor,
      activityEndBackgroundColor:
          activityEndBackgroundColor ?? this.activityEndBackgroundColor,
      activityEndBorderColor:
          activityEndBorderColor ?? this.activityEndBorderColor,
      activityDiamondBackgroundColor:
          activityDiamondBackgroundColor ?? this.activityDiamondBackgroundColor,
      arrowColor: arrowColor ?? this.arrowColor,
      componentBackgroundColor:
          componentBackgroundColor ?? this.componentBackgroundColor,
      componentFontColor: componentFontColor ?? this.componentFontColor,
      componentBorderColor: componentBorderColor ?? this.componentBorderColor,
      interfaceBackgroundColor:
          interfaceBackgroundColor ?? this.interfaceBackgroundColor,
      interfaceFontColor: interfaceFontColor ?? this.interfaceFontColor,
      interfaceBorderColor: interfaceBorderColor ?? this.interfaceBorderColor,
      packageBackgroundColor:
          packageBackgroundColor ?? this.packageBackgroundColor,
      packageFontColor: packageFontColor ?? this.packageFontColor,
      packageBorderColor: packageBorderColor ?? this.packageBorderColor,
      sequenceBackgroundColor:
          sequenceBackgroundColor ?? this.sequenceBackgroundColor,
      sequenceFontColor: sequenceFontColor ?? this.sequenceFontColor,
      sequenceBorderColor: sequenceBorderColor ?? this.sequenceBorderColor,
      classBackgroundColor: classBackgroundColor ?? this.classBackgroundColor,
      classFontColor: classFontColor ?? this.classFontColor,
      classBorderColor: classBorderColor ?? this.classBorderColor,
    );
  }
}

/// Parameters for generating PlantUML diagram URLs.
///
/// Wraps [encodingParameters] with a [provider] and optional [type].
class PlantUmlParameters extends UmlParameters<PlantUmlEncodingParameters> {
  @override
  final PlantUmlEncodingParameters encodingParameters;

  /// The PlantUML server provider.
  final PlantUMLProvider provider;

  /// The output file type (SVG or PNG). Defaults to SVG.
  final PlantUMLFileType? type;

  const PlantUmlParameters({
    this.encodingParameters = const PlantUmlEncodingParameters(),
    this.provider = PlantUMLProvider.planttext,
    this.type,
  });

  /// Returns a copy of this [PlantUmlParameters] with the given fields replaced.
  PlantUmlParameters copyWith({
    PlantUmlEncodingParameters? encodingParameters,
    PlantUMLProvider? provider,
    PlantUMLFileType? type,
  }) {
    return PlantUmlParameters(
      encodingParameters: encodingParameters ?? this.encodingParameters,
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}
