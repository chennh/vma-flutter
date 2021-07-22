import 'package:dio/dio.dart';
import 'package:vma_flutter_assist/src/authorization/Authorization.dart';

typedef AuthorizationHandler = String Function(
    String url, String method, String macKey);
typedef GetToken = String Function(RequestOptions options);

class AuthorizationConfig {
  String _headerName;
  bool _debug;
  AuthorizationHandler _handler;
  GetToken _getToken;

  AuthorizationConfig(this._getToken,
      {AuthorizationHandler? handler, String? headerName, bool? debug})
      : _handler = handler ?? AuthorizationSDKService.hmacUrl,
        _headerName = headerName ?? 'Authorization',
        _debug = debug ?? false;
}

class AuthorizationInterceptor extends InterceptorsWrapper {
  AuthorizationConfig _config;

  AuthorizationInterceptor(this._config);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (!options.headers.containsKey(_config._headerName)) {
      String macKey = _config._getToken(options);
      options.headers[_config._headerName] = _config._debug
          ? macKey
          : _config._handler(options.uri.toString(), options.method, macKey);
      print(options.uri);
    }
    handler.next(options);
  }
}
