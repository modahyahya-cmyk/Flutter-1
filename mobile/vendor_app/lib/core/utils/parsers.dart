/// Shared helpers to coerce raw JSON values into typed Dart values defensively.
class Parsers {
  Parsers._();

  static double doubleOf(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static double? doubleOrNull(Object? value) {
    if (value == null) return null;
    return doubleOf(value);
  }

  static int intOf(Object? value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? intOrNull(Object? value) {
    if (value == null) return null;
    return intOf(value);
  }

  static DateTime? dateTimeOrNull(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
