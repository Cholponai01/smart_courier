import 'package:flutter/material.dart';
import 'package:smart_courier/core/map/dgis_map_service.dart';
import 'package:smart_courier/core/map/map_pick_result.dart';
import 'package:smart_courier/core/map/map_picker_controller.dart';
import 'package:smart_courier/features/orders/data/map/dgis_map_picker_section.dart';

class DgisMapPickerController implements MapPickerController {
  DgisMapPickerController(this._mapService);

  final DgisMapService _mapService;

  @override
  bool get isAvailable => _mapService.isAvailable;

  @override
  Widget buildMapSection({
    required MapPickTarget target,
    required String addressHint,
    required ValueChanged<MapPickResult> onLocationPicked,
  }) {
    if (!isAvailable) {
      return const SizedBox.shrink();
    }

    return DgisMapPickerSection(
      target: target,
      mapService: _mapService,
      addressHint: addressHint,
      onLocationPicked: onLocationPicked,
    );
  }
}
