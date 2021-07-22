import 'package:vma_flutter_assist/vma_flutter_assist.dart';
import 'package:dio/dio.dart';
import 'api/common/v1.0/AccountApi.dart';
import 'api/common/v1.0/definitions/EncryptionResp.dart';
import 'api/common/v1.0/definitions/AccountLoginReq.dart';
import 'api/common/v1.0/definitions/AccountLoginResp.dart';

void main() async {
  Map<String, String> map = {'token': ''};
  Http.init(HttpConfig(
      options: BaseOptions(
          baseUrl: 'http://localhost:51002',
          receiveTimeout: 10000,
          connectTimeout: 10000),
      interceptors: [
        JsonStrategyInterceptor(),
        AuthorizationInterceptor(
            AuthorizationConfig((options) => map['token'] ?? '', debug: false))
      ]));

  String account = 'xmls10010';
  String password = '123456';

  print('getEncryption');
  EncryptionResp encryptionResp =
      (await AccountApi.getEncryption()).data as EncryptionResp;
  String encryptPassword = RSAWrap.encrypt(
      password, encryptionResp.modulus, encryptionResp.exponent);

  print('login');
  AccountLoginResp loginResp = (await AccountApi.login(AccountLoginReq(
          account, encryptPassword, encryptionResp.randomIndex)))
      .data as AccountLoginResp;
  map['token'] = loginResp.macKey;

  print('getCurrent: ' + (map['token'] as String));
  AccountLoginResp loginResp2 =
      (await AccountApi.getCurrent()).data as AccountLoginResp;
  print(loginResp2);
}
