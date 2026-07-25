import 'package:smart_courier/core/map/map_pick_result.dart';
import 'package:dgis_mobile_sdk_map/dgis.dart' as sdk;
import 'package:flutter/material.dart';
import 'package:smart_courier/core/constants/map_constants.dart';
import 'package:smart_courier/core/map/dgis_map_service.dart';

/// Default map center (Bishkek) used when confirming a map pick in MVP.
const _defaultPickLat = 42.8746;
const _defaultPickLng = 74.6122;

class DgisMapPickerSection extends StatefulWidget {
  const DgisMapPickerSection({
    required this.target,
    required this.mapService,
    required this.addressHint,
    required this.onLocationPicked,
    super.key,
  });

  final MapPickTarget target;
  final DgisMapService mapService;
  final String addressHint;
  final ValueChanged<MapPickResult> onLocationPicked;

  @override
  State<DgisMapPickerSection> createState() => _DgisMapPickerSectionState();
}

class _DgisMapPickerSectionState extends State<DgisMapPickerSection> {
  sdk.Context? _sdkContext;
  final _mapController = sdk.MapWidgetController();
  var _mapReady = false;

  @override
  void initState() {
    super.initState();
    _initSdk();
  }

  void _initSdk() {
    if (!widget.mapService.isAvailable) {
      return;
    }

    try {
      _sdkContext = sdk.DGis.initialize(
        keySource: sdk.KeySource.fromAsset(
          sdk.KeyFromAsset(MapConstants.dgisSdkKeyAssetPath),
        ),
      );
      _mapController.getMapAsync((_) {
        if (mounted) {
          setState(() => _mapReady = true);
        }
      });
    } catch (_) {
      _sdkContext = null;
    }
  }

  void _pickFromMap() {
    widget.onLocationPicked(
      MapPickResult(
        address: widget.addressHint,
        lat: _defaultPickLat,
        lng: _defaultPickLng,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sdkContext = _sdkContext;
    if (sdkContext == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 180,
          child: sdk.MapWidget(
            key: Key('dgis_map_${widget.target.name}'),
            sdkContext: sdkContext,
            mapOptions: sdk.MapOptions(),
            controller: _mapController,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: Key('map_pick_${widget.target.name}_button'),
          onPressed: _mapReady ? _pickFromMap : null,
          child: Text(widget.addressHint),
        ),
      ],
    );
  }
}
