import 'dart:async';

import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final TokenManager tokenManager;

  AuthInterceptor(this.dio, this.tokenManager);

  @override
  void onRequest(options, handler) async {
    final token = tokenManager.token;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(err, handler) async {
    if (err.response?.statusCode == 401) {
      try {
        await tokenManager.refreshToken();

        final request = err.requestOptions;

        request.headers['Authorization'] = 'Bearer ${tokenManager.token}';

        final response = await dio.fetch(request);

        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    return handler.next(err);
  }
}

class TokenManager {
  String? _accessToken;

  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  String? get token => _accessToken;

  Future<void> refreshToken() async {
    if (_isRefreshing) {
      return _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer();

    try {
      await Future.delayed(const Duration(seconds: 1));

      _accessToken = "NEW_TOKEN";

      _refreshCompleter!.complete();
    } catch (e) {
      _refreshCompleter!.completeError(e);
    } finally {
      _isRefreshing = false;
    }
  }
}
