import 'dart:developer';

import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(options, handler) {
    log('RQUEST[$options.method] => PATH: {$options.path}');
    super.onRequest(options, handler);
  }
}
