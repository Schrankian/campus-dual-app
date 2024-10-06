import 'dart:async';

import 'package:campus_dual_android/scripts/campus_dual_manager.dart';
import 'package:campus_dual_android/scripts/event_bus.dart';
import 'package:campus_dual_android/scripts/storage_manager.dart';
import 'package:flutter/material.dart';
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
        debugPrint("Reloading timetable and updating widget...");
        final nowDay = DateTime.now();
        const bufferSize = 365;
        final lessons = await CampusDualManager().fetchTimeTable(nowDay.subtract(const Duration(days: bufferSize)), nowDay.add(const Duration(days: bufferSize)));
        await StorageManager().saveObject("timetable", lessons.map((key, value) => MapEntry(key.toIso8601String(), value.map((e) => e.toJson()).toList())));
        updateWidget();
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
