import 'package:equatable/equatable.dart';

class Address extends Equatable {
  const Address({
    required this.address,
    required this.lat,
    required this.lng,
  });

  final String address;
  final double lat;
  final double lng;

  bool get hasCoordinates => lat != 0 || lng != 0;

  Address copyWith({String? address, double? lat, double? lng}) {
    return Address(
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  @override
  List<Object?> get props => [address, lat, lng];
}
