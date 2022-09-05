import 'package:uuid/uuid.dart';

class DBHelper {
  static String newGuid() => (new Uuid()).v4();

  /// UTC now without microseconds
  static DateTime utcNow() {
    DateTime d = DateTime.now().toUtc();
    return d.toIso8601String().parseToUtc();
  }

  static int getVersionFromNow() => utcNow().millisecondsSinceEpoch;

  // version to UTC
  // DateTime dt1 =   DateTime.fromMillisecondsSinceEpoch(1617726048990);
  // print(dt1.toUtc());

  // Static field is required to support SyncRecord: recordVersion > DBHelper.lastSyncVersion;
  static int lastSyncVersion = 0;

  /// Conditional convert an empty string to null.
  //static String? toNull(String? s) => isNullOrEmpty(s) ? null : s;

  static bool isNullOrEmpty(String? s) => s == null || s.isEmpty;
}

extension StringExtensions on String {
  // DateTime parseDate() {
  //   DateTime parsed = DateTime.parse(this);
  //   return new DateTime(parsed.year, parsed.month, parsed.day);
  // }

  /// String to UTC datetime.
  DateTime parseToUtc() {
    var parsed = DateTime.parse(this);
    return parsed.isUtc
        ? new DateTime.utc(
        parsed.year, parsed.month, parsed.day, parsed.hour, parsed.minute, parsed.second, parsed.millisecond)
        : new DateTime(
        parsed.year, parsed.month, parsed.day, parsed.hour, parsed.minute, parsed.second, parsed.millisecond)
        .toUtc();
  }
}

extension DateExtensions on DateTime {
  String toDateString() => this.toIso8601String().substring(0, 10);
}
