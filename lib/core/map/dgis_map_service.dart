import 'package:flutter/services.dart';
import 'package:smart_courier/core/constants/map_constants.dart';
import 'package:smart_courier/core/logging/app_logger.dart';

/// Initializes the 2GIS SDK once and exposes availability to map widgets.
class DgisMapService {
  static const _logTag = 'DgisMapService';

  var _initialized = false;
  var _isAvailable = false;

  bool get isAvailable => _isAvailable;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    try {
      await rootBundle.load(MapConstants.dgisSdkKeyAssetPath);
      _isAvailable = true;
      AppLogger.debug('2GIS key asset found', tag: _logTag);
    } catch (error, stackTrace) {
      _isAvailable = false;
      AppLogger.error(
        '2GIS map unavailable — key asset missing or invalid',
        tag: _logTag,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
