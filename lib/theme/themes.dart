import 'package:flutter/material.dart';

class Themes {
  late ThemeData _cleanLight;
  late ThemeData _cleanDark;

  Themes() {
    final ColorScheme _colorsLight = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 59, 81, 159),
      brightness: Brightness.light,
    );
    final ColorScheme _colorsDark = ColorScheme.fromSeed(
      seedColor: Color.fromARGB(255, 4, 17, 70),
      brightness: Brightness.dark,
    );

    _cleanLight = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _colorsLight,
      scaffoldBackgroundColor: _colorsLight.background,
      fontFamily: 'Montserrat',
      appBarTheme: AppBarTheme(
        backgroundColor: _colorsLight.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 33,
          overflow: TextOverflow.visible,
          color: _colorsLight.onBackground,
        ),
      ),
      switchTheme: SwitchThemeData(),
      checkboxTheme: CheckboxThemeData(
        side: MaterialStateBorderSide.resolveWith((states) => BorderSide(
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
      colorScheme: _colorsDark,
      scaffoldBackgroundColor: _colorsDark.background,
      fontFamily: 'Montserrat',
      appBarTheme: AppBarTheme(
        backgroundColor: _colorsDark.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 33,
          overflow: TextOverflow.visible,
          color: _colorsDark.onBackground,
        ),
      ),
      switchTheme: SwitchThemeData(),
      checkboxTheme: CheckboxThemeData(
        side: MaterialStateBorderSide.resolveWith((states) => BorderSide(
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
