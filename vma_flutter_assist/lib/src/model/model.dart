import 'dart:convert';

abstract class Model<T> {
  /// 从map序列化
  T fromJson(Map<String, dynamic> map);

  /// 从jsonStr序列化
  T fromJsonString(String jsonStr) => fromJson(json.decode(jsonStr));

  /// 反序列化成map
  Map<String, dynamic> toJson();

  /// 反序列化成jsonStr
  String toJsonString() => json.encode(this);
}
