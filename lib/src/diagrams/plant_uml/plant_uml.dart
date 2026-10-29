import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:uml/src/base.dart';
import 'package:uml/src/diagrams/plant_uml/types/file_type.dart';
import 'package:uml/src/diagrams/plant_uml/types/provider.dart';
import 'package:uml/src/diagrams/plant_uml/types/theme.dart';

export 'types/file_type.dart';
export 'types/provider.dart';
export 'types/theme.dart';

/// Singleton that generates PlantUML diagram URLs.
///
/// Encodes PlantUML code with optional themes, colors, and styling,
/// then builds a URL that renders the diagram on a PlantUML server.
///
/// This class uses PlantUML's specific encoding: deflate compression
/// followed by a custom base64 encoding.
///
/// Example:
/// ```dart
/// final url = PlantUml.instance.getUrl(
///   '@startuml\nAlice -> Bob\n@enduml',
///   parameters: const PlantUmlParameters(type: PlantUMLFileType.svg),
/// );
/// ```
class PlantUml extends Uml<PlantUmlEncodingParameters, PlantUmlParameters> {
  PlantUml._();
  static PlantUml? _instance;

  /// Returns the singleton instance of [PlantUml].
  static PlantUml get instance => _instance ??= PlantUml._();

  /// Encodes PlantUML code with optional theme and styling.
  ///
  /// Applies the specified theme and styling parameters to the code,
  /// then compresses it using deflate and encodes it using PlantUML's
  /// custom base64 encoding.
  ///
  /// Returns a PlantUML-compatible encoded string suitable for use in URLs.
  @override
  String encode(
    String text, [
    PlantUmlEncodingParameters parameters = const PlantUmlEncodingParameters(),
  ]) {
    final styleParameters = parameters.styleParameters;
    final themedCode = _applyCustomTheme(
      text,
      theme: parameters.theme,
      backgroundColor: styleParameters.backgroundColor,
      fontColor: styleParameters.fontColor,
      textAlign: styleParameters.textAlign,
      activityRoundCorner: styleParameters.activityRoundCorner,
      noteFontColor: styleParameters.noteFontColor,
      noteBackgroundColor: styleParameters.noteBackgroundColor,
      noteBorderColor: styleParameters.noteBorderColor,
      activityBackgroundColor: styleParameters.activityBackgroundColor,
      activityFontColor: styleParameters.activityFontColor,
      activityBorderColor: styleParameters.activityBorderColor,
      rectangleBackgroundColor: styleParameters.rectangleBackgroundColor,
      rectangleFontColor: styleParameters.rectangleFontColor,
      rectangleBorderColor: styleParameters.rectangleBorderColor,
      partitionBackgroundColor: styleParameters.partitionBackgroundColor,
      partitionFontColor: styleParameters.partitionFontColor,
      partitionBorderColor: styleParameters.partitionBorderColor,
      activityStartColor: styleParameters.activityStartColor,
      activityEndBackgroundColor: styleParameters.activityEndBackgroundColor,
      activityEndBorderColor: styleParameters.activityEndBorderColor,
      activityEndColor: styleParameters.activityEndColor,
      activityDiamondBackgroundColor:
          styleParameters.activityDiamondBackgroundColor,
      fontSize: styleParameters.fontSize,
      componentBackgroundColor: styleParameters.componentBackgroundColor,
      componentFontColor: styleParameters.componentFontColor,
      componentBorderColor: styleParameters.componentBorderColor,
      interfaceBackgroundColor: styleParameters.interfaceBackgroundColor,
      interfaceFontColor: styleParameters.interfaceFontColor,
      interfaceBorderColor: styleParameters.interfaceBorderColor,
      packageBackgroundColor: styleParameters.packageBackgroundColor,
      packageFontColor: styleParameters.packageFontColor,
      packageBorderColor: styleParameters.packageBorderColor,
      sequenceBackgroundColor: styleParameters.sequenceBackgroundColor,
      sequenceFontColor: styleParameters.sequenceFontColor,
      sequenceBorderColor: styleParameters.sequenceBorderColor,
      classBackgroundColor: styleParameters.classBackgroundColor,
      classFontColor: styleParameters.classFontColor,
      classBorderColor: styleParameters.classBorderColor,
      arrowColor: styleParameters.arrowColor,
    );
    return _encodePlantUml(themedCode);
  }

