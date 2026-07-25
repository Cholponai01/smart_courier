import 'package:equatable/equatable.dart';

class MapPickResult extends Equatable {
  const MapPickResult({
    required this.address,
    required this.lat,
    required this.lng,
  });

  final String address;
  final double lat;
  final double lng;

  @override
  List<Object?> get props => [address, lat, lng];
}

enum MapPickTarget { pickup, dropoff }
