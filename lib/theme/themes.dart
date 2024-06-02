import 'package:flutter/material.dart';

class Themes {
  late ThemeData _cleanLight;
  late ThemeData _cleanDark;

  Themes() {
    final ColorScheme colorsLight = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 59, 81, 159),
      brightness: Brightness.light,
    );
    final ColorScheme colorsDark = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 4, 17, 70),
      brightness: Brightness.dark,
    );

    _cleanLight = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorsLight,
      scaffoldBackgroundColor: colorsLight.surface,
      fontFamily: 'Montserrat',
      appBarTheme: AppBarTheme(
        backgroundColor: colorsLight.surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 33,
          overflow: TextOverflow.visible,
          color: colorsLight.onSurface,
        ),
      ),
      switchTheme: const SwitchThemeData(),
      checkboxTheme: CheckboxThemeData(
        side: WidgetStateBorderSide.resolveWith((states) => BorderSide(
              width: 1.0,
              color: _cleanLight.colorScheme.primary,
            )),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
      ),
    );
    _cleanDark = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorsDark,
      scaffoldBackgroundColor: colorsDark.surface,
      fontFamily: 'Montserrat',
      appBarTheme: AppBarTheme(
        backgroundColor: colorsDark.surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 33,
          overflow: TextOverflow.visible,
          color: colorsDark.onSurface,
        ),
      ),
      switchTheme: const SwitchThemeData(),
      checkboxTheme: CheckboxThemeData(
        side: WidgetStateBorderSide.resolveWith((states) => BorderSide(
              width: 1.0,
              color: _cleanDark.colorScheme.primary,
            )),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
      ),
    );
  }

  ThemeData get cleanLight => _cleanLight;
  ThemeData get cleanDark => _cleanDark;
}
