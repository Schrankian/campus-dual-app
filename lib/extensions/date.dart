extension DateExtension on DateTime {
  // Returns the date in the format 'dd.MM.yyyy'
  String toDateString() {
    return '${day.toString().padLeft(2, '0')}.${month.toString().padLeft(2, '0')}.${year}';
  }

  // Returns the time in the format 'HH:mm'
  String toTimeString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String toTimeDiff(DateTime end, {bool showDifference = true}) {
    if (hour == 0 && minute == 0 || end.hour == 0 && end.minute == 0) return 'Keine Zeitangabe';
    final diff = end.difference(this);
    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    if (!showDifference) return '${toTimeString()}->${end.toTimeString()}';
    return '${toTimeString()}->${end.toTimeString()} (${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}h)';
  }
}