  /// Builds a complete [UmlURL] from PlantUML code.
  ///
  /// Applies [parameters] for file type, provider, theme, and styling.
  ///
  /// Throws [ArgumentError] if the requested file type is not supported by the provider.
  @override
  UmlURL getUrl(
    String code, {
    PlantUmlParameters parameters = const PlantUmlParameters(),
    PlantUmlEncodingParameters encodingParameters =
        const PlantUmlEncodingParameters(),
  }) {
    final type = parameters.type;
    final provider = parameters.provider;

    // Validate that the provider supports the requested file type
    if (!provider.supportsFileType(type.type)) {
      throw ArgumentError(
        'FileType ${type.type} is not supported by provider ${provider.name}. '
        'Supported types: ${provider.supportedFileTypes.map((t) => t.name).join(", ")}',
      );
    }

    final encodedCode = encode(code, encodingParameters);
    final base = provider.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final path = provider.getPathForFileType(type);
    return UmlURL('$base/$path/$encodedCode', type.type);
  }

  String _encodePlantUml(String text) {
    final bytes = utf8.encode(text);
    final compressed = Deflate(bytes).getBytes();
    return plantUmlBase64Encode(compressed);
  }

  static String _applyCustomTheme(
    String code, {
    PlantUmlTheme? theme,
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
    var result = code;

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
      if (round != null) {
        params['RoundCorner'] = round == round.roundToDouble()
            ? round.toInt().toString()
            : round.toString();
      }
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

    // --- Collect single-line params ---
    final singleParams = <String, String>{};
    if (fontSize != null) {
      singleParams['skinparam defaultFontSize'] = fontSize.toInt().toString();
    }
    if (backgroundColor != null) {
      singleParams['skinparam backgroundColor'] = backgroundColor.toHex();
    }
    if (fontColor != null) {
      singleParams['skinparam defaultFontColor'] = fontColor.toHex();
    }
    if (activityStartColor != null) {
      singleParams['skinparam activityStartColor'] = activityStartColor.toHex();
    }
    if (activityEndColor != null) {
      singleParams['skinparam activityEndColor'] = activityEndColor.toHex();
    }
    if (activityDiamondBackgroundColor != null) {
      singleParams['skinparam activityDiamondBackgroundColor'] =
          activityDiamondBackgroundColor.toHex();
    }
    if (arrowColor != null) {
      singleParams['skinparam ArrowColor'] = arrowColor.toHex();
    }
    if (activityEndBackgroundColor != null) {
      singleParams['skinparam activityEndBackgroundColor'] =
          activityEndBackgroundColor.toHex();
    }
    if (activityEndBorderColor != null) {
      singleParams['skinparam activityEndBorderColor'] =
          activityEndBorderColor.toHex();
    }
    singleParams['skinparam defaultTextAlignment'] = textAlign.name;

    final directivesToInsert = <String>[];

    // 1. Theme directives
    if (theme != null) {
      final hasTheme = RegExp(
        r'^[ \t]*!theme\b',
        multiLine: true,
      ).hasMatch(result);
      if (!hasTheme) {
        if (theme.externalDependency != null) {
          directivesToInsert.add('!include ${theme.externalDependency}');
        }
        directivesToInsert.add('!theme ${theme.themeName}');
      }
    }

    // 2. Single-line skinparams
    singleParams.forEach((key, val) {
      final regex = RegExp(
        r'^[ \t]*' + RegExp.escape(key) + r'\b',
        multiLine: true,
      );
      if (!regex.hasMatch(result)) {
        directivesToInsert.add('$key $val');
      }
    });

    // 3. Block skinparams
    blocks.forEach((blockName, params) {
      final blockRegex = RegExp(
        r'^[ \t]*skinparam\s+' +
            RegExp.escape(blockName) +
            r'\s*\{\s*([\s\S]*?)\s*\}',
        multiLine: true,
      );
      final match = blockRegex.firstMatch(result);
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
        params.forEach((key, value) {
          if (!existingKeys.contains(key)) {
            updatedBlock.writeln();
            updatedBlock.write('  $key $value');
          }
        });
        result = result.replaceFirst(
          match.group(0)!,
          'skinparam $blockName {\n${updatedBlock.toString().trimRight()}\n}',
        );
      } else {
        final blockStr = StringBuffer('skinparam $blockName {');
        params.forEach((k, v) => blockStr.write('\n  $k $v'));
        blockStr.write('\n}');
        directivesToInsert.add(blockStr.toString());
      }
    });

    final startumlRegex = RegExp(
      r'^[ \t]*@startuml[^\r\n]*\r?\n?',
      multiLine: true,
    );
    final startumlMatch = startumlRegex.firstMatch(result);

    if (startumlMatch != null) {
      if (directivesToInsert.isNotEmpty) {
        final insertIndex = startumlMatch.end;
        final prefix = result.substring(0, insertIndex);
        final suffix = result.substring(insertIndex);
        final separator = prefix.endsWith('\n') ? '' : '\n';
        result = '$prefix$separator${directivesToInsert.join('\n')}\n$suffix';
      }
    } else {
      if (directivesToInsert.isNotEmpty) {
        result = '@startuml\n${directivesToInsert.join('\n')}\n$result';
      } else {
        result = '@startuml\n$result';
      }
    }

    if (!RegExp(r'^[ \t]*@enduml\b', multiLine: true).hasMatch(result)) {
      if (!result.endsWith('\n')) {
        result = '$result\n';
      }
      result = '$result@enduml';
    }

    return result;
  }
}

