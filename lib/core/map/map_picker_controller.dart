import 'package:flutter/widgets.dart';
import 'package:smart_courier/core/map/map_pick_result.dart';

/// Map picker abstraction — UI implementations live in the data layer.
abstract class MapPickerController {
  bool get isAvailable;

  Widget buildMapSection({
    required MapPickTarget target,
    required String addressHint,
    required ValueChanged<MapPickResult> onLocationPicked,
  });
}
