class ModelUtils {
  static DateTime dateTimeFromJson(int intTimestamp) =>
      DateTime.fromMillisecondsSinceEpoch(intTimestamp);
  static int dateTimeToJson(DateTime time) => time.millisecondsSinceEpoch;

  static DateTime? nullableDateTimeFromJson(int? intTimestamp) {
    if (intTimestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(intTimestamp);
  }

  static Map<String, bool> friendsFromJson(Map<Object, Object> friendsJson) {
    return {};
  }

  static int? nullableDateTimeToJson(DateTime? time) =>
      time?.millisecondsSinceEpoch;
}
