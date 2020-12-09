import 'package:dio/dio.dart';

class DioWrap {
  static options(Options options, {customOptions: Options}) {
    if (customOptions == null) {
      return options;
    }
    return options.merge(
      method: customOptions.method,
      sendTimeout: customOptions.sendTimeout,
      receiveTimeout: customOptions.receiveTimeout,
      extra: customOptions.extra,
      headers: customOptions.headers,
      responseType: customOptions.responseType,
      contentType: customOptions.contentType,
      validateStatus: customOptions.validateStatus,
      receiveDataWhenStatusError: customOptions.receiveDataWhenStatusError,
      followRedirects: customOptions.followRedirects,
      maxRedirects: customOptions.maxRedirects,
      requestEncoder: customOptions.requestEncoder,
      responseDecoder: customOptions.responseDecoder,
    );
  }

  static response<R>(Response response, R data) {
    return new Response(
      data: data,
      headers: response.headers,
      request: response.request,
      isRedirect: response.isRedirect,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      redirects: response.redirects,
      extra: response.extra,
    );
  }
}
