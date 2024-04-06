import 'package:campus_dual_android/screens/homepage.dart';
import 'package:campus_dual_android/scripts/event_bus.dart';
import 'package:campus_dual_android/scripts/storage_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/themes.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var themes = Themes();
  // TODO get initial from storage
  var themeMode = true ? ThemeMode.dark : ThemeMode.light;

  void _onThemeChange(dynamic args) {
    setState(() {
      // TODO switch for real
      themeMode = true ? ThemeMode.dark : ThemeMode.light;
      // TODO set  storage
    });
  }

  @override
  void initState() {
    super.initState();
    mainBus.onBus(event: "ToggleTheme", onEvent: _onThemeChange);
  }

  @override
  void dispose() {
    mainBus.offBus(event: "ToggleTheme", callBack: _onThemeChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    StorageManager().loadUserAuthData();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Campus Dual',
      themeMode: themeMode, //can also be ThemeMode.light or ThemeMode.dark
      theme: themes.cleanLight,
      darkTheme: themes.cleanDark,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: const HomePage(),
    );
  }
}