/// Encoding parameters for PlantUML diagrams.
///
/// Controls themes, colors, fonts, and block-specific styling.
/// Use [copyWith] to create modified copies.
class PlantUmlEncodingParameters extends UmlEncodingParameters<PlantUmlTheme> {
  /// Creates encoding parameters with optional theme and styling options.
  const PlantUmlEncodingParameters({
    this.theme = PlantUmlTheme.plain,
    this.styleParameters = const PlantUmlEncodingStyleParameters(),
  });

  /// The PlantUML theme to apply (e.g., Darkula, Spacelab).
  @override
  final PlantUmlTheme theme;

  final PlantUmlEncodingStyleParameters styleParameters;

  /// Returns a copy of this [PlantUmlEncodingParameters] with the given fields replaced.
  @override
  PlantUmlEncodingParameters copyWith({
    PlantUmlTheme? theme,
    PlantUmlEncodingStyleParameters? styleParameters,
  }) {
    return PlantUmlEncodingParameters(
      theme: theme ?? this.theme,
      styleParameters: styleParameters ?? this.styleParameters,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantUmlEncodingParameters &&
          theme == other.theme &&
          styleParameters == other.styleParameters;

  @override
  int get hashCode => Object.hashAll([theme, styleParameters]);
}

class PlantUmlEncodingStyleParameters {
  const PlantUmlEncodingStyleParameters({
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

  /// The overall background color of the diagram.
  final Color? backgroundColor;

  /// The default font color for all text elements.
  final Color? fontColor;

  /// The text alignment for diagram elements.
  final TextAlign textAlign;

  /// The corner radius in pixels for activity nodes.
  final double? activityRoundCorner;

  /// The font size for all text elements.
  final double? fontSize;

  /// The font color for note elements.
  final Color? noteFontColor;

  /// The background color for note elements.
  final Color? noteBackgroundColor;

  /// The border color for note elements.
  final Color? noteBorderColor;

  /// The background color for activity nodes.
  final Color? activityBackgroundColor;

  /// The font color for activity nodes.
  final Color? activityFontColor;

  /// The border color for activity nodes.
  final Color? activityBorderColor;

  /// The background color for rectangle elements.
  final Color? rectangleBackgroundColor;

  /// The font color for rectangle elements.
  final Color? rectangleFontColor;

  /// The border color for rectangle elements.
  final Color? rectangleBorderColor;

  /// The background color for partition elements.
  final Color? partitionBackgroundColor;

  /// The font color for partition elements.
  final Color? partitionFontColor;

  /// The border color for partition elements.
  final Color? partitionBorderColor;

  /// The color of the start node in activity diagrams.
  final Color? activityStartColor;

  /// The color of the end node in activity diagrams.
  final Color? activityEndColor;

  /// The background color of the end node in activity diagrams.
  final Color? activityEndBackgroundColor;

  /// The border color of the end node in activity diagrams.
  final Color? activityEndBorderColor;

  /// The background color of decision diamond nodes in activity diagrams.
  final Color? activityDiamondBackgroundColor;

  /// The color of arrows and connectors between elements.
  final Color? arrowColor;

  /// The background color for component elements.
  final Color? componentBackgroundColor;

  /// The font color for component elements.
  final Color? componentFontColor;

  /// The border color for component elements.
  final Color? componentBorderColor;

  /// The background color for interface elements.
  final Color? interfaceBackgroundColor;

  /// The font color for interface elements.
  final Color? interfaceFontColor;

  /// The border color for interface elements.
  final Color? interfaceBorderColor;

  /// The background color for package elements.
  final Color? packageBackgroundColor;

  /// The font color for package elements.
  final Color? packageFontColor;

  /// The border color for package elements.
  final Color? packageBorderColor;

  /// The background color for sequence diagram lifelines.
  final Color? sequenceBackgroundColor;

  /// The font color for sequence diagram elements.
  final Color? sequenceFontColor;

  /// The border color for sequence diagram elements.
  final Color? sequenceBorderColor;

  /// The background color for class elements.
  final Color? classBackgroundColor;

  /// The font color for class elements.
  final Color? classFontColor;

  /// The border color for class elements.
  final Color? classBorderColor;

  PlantUmlEncodingStyleParameters copyWith({
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
    return PlantUmlEncodingStyleParameters(
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantUmlEncodingStyleParameters &&
          (backgroundColor == other.backgroundColor &&
          fontColor == other.fontColor &&
          textAlign == other.textAlign &&
          activityRoundCorner == other.activityRoundCorner &&
          fontSize == other.fontSize &&
          noteFontColor == other.noteFontColor &&
          noteBackgroundColor == other.noteBackgroundColor &&
          noteBorderColor == other.noteBorderColor &&
          activityBackgroundColor == other.activityBackgroundColor &&
          activityFontColor == other.activityFontColor &&
          activityBorderColor == other.activityBorderColor &&
          rectangleBackgroundColor == other.rectangleBackgroundColor &&
          rectangleFontColor == other.rectangleFontColor &&
          rectangleBorderColor == other.rectangleBorderColor &&
          partitionBackgroundColor == other.partitionBackgroundColor &&
          partitionFontColor == other.partitionFontColor &&
          partitionBorderColor == other.partitionBorderColor &&
          activityStartColor == other.activityStartColor &&
          activityEndColor == other.activityEndColor &&
          activityEndBackgroundColor == other.activityEndBackgroundColor &&
          activityEndBorderColor == other.activityEndBorderColor &&
          activityDiamondBackgroundColor ==
              other.activityDiamondBackgroundColor &&
          arrowColor == other.arrowColor &&
          componentBackgroundColor == other.componentBackgroundColor &&
          componentFontColor == other.componentFontColor &&
          componentBorderColor == other.componentBorderColor &&
          interfaceBackgroundColor == other.interfaceBackgroundColor &&
          interfaceFontColor == other.interfaceFontColor &&
          interfaceBorderColor == other.interfaceBorderColor &&
          packageBackgroundColor == other.packageBackgroundColor &&
          packageFontColor == other.packageFontColor &&
          packageBorderColor == other.packageBorderColor &&
          sequenceBackgroundColor == other.sequenceBackgroundColor &&
          sequenceFontColor == other.sequenceFontColor &&
          sequenceBorderColor == other.sequenceBorderColor &&
          classBackgroundColor == other.classBackgroundColor &&
          classFontColor == other.classFontColor &&
          classBorderColor == other.classBorderColor);

  @override
  int get hashCode => Object.hashAll([
        backgroundColor,
        fontColor,
        textAlign,
        activityRoundCorner,
        fontSize,
        noteFontColor,
        noteBackgroundColor,
        noteBorderColor,
        activityBackgroundColor,
        activityFontColor,
        activityBorderColor,
        rectangleBackgroundColor,
        rectangleFontColor,
        rectangleBorderColor,
        partitionBackgroundColor,
        partitionFontColor,
        partitionBorderColor,
        activityStartColor,
        activityEndColor,
        activityEndBackgroundColor,
        activityEndBorderColor,
        activityDiamondBackgroundColor,
        arrowColor,
        componentBackgroundColor,
        componentFontColor,
        componentBorderColor,
        interfaceBackgroundColor,
        interfaceFontColor,
        interfaceBorderColor,
        packageBackgroundColor,
        packageFontColor,
        packageBorderColor,
        sequenceBackgroundColor,
        sequenceFontColor,
        sequenceBorderColor,
        classBackgroundColor,
        classFontColor,
        classBorderColor,
      ]);
}

/// Parameters for generating PlantUML diagram URLs.
///
/// Wraps [encodingParameters] with a [provider] and optional [type].
/// These parameters are passed to [PlantUml.getUrl] to configure the
/// diagram generation.
class PlantUmlParameters
    extends UmlParameters<PlantUMLProvider, PlantUMLFileType> {
  /// Creates parameters for generating PlantUML diagram URLs.
  ///
  /// [provider] defaults to [PlantUMLProvider.planttext].
  /// [type] defaults to [PlantUMLFileType.svg].
  const PlantUmlParameters({
    this.provider = PlantUMLProvider.planttext,
    this.type = PlantUMLFileType.svg,
  });

  /// The PlantUML server provider to use for rendering.
  ///
  /// Defaults to [PlantUMLProvider.planttext].
  @override
  final PlantUMLProvider provider;

  /// The output file type for the diagram.
  ///
  /// Supported types depend on the provider. Defaults to SVG.
  @override
  final PlantUMLFileType type;

  /// Returns a copy of this [PlantUmlParameters] with the given fields replaced.
  ///
  /// Use this to create modified parameter instances without mutating the original.
  @override
  PlantUmlParameters copyWith({
    PlantUMLProvider? provider,
    PlantUMLFileType? type,
  }) {
    return PlantUmlParameters(
      provider: provider ?? this.provider,
      type: type ?? this.type,
    );
  }
}

/// Configuration for PlantUML diagrams.
final class PlantUmlConfig extends UmlConfig {
  /// Creates a PlantUML configuration from [parameters].
  const PlantUmlConfig(
      {this.parameters = const PlantUmlParameters(),
      this.encodingParameters = const PlantUmlEncodingParameters()});

  @override
  PlantUml get umlBuilder => PlantUml.instance;

  @override
  List<PlantUMLProvider> get allProviders => PlantUMLProvider.values;

  @override
  List<PlantUmlTheme> get allThemes => PlantUmlTheme.values;

  @override
  final PlantUmlParameters parameters;

  /// The encoding-specific parameters for theme, colors, and styling.
  @override
  final PlantUmlEncodingParameters encodingParameters;

  @override
  PlantUmlConfig copyWith({
    PlantUmlParameters? parameters,
    PlantUmlEncodingParameters? encodingParameters,
  }) {
    return PlantUmlConfig(
      parameters: parameters ?? this.parameters,
      encodingParameters: encodingParameters ?? this.encodingParameters,
    );
  }

}
