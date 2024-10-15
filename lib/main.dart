import 'dart:io';

import 'package:campus_dual_android/background/widget.dart';
import 'package:campus_dual_android/screens/homepage.dart';
import 'package:campus_dual_android/screens/login.dart';
import 'package:campus_dual_android/scripts/campus_dual_manager.dart';
import 'package:campus_dual_android/scripts/event_bus.dart';
import 'package:campus_dual_android/scripts/storage_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'theme/themes.dart';
import "package:campus_dual_android/scripts/campus_dual_manager.models.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fix some issues related to reinstalling the app
  await StorageManager().fixFirstLaunchIssues();

  // Load campus dual certificate
  Future<ByteData> data = PlatformAssetBundle().load('assets/ca/selfservice.campus-dual.de.crt');
  Future<ThemeMode> initTheme = StorageManager().loadTheme();
  Future<UserCredentials?> creds = StorageManager().loadUserAuthData();

  var result = await Future.wait([data, initTheme, creds]);

  SecurityContext.defaultContext.setTrustedCertificatesBytes((result[0] as ByteData).buffer.asUint8List());
  CampusDualManager.userCreds = result[2] as UserCredentials?;

  runApp(
    MyApp(initTheme: result[1] as ThemeMode),
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
    StorageManager().clearAll().then((_) => updateWidget());
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

    HomeWidget.registerInteractivityCallback(backgroundCallback);
    listenWidgetLaunchStream(HomeWidget.widgetClicked, HomeWidget.initiallyLaunchedFromHomeWidget());

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
