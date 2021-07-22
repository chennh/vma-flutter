import 'package:dio/dio.dart';
import 'package:vma_flutter_assist/src/wrap/StringWrap.dart';
import 'package:vma_flutter_assist/src/wrap/HttpWrap.dart';

enum HttpJsonStrategy {
  /// 处理成驼峰
  HUMP,

  /// 处理成下划线
  UNDERLINE,

  /// 忽略
  IGNORE,
}

class HttpJsonStrategyKey {
  /// request请求的json策略独立配置key
  static const String DATA_FORMAT = 'DATA_FORMAT';

  /// response响应的json策略独立配置key
  static const String RESPONSE_DATA_FORMAT = 'RESPONSE_DATA_FORMAT';
}

class HttpJsonStrategyValue {
  /// 驼峰
  static const String HUMP = 'HUMP';

  /// 下划线
  static const String UNDERLINE = 'UNDERLINE';
}

typedef RequestHandler = RequestOptions Function(RequestOptions options);
typedef ResponseHandler = Response Function(Response response);

class HttpJsonStrategyHandler {
  HttpJsonStrategy _strategy;
  String _name;
  String _strategyValue;

  HttpJsonStrategyHandler(this._name, this._strategyValue, this._strategy);
}

class HttpJsonStrategyRequestHandler extends HttpJsonStrategyHandler {
  RequestHandler request;

  HttpJsonStrategyRequestHandler(String name, String strategyValue,
      HttpJsonStrategy strategy, this.request)
      : super(name, strategyValue, strategy);

  /// request参数转驼峰
  static final dataFormatHump = HttpJsonStrategyRequestHandler(
      HttpJsonStrategyKey.DATA_FORMAT,
      HttpJsonStrategyValue.HUMP,
      HttpJsonStrategy.HUMP, (options) {
    options.queryParameters = StringWrap.dataToHump(options.queryParameters);
    if (options.data != null) {
      options.data = StringWrap.dataToHump(options.data);
    }
    return options;
  });

  /// request参数转下划线
  static final dataFormatUnderline = HttpJsonStrategyRequestHandler(
      HttpJsonStrategyKey.DATA_FORMAT,
      HttpJsonStrategyValue.UNDERLINE,
      HttpJsonStrategy.UNDERLINE, (options) {
    options.queryParameters =
        StringWrap.dataToUnderline(options.queryParameters);
    if (options.data != null) {
      options.data = StringWrap.dataToUnderline(options.data);
    }
    return options;
  });
}

class HttpJsonStrategyResponseHandler extends HttpJsonStrategyHandler {
  ResponseHandler response;

  HttpJsonStrategyResponseHandler(String name, String strategyValue,
      HttpJsonStrategy strategy, this.response)
      : super(name, strategyValue, strategy);

  /// 响应数据转驼峰
  static final responseDataFormatHump = HttpJsonStrategyResponseHandler(
      HttpJsonStrategyKey.RESPONSE_DATA_FORMAT,
      HttpJsonStrategyValue.HUMP,
      HttpJsonStrategy.HUMP, (response) {
    if (response.data != null) {
      return HttpWrap.dataResponse(
          response, StringWrap.dataToHump(response.data));
    }
    return response;
  });

  /// 响应数据转下划线
  static final responseDataFormatUnderline = HttpJsonStrategyResponseHandler(
      HttpJsonStrategyKey.RESPONSE_DATA_FORMAT,
      HttpJsonStrategyValue.UNDERLINE,
      HttpJsonStrategy.UNDERLINE, (response) {
    if (response.data != null) {
      return HttpWrap.dataResponse(
          response, StringWrap.dataToUnderline(response.data));
    }
    return response;
  });
}

class HttpJsonStrategyConfig {
  /// 全局request请求的json策略
  HttpJsonStrategy _request;

  /// 全局response响应的json策略
  HttpJsonStrategy _response;

  /// request请求json策略处理器
  List<HttpJsonStrategyRequestHandler> _requestHandlers;

  /// response响应json策略处理器
  List<HttpJsonStrategyResponseHandler> _responseHandlers;

  HttpJsonStrategyConfig({
    HttpJsonStrategy? request,
    HttpJsonStrategy? response,
    List<HttpJsonStrategyRequestHandler>? requestHandlers,
    List<HttpJsonStrategyResponseHandler>? responseHandlers,
  })  :

        /// request默认转下划线
        _request = request ?? HttpJsonStrategy.UNDERLINE,

        /// response默认转驼峰
        _response = response ?? HttpJsonStrategy.HUMP,

        /// request默认只启用驼峰handler
        _requestHandlers = requestHandlers ??
            [HttpJsonStrategyRequestHandler.dataFormatUnderline],

        /// response默认只启用下划线handler
        _responseHandlers = responseHandlers ??
            [HttpJsonStrategyResponseHandler.responseDataFormatHump];
}

/// Http请求json策略拦截器
class JsonStrategyInterceptor extends InterceptorsWrapper {
  late HttpJsonStrategyConfig _config;

  JsonStrategyInterceptor({HttpJsonStrategyConfig? config})
      : _config = config ?? HttpJsonStrategyConfig();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (_config._requestHandlers.isNotEmpty) {
      for (var handler in _config._requestHandlers) {
        if (options.extra.containsKey(handler._name) &&
                options.extra[handler._name].toString().toUpperCase() ==
                    handler._strategyValue ||
            _config._request == handler._strategy) {
          options = handler.request(options);
        }
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data != null && _config._responseHandlers.isNotEmpty) {
      for (var handler in _config._responseHandlers) {
        if (response.extra.containsKey(handler._name) &&
                response.extra[handler._name].toString().toUpperCase() ==
                    handler._strategyValue ||
            _config._response == handler._strategy) {
          response = handler.response(response);
        }
      }
    }
    handler.next(response);
  }
}
