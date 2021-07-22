import 'package:dio/dio.dart';

class HttpWrap {
  HttpWrap._();

  /// 合并options
  static Options mergeOptions(Options source, Options? target) {
    if (target == null) {
      return source;
    }
    return source.copyWith(
      method: target.method,
      sendTimeout: target.sendTimeout,
      receiveTimeout: target.receiveTimeout,
      extra: target.extra,
      headers: target.headers,
      responseType: target.responseType,
      contentType: target.contentType,
      validateStatus: target.validateStatus,
      receiveDataWhenStatusError: target.receiveDataWhenStatusError,
      followRedirects: target.followRedirects,
      maxRedirects: target.maxRedirects,
      requestEncoder: target.requestEncoder,
      responseDecoder: target.responseDecoder,
      listFormat: target.listFormat,
    );
  }

  /// 替换data并生成新的[Response]
  static Response<T> dataResponse<T>(Response source, T? data) {
    return Response<T>(
      data: data,
      headers: source.headers,
      requestOptions: source.requestOptions,
      isRedirect: source.isRedirect,
      statusCode: source.statusCode,
      statusMessage: source.statusMessage,
      redirects: source.redirects,
      extra: source.extra,
    );
  }

  /// 转换response，将data转换为bean对象
  static transformResponse<T>(
      Response response, T fromJson(Map<String, dynamic> data)) {
    if (response.data == null) {
      return response;
    }
    return dataResponse<dynamic>(response, fromResponseData(response.data, fromJson));
  }

  /// response.data转为bean对象
  static fromResponseData<T>(data, T fromJson(Map<String, dynamic> data)) {
    if (data is List) {
      return data.map((item) => fromResponseData(item, fromJson));
    }
    if (data is Map) {
      return fromJson(data as Map<String, dynamic>);
    }
    return data;
  }

}
