import 'package:dio/dio.dart';
import 'package:vma_flutter_assist/vma_flutter_assist.dart';

import 'definitions/AccountLoginReq.dart';
import 'definitions/AccountLoginResp.dart';
import 'definitions/EncryptionResp.dart';

class AccountApi {
  AccountApi._();

  ///
  /// 登录
  ///
  /// @param { AccountLoginReq } params
  /// @return { Future<Response<AccountLoginResp>> }
  ///
  static Future<Response<AccountLoginResp>> login(
    AccountLoginReq params, {
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      Http.post(
        '/common/v1.0/account/login',
        data: params.toJson(),
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ).then((response) => Http.transformResponse(
          response, (model) => AccountLoginResp.fromJson(model)));

  ///
  /// 获取加密串
  ///
  /// @return { Future<Response<EncryptionResp>> }
  ///
  static Future<Response<EncryptionResp>> getEncryption({
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      Http.get(
        '/common/v1.0/account/encryption',
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ).then((response) => Http.transformResponse(
          response, (model) => EncryptionResp.fromJson(model)));

  ///
  /// 退出
  ///
  /// @return { Future<Response<void>> }
  ///
  static Future<Response<void>> logout({
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return Http.post('/common/v1.0/account/logout',
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
  }

  ///
  /// 获取当前登录用户
  ///
  /// @return { Future<Response<AccountLoginResp>> }
  ///
  static Future<Response<AccountLoginResp>> getCurrent({
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return Http.get('/common/v1.0/account/current',
            options: options,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress)
        .then((response) => Http.transformResponse(
            response, (model) => AccountLoginResp.fromJson(model)));
  }
}
