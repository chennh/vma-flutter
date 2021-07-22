import 'package:vma_flutter_assist/vma_flutter_assist.dart';
import 'package:dio/dio.dart';
import 'api/common/v1.0/accountApi.dart';
import 'api/common/v1.0/qiniuOssApi.dart';
import 'api/common/v1.0/definitions/EncryptionResp.dart';
import 'api/common/v1.0/definitions/AccountLoginReq.dart';
import 'api/common/v1.0/definitions/AccountLoginResp.dart';
import 'api/common/v1.0/definitions/QiniuTokenBO.dart';

void main() async {
  Map<String, String> map = {'token': ''};
  Http.init(HttpConfig(
      options: BaseOptions(
          baseUrl: 'http://39.100.61.208:51002',
          receiveTimeout: 10000,
          connectTimeout: 10000),
      interceptors: [
        JsonStrategyInterceptor(),
        AuthorizationInterceptor(
            AuthorizationConfig((options) => map['token'] ?? '', debug: true))
      ]));

  String account = 'xmls10010';
  String password = '123456';

  // 登录
//  print('getEncryption');
//  EncryptionResp encryptionResp =
//      (await AccountApi.getEncryption()).data as EncryptionResp;
//  String encryptPassword = RSAWrap.encrypt(
//      password, encryptionResp.modulus as String, encryptionResp.exponent as String);
//
//  print('login');
//  AccountLoginResp loginResp = (await AccountApi.login(AccountLoginReq(
//          account: account,
//          password: encryptPassword,
//          randomIndex: encryptionResp.randomIndex)))
//      .data as AccountLoginResp;
//  map['token'] = loginResp.macKey as String;
//
//  print('getCurrent: ' + (map['token'] as String));
//  AccountLoginResp loginResp2 =
//      (await AccountApi.getCurrent()).data as AccountLoginResp;
//  print(loginResp2);

  // 取七牛token，是个内嵌对象
  QiniuTokenBO qiniuTokenBO = (await QiniuOssApi.getQiNiuAddress()).data as QiniuTokenBO;
  print(qiniuTokenBO);
}
