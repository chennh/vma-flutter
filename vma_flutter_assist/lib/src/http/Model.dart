abstract class Model {
  fromJson(Map<String, dynamic> map);

  fromJsonString(String jsonStr);

  Map<String, dynamic> toJson();
}
