import 'package:campus_dual_android/scripts/notification_manager.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class BackgroundServiceManager {
  final FlutterBackgroundService flutterBackgroundService = FlutterBackgroundService();

  @pragma('vm:entry-point')
  static Future<void> onStart(ServiceInstance serivce) async {
    while (true) {
      await Future.delayed(Duration(seconds: 10));
      NotificationManager().showNotification("Test ", "Simple test notifciation from background service");
    }
  }

  Future<void> init() async {
    await flutterBackgroundService.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: false,
        autoStart: true,
        autoStartOnBoot: true,
      ),
    );
  }
}
