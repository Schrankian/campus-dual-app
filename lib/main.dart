import 'package:campus_dual_android/screens/homepage.dart';
import 'package:campus_dual_android/scripts/event_bus.dart';
import 'package:campus_dual_android/scripts/storage_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ThemeMode initTheme = await StorageManager().loadTheme();
  runApp(
    MyApp(initTheme: initTheme),
  );
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.initTheme});

  final ThemeMode initTheme;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var themes = Themes();
  late ThemeMode themeMode;

  void _onThemeChange(dynamic args) {
    setState(() {
      themeMode = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      StorageManager().saveTheme(themeMode);
    });
  }

  @override
  void initState() {
    super.initState();
    themeMode = widget.initTheme;
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
