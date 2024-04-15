import 'dart:io';

import 'package:campus_dual_android/screens/homepage.dart';
import 'package:campus_dual_android/screens/login.dart';
import 'package:campus_dual_android/scripts/campus_dual_manager.dart';
import 'package:campus_dual_android/scripts/event_bus.dart';
import 'package:campus_dual_android/scripts/storage_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load campus dual certificate
  ByteData data = await PlatformAssetBundle().load('assets/ca/selfservice.campus-dual.de.crt');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());

  CampusDualManager.userCreds = await StorageManager().loadUserAuthData();
  // CampusDualManager.userCreds = UserCredentials("3004717", "BreakLoab-38", "54caf288eb3e1e5d12c046404a43fb9c");

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

  void _onLogout(dynamic args) {
    StorageManager().clearAll();
    setState(() {
      CampusDualManager.userCreds = null;
    });
  }

  void _onLogin(dynamic args) {
    if (args is UserCredentials) {
      StorageManager().saveUserAuthData(args);
      setState(() {
        CampusDualManager.userCreds = args;
      });
    } else {
      throw Exception("Invalid argument type");
    }
  }

  @override
  void initState() {
    super.initState();
    themeMode = widget.initTheme;
    mainBus.onBus(event: "ToggleTheme", onEvent: _onThemeChange);
    mainBus.onBus(event: "Logout", onEvent: _onLogout);
    mainBus.onBus(event: "Login", onEvent: _onLogin);
  }

  @override
  void dispose() {
    mainBus.offBus(event: "ToggleTheme", callBack: _onThemeChange);
    mainBus.offBus(event: "Logout", callBack: _onLogout);
    mainBus.offBus(event: "Login", callBack: _onLogin);
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
      home: CampusDualManager.userCreds != null ? const HomePage() : const Login(),
    );
  }
}
