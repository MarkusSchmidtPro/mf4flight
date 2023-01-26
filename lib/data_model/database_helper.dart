
class DBHelper {
  /// UTC now without microseconds
  static DateTime utcNow() {
    DateTime d = DateTime.now().toUtc();
    return d.toIso8601String().parseToUtc();
  }

  static int getVersionFromNow() =>
      DateTime.now().toUtc().millisecondsSinceEpoch;

  // version to UTC
  // DateTime dt1 =   DateTime.fromMillisecondsSinceEpoch(1617726048990);
  // print(dt1.toUtc());

  // Static field is required to support SyncRecord: recordVersion > DBHelper.lastSyncVersion;
  static int lastSyncVersion = 0;

  /// Conditional convert an empty string to null.
  //static String? toNull(String? s) => isNullOrEmpty(s) ? null : s;

  static bool isNullOrEmpty(String? s) => s == null || s.isEmpty;

  /// Build a SQL LIKE statement with multiple criteria, like an IN statement,
  ///
  /// [fieldNames] per filterTag: AND
  /// (   lower( fieldName[0]) LIKE '%filterTags[j]%'
  ///     OR lower( fieldName[1]) LIKE '%filterTags[j]%'
  ///     OR ...
  /// ) AND ... other filters
  static String buildInLike(
      List<String> fieldNames, List<String> filterTags) {
    assert(fieldNames.length > 0);
    assert(filterTags.length > 0);

    String result = _buildFilterTagLike(filterTags[0], fieldNames);
    for (int j = 1; j < filterTags.length; j++) {
      result += " OR " + _buildFilterTagLike(filterTags[j], fieldNames);
    }

    return "($result)";
  }

  /// Build an OR-block for all fieldNames
  /// on the current filterTag
  static String _buildFilterTagLike(String filterTag, List<String> fieldNames, {String logic="OR"}) {
    String filter = "lower( ${fieldNames[0]}) LIKE '%$filterTag%'";
    for (int i = 1; i < fieldNames.length; i++) {
      filter += " $logic lower( ${fieldNames[i]}) LIKE '%$filterTag%'";
    }
    return "($filter)";
  }
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
        ? new DateTime.utc(parsed.year, parsed.month, parsed.day, parsed.hour,
            parsed.minute, parsed.second, parsed.millisecond)
        : new DateTime(parsed.year, parsed.month, parsed.day, parsed.hour,
                parsed.minute, parsed.second, parsed.millisecond)
            .toUtc();
  }
}

extension DateExtensions on DateTime {
  String toDateString() => this.toIso8601String().substring(0, 10);
}
