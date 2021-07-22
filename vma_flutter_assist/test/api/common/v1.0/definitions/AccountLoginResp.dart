import 'dart:convert' as dartConvert;
import 'package:vma_flutter_assist/vma_flutter_assist.dart';

class AccountLoginResp extends Model {
  /// 老师账号
  String account;

  /// 老师头像
  String? avatar;

  /// 老师id
  int id;

  /// macKey
  String macKey;

  /// 老师姓名
  String name;

  /// 老师昵称
  String? nickname;

  AccountLoginResp({
    account,
    avatar,
    id,
    macKey,
    name,
    nickname,
  }) : this.fromJson({
          'account': account,
          'avatar': avatar,
          'id': id,
          'macKey': macKey,
          'name': name,
          'nickname': nickname,
        });

  AccountLoginResp.fromJson(Map<String, dynamic> map)
      : account = map['account'],
        avatar = map['avatar'],
        id = map['id'],
        macKey = map['macKey'],
        name = map['name'],
        nickname = map['nickname'];

  AccountLoginResp.fromJsonString(String jsonStr)
      : this.fromJson(dartConvert.json.decode(jsonStr));

  Map<String, dynamic> toJson() => {
        'account': account,
        'avatar': avatar,
        'id': id,
        'macKey': macKey,
        'name': name,
        'nickname': nickname,
      };

  @override
  String toString() {
    return dartConvert.json.encode(this);
  }

  @override
  fromJson(Map<String, dynamic> map) => fromJson(map);

  @override
  fromJsonString(String jsonStr) => fromJsonString(jsonStr);
}
