class StringWrap {
  StringWrap._();

  /// 字符串转下划线
  static String strToUnderline(String str) {
    return str.replaceAllMapped(
        RegExp(r'([A-Z])'), (Match m) => '_${m[0]?.toLowerCase()}');
  }

  /// 字符串转驼峰
  static String strToHump(String str) {
    return str.replaceAllMapped(
        RegExp(r'(_([a-z]))'), (Match m) => '${m[2]?.toUpperCase()}');
  }

  /// Map转下划线
  static Map<String, dynamic> dataToUnderline(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(strToUnderline(key),
        value is Map ? dataToUnderline(value as Map<String, dynamic>) : value));
  }

  /// Map转驼峰
  static Map<String, dynamic> dataToHump(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(strToHump(key),
        value is Map ? dataToHump(value as Map<String, dynamic>) : value));
  }
}
