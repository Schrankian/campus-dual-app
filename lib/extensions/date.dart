extension DateExtension on DateTime {
  // Returns the date in the format 'dd.MM.yyyy'
  String toDateString() {
    return '${day.toString().padLeft(2, '0')}.${month.toString().padLeft(2, '0')}.$year';
  }

  // Returns the time in the format 'HH:mm'
  String toTimeString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  // Returns only the year date and month
  DateTime trim() {
    return DateTime(year, month, day);
  }

  DateTime toCet() {
    final utc = toUtc();
    final year = utc.year;

    // Calculate the last Sunday in March (start of Sommerzeit)
    DateTime lastSundayInMarch = DateTime(year, 3, 31);
    while (lastSundayInMarch.weekday != DateTime.sunday) {
      lastSundayInMarch = lastSundayInMarch.subtract(Duration(days: 1));
    }

    // Calculate the last Sunday in October (end of Sommerzeit)
    DateTime lastSundayInOctober = DateTime(year, 10, 31);
    while (lastSundayInOctober.weekday != DateTime.sunday) {
      lastSundayInOctober = lastSundayInOctober.subtract(Duration(days: 1));
    }

    // Determine if the current date is within the Sommerzeit period
    if (utc.isAfter(lastSundayInMarch.add(Duration(hours: 1))) && utc.isBefore(lastSundayInOctober.add(Duration(hours: 1)))) {
      // Sommerzeit (CEST)
      return utc.add(Duration(hours: 2));
    } else {
      // Winterzeit (CET)
      return utc.add(Duration(hours: 1));
    }
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
