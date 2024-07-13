import 'dart:convert';

import 'package:campus_dual_android/scripts/campus_dual_manager.models.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

extension BaColor on Color {
  static Color fromRule(List<EvaluationRule> rules, String title, bool useFuzzyColor, BuildContext context) {
    final match = EvaluationRule.getMatch(rules, title);
    if (match != null) {
      return match.color;
    }

    if (useFuzzyColor) {
      return FuzzyColor.fromString(title);
    }

    return Theme.of(context).colorScheme.primary;
  }

  static Color fromSurface(Color surfaceColor) {
    final luminance = 1 - (0.299 * surfaceColor.red + 0.587 * surfaceColor.green + 0.114 * surfaceColor.blue) / 255;

    return luminance < 0.5 ? Colors.black : Colors.white;
  }
}

class FuzzyColor {
  static Color fromString(String input) {
    // Generate hash from the input string
    var bytes = utf8.encode("${input}Salt");
    var digest = sha256.convert(bytes);

    // Convert hash to hexadecimal string
    String hexColor = digest.toString().substring(0, 6); // Extract the first 6 characters as the color code

    // Convert hexadecimal color code to Color object
    return Color(int.parse(hexColor, radix: 16) | 0xFF000000);
  }
}
