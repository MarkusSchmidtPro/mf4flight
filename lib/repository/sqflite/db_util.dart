
class DBUtil {

  static int getVersionFromNow() =>
      DateTime.now().toUtc().millisecondsSinceEpoch;

  // version to UTC
  // DateTime dt1 =   DateTime.fromMillisecondsSinceEpoch(1617726048990);
  // print(dt1.toUtc());

  // Static field is required to support SyncRecord: recordVersion > DBHelper.lastSyncVersion;
  static int lastSyncVersion = 0;

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

