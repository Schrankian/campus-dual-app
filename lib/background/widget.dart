import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:campus_dual_android/scripts/campus_dual_manager.dart';
import 'package:campus_dual_android/scripts/event_bus.dart';
import 'package:campus_dual_android/scripts/storage_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

void updateWidget() {
  HomeWidget.updateWidget(
    androidName: 'TimetableWidget',
  );
}

@pragma("vm:entry-point")
FutureOr<void> backgroundCallback(Uri? data) async {
  if (data == null) {
    return;
  }

  switch (data.host) {
    case "reload":
      {
        try {
          debugPrint("Reloading timetable and updating widget...");
          // Load campus dual certificate
          ByteData data = await PlatformAssetBundle().load('assets/ca/GEANT TLS RSA 1.crt');
          SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());

          bool useUntrustedHTTP = await StorageManager().loadBool("useUntrustedHTTP") ?? false;
          CampusDualManager.insecureMode = useUntrustedHTTP;

          // Load the user auth data
          final userCreds = await StorageManager().loadUserAuthData();
          if (userCreds == null) {
            debugPrint("User credentials not found. Aborting...");
            return;
          }
          CampusDualManager.userCreds = userCreds;

          // Fetch the timetable from campus dual
          final nowDay = DateTime.now();
          const bufferSize = 365;
          final lessons = await CampusDualManager().fetchTimeTable(nowDay.subtract(const Duration(days: bufferSize)), nowDay.add(const Duration(days: bufferSize)));

          // Save the timetable to the storage
          await StorageManager().saveObject("timetable", lessons.map((key, value) => MapEntry(key.toIso8601String(), value.map((e) => e.toJson()).toList())));

          // Save the last update time
          await StorageManager().saveDateTime("timetableUpdateTime", DateTime.now());

          // Notify the widget to update
          updateWidget();
        } catch (e, stack) {
          debugPrint("Error: $e");
          debugPrintStack(stackTrace: stack);
        }
        break;
      }
    default:
      {
        debugPrint("Unknown command: ${data.host}");
        break;
      }
  }
}

void listenWidgetLaunchStream(Stream<Uri?> stream, Future<Uri?> initialState) {
  void handleData(Uri? data) {
    if (data == null) {
      return;
    }

    debugPrint("Received data: $data");
    switch (data.host) {
      case "opentimetable":
        {
          mainBus.emit(event: "SetMainNavigationIndex", args: 3);
          break;
        }
      default:
        {
          debugPrint("Unknown launch uri: ${data.host}. Starting normally...");
          break;
        }
    }
    // Do something
  }

  // Handle the initial state when the app is launched
  Future.delayed(Duration(milliseconds: 100), () {
    initialState.then(handleData);
  });

  // Handle subsequent launch requests made by the widget
  stream.listen(handleData);
}
