class Util {
    static bool isNoE(String? s) => s == null || s.isEmpty;
    //static bool listIsNoE(List? l) => l == null || l.isEmpty;
    
    /// Get a list's first element or _null_ if [list] is _null_ or empty.
    static TListItem? firstOrNull<TListItem>(List<TListItem>? list) => (list != null && list.isNotEmpty) ? list[0] : null;
    
    /// UTC now without microseconds
    static DateTime utcNow() {
      DateTime d = DateTime.now().toUtc();
      return d.toIso8601String().parseToUtc();
    }
} 

extension StringExtensions on String {
  // DateTime parseDate() {
  //   DateTime parsed = DateTime.parse(this);
  //   return new DateTime(parsed.year, parsed.month, parsed.day);
  // }

  bool isNullOrEmpty(String? s) => s == null || s.isEmpty;
  
  
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