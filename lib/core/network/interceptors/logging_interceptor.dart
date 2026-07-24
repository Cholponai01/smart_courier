import 'package:dio/dio.dart';
import 'package:smart_courier/core/logging/app_logger.dart';

class LoggingInterceptor extends Interceptor {
  static const _tag = 'HTTP';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug('→ ${options.method} ${options.uri}', tag: _tag);
    if (options.data != null) {
      AppLogger.debug('  body: ${options.data}', tag: _tag);
    }
    if (options.queryParameters.isNotEmpty) {
      AppLogger.debug('  query: ${options.queryParameters}', tag: _tag);
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.debug(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri}',
      tag: _tag,
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    AppLogger.error(
      '✕ ${statusCode ?? 'ERR'} ${err.requestOptions.method} '
      '${err.requestOptions.uri} — ${err.message}',
      tag: _tag,
      error: err,
    );
    super.onError(err, handler);
  }
}
