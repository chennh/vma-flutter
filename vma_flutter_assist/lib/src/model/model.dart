import 'dart:convert';

abstract class Model<T> {
  /// 从map序列化
  T fromJsonMap(Map<String, dynamic> map);

  /// 从jsonStr序列化
  T fromJson(jsonStr) =>
      fromJsonMap(jsonStr is String ? json.decode(jsonStr) : jsonStr);

  /// 反序列化成map
  Map<String, dynamic> toJson();

  /// 反序列化成jsonStr
  String toString() => json.encode(this);

  static transformFromJson<T>(data, Model<T> fromJson(item)) {
    if (data is List) {
      return data.map((item) => fromJson(item)).toList();
    }
    return fromJson(data);
  }
}
