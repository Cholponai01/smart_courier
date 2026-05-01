import 'dart:async';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectionService {
  final _controller = StreamController<bool>();

  Stream<bool> get connectionStream => _controller.stream;

  void startListening() {
    InternetConnection().onStatusChange.listen((status) {
      _controller.add(status == InternetStatus.connected);
    });
  }

  void dispose() {
    _controller.close();
  }
}
