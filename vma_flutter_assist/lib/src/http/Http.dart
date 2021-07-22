import 'package:dio/dio.dart';
import 'package:vma_flutter_assist/src/wrap/HttpWrap.dart';

class HttpConfig {
  BaseOptions? options;

  List<Interceptor>? interceptors;

  HttpConfig({this.options, this.interceptors});
}

class Http {
  static late Http _instance;

  HttpConfig? _config;

  late Dio _dio;

  /// 取全局单例
  static Http get instance => _instance;

  /// 初始化全局单例
  static Http init(HttpConfig? config) => _instance = create(config);

  /// 创建Http实例
  static Http create(HttpConfig? config) => Http(config);

  /// 合并Options
  static Options mergeOptions(Options source, Options? target) =>
      HttpWrap.mergeOptions(source, target);

  /// 转换Response
  static Response<T> transformResponse<T>(
          Response response, T fromJson(Map<String, dynamic> data)) =>
      HttpWrap.transformResponse(response, fromJson);

  /// Handy method to make http GET request, which is a alias of  [Http.request(RequestOptions)].
  static Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      instance.request<T>(
        path,
        queryParameters: queryParameters,
        options: mergeOptions(Options(method: 'GET'), options),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

  /// Handy method to make http POST request, which is a alias of  [Http.request(RequestOptions)].
  static Future<Response<T>> post<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      instance.request<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: mergeOptions(Options(method: 'POST'), options),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

  /// Handy method to make http PUT request, which is a alias of  [Http.request(RequestOptions)].
  static Future<Response<T>> put<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      instance.request<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: mergeOptions(Options(method: 'PUT'), options),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

  /// Handy method to make http DELETE request, which is a alias of  [Http.request(RequestOptions)].
  static Future<Response<T>> delete<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      instance.request<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: mergeOptions(Options(method: 'DELETE'), options),
        cancelToken: cancelToken,
      );

  Http(this._config) : _dio = Dio(_config?.options) {
    _config?.interceptors
        ?.forEach((interceptor) => _dio.interceptors.add(interceptor));
  }

  /// Make http request with options, which is a alias of  [Dio.request(RequestOptions)].
  ///
  /// [path] The url path.
  /// [data] The request data
  /// [options] The request options.
  Future<Response<T>> request<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
}
