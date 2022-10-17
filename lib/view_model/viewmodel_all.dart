//mixin ViewModelAll {
  /// zn: Zero to Null - empty string to null.

  String? zn(String? s) => (s==null || s.isEmpty) ? null : s;

  /// Returns *null* when [s] is blank.
  /// ref: ...returns `null` for invalid inputs instead of throwing.
  double? znDouble(String s) => double.tryParse(s);
  
  // Parse source as a double literal using a '.'
  double? znCurrency(String s) {
    if( s.contains(",")) s= s.replaceAll(",", ".");
    return double.tryParse(s);
  }  
  
  DateTime? znDate(String? s) {
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  
  /// Not-Zero or not-null converts a nullable string into a String.
  String nz(String? s, [String defaultValue = '']) => s ?? defaultValue;

  /// Convert a double to string or null to blank.
  String nzDouble(double? value, String Function(double v) toString) =>
      value == null ? "" : toString(value);

  // String nzDate(DateTime? value) {
  //   return value == null ? "": value.toIso8601String().substring(0, 10);
  // } 
  
  String toDateString(DateTime value) => value.toIso8601String().substring(0, 10);
//}
