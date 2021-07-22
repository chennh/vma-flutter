import 'dart:convert' as dartConvert;
import 'package:vma_flutter_assist/vma_flutter_assist.dart';

class AccountLoginReq extends Model {
  /// 账号
  String account;

  /// 加密后的密码
  String password;

  /// 加密串索引
  String randomIndex;

  AccountLoginReq(
    this.account,
    this.password,
    this.randomIndex,
  );

  AccountLoginReq.fromJson(Map<String, dynamic> map)
      : account = map['account'],
        password = map['password'],
        randomIndex = map['randomIndex'];

  AccountLoginReq.fromJsonString(String jsonStr)
      : this.fromJson(dartConvert.json.decode(jsonStr));

  Map<String, dynamic> toJson() => {
        'account': account,
        'password': password,
        'randomIndex': randomIndex,
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
