import 'package:flutter/material.dart';

extension ExtTimeOfDay on TimeOfDay {
  double toDouble() {
    return hour + minute / 60;
  }

  static TimeOfDay fromDouble(double frac) {
    final hour = frac.floor();
    final minute = ((frac - hour) * 60).round();
    return TimeOfDay(hour: hour, minute: minute);
  }

  String formatTime() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  static TimeOfDay fromString(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  bool operator >(TimeOfDay other) {
    return toDouble() > other.toDouble();
  }

  bool operator <(TimeOfDay other) {
    return toDouble() < other.toDouble();
  }

  bool operator >=(TimeOfDay other) {
    return toDouble() >= other.toDouble();
  }

  bool operator <=(TimeOfDay other) {
    return toDouble() <= other.toDouble();
  }
}
