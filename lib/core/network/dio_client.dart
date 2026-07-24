import 'package:dio/dio.dart';
import 'package:smart_courier/core/network/interceptors/logging_interceptor.dart';

Dio createDioClient({String? baseUrl}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl ?? '',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
    ),
  );

  dio.interceptors.add(LoggingInterceptor());

  return dio;
}
